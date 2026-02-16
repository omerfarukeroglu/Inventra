import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/providers/storage_provider.dart';
import '../../../l10n/app_localizations.dart';
import '../../storage/screens/storage_detail_screen.dart';

/// QR Scanner Screen — Full camera lifecycle managed via [widget.isActive].
///
/// Key design decisions (Samsung S22 ANR fix):
///  1. Controller is created/disposed per activation cycle (not per State lifecycle).
///  2. [MobileScanner] widget is NEVER in the tree when [widget.isActive] is false.
///  3. A lock flag [_isBusy] prevents overlapping init/dispose operations.
class QRScannerScreen extends StatefulWidget {
  final bool isActive;

  const QRScannerScreen({super.key, this.isActive = false});

  @override
  State<QRScannerScreen> createState() => _QRScannerScreenState();
}

class _QRScannerScreenState extends State<QRScannerScreen>
    with WidgetsBindingObserver {
  // ── State ──────────────────────────────────────────────────────────────
  MobileScannerController? _controller;
  bool _hasPermission = false;
  bool _permissionChecked = false;
  bool _isPermanentlyDenied = false;
  bool _isProcessing = false;
  bool _flashOn = false;
  bool _cameraError = false;

  /// Prevents concurrent init/dispose calls (race-condition lock).
  bool _isBusy = false;

  // ── Lifecycle ──────────────────────────────────────────────────────────

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    // Dismiss keyboard leaked from other tabs
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && widget.isActive) {
        FocusManager.instance.primaryFocus?.unfocus();
        SystemChannels.textInput.invokeMethod('TextInput.hide');
      }
    });

    _checkPermission();
  }

  @override
  void didUpdateWidget(QRScannerScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isActive == oldWidget.isActive) return;

    if (widget.isActive) {
      // Tab became active → spin up camera
      if (_hasPermission) _createAndStartCamera();
    } else {
      // Tab became inactive → tear down camera completely
      _disposeCamera();
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (!widget.isActive || !_hasPermission) return;

    switch (state) {
      case AppLifecycleState.paused:
      case AppLifecycleState.inactive:
        _disposeCamera();
        break;
      case AppLifecycleState.resumed:
        _createAndStartCamera();
        break;
      default:
        break;
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _controller?.dispose();
    super.dispose();
  }

  // ── Camera Control (Thread-safe) ───────────────────────────────────────

  Future<void> _createAndStartCamera() async {
    if (_isBusy || _cameraError) return;
    _isBusy = true;

    try {
      // Always dispose previous controller first
      await _controller?.dispose();
      _controller = null;

      final controller = MobileScannerController(
        detectionSpeed: DetectionSpeed.noDuplicates,
        facing: CameraFacing.back,
        torchEnabled: false,
        autoStart: false,
        returnImage: false,
      );

      if (!mounted) {
        await controller.dispose();
        return;
      }

      _controller = controller;
      setState(() {});

      await controller.start();
    } catch (e) {
      debugPrint('Camera init/start failed: $e');
      if (mounted) setState(() => _cameraError = true);
    } finally {
      _isBusy = false;
    }
  }

  Future<void> _disposeCamera() async {
    if (_isBusy) return;
    _isBusy = true;

    try {
      _flashOn = false;
      final ctrl = _controller;
      _controller = null;
      if (mounted) setState(() {});
      await ctrl?.dispose();
    } catch (e) {
      debugPrint('Camera dispose failed: $e');
    } finally {
      _isBusy = false;
    }
  }

  // ── Permissions ────────────────────────────────────────────────────────

  Future<void> _checkPermission() async {
    if (!Platform.isAndroid && !Platform.isIOS) {
      // Desktop → assume granted
      if (mounted) {
        setState(() {
          _permissionChecked = true;
          _hasPermission = true;
        });
        if (widget.isActive) _createAndStartCamera();
      }
      return;
    }

    final status = await Permission.camera.status;
    if (!mounted) return;

    setState(() {
      _permissionChecked = true;
      _hasPermission = status.isGranted;
      _isPermanentlyDenied = status.isPermanentlyDenied;
    });

    if (status.isGranted) {
      if (widget.isActive) _createAndStartCamera();
    } else if (status.isDenied && !status.isPermanentlyDenied) {
      _requestPermission();
    }
  }

  Future<void> _requestPermission() async {
    final status = await Permission.camera.request();
    if (!mounted) return;

    setState(() {
      _hasPermission = status.isGranted;
      _isPermanentlyDenied = status.isPermanentlyDenied;
    });

    if (status.isGranted && widget.isActive) {
      _createAndStartCamera();
    }
  }

  // ── QR Detection ──────────────────────────────────────────────────────

  void _onDetect(BarcodeCapture capture) {
    if (_isProcessing) return;

    final code = capture.barcodes.firstOrNull?.rawValue;
    if (code == null || code.isEmpty) return;

    setState(() => _isProcessing = true);
    _handleCode(code);
  }

  void _handleCode(String code) {
    final storageProvider = context.read<StorageProvider>();
    final l10n = AppLocalizations.of(context)!;

    final found = storageProvider.spaces.any(
      (s) => s.qrCode == code || s.id == code,
    );

    if (found) {
      final space = storageProvider.spaces.firstWhere(
        (s) => s.qrCode == code || s.id == code,
      );

      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => StorageDetailScreen(space: space)),
      ).then((_) {
        if (mounted) setState(() => _isProcessing = false);
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.searchingFor(code)),
          backgroundColor: AppColors.warning,
          behavior: SnackBarBehavior.floating,
        ),
      );

      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) setState(() => _isProcessing = false);
      });
    }
  }

  // ── Flash Toggle ───────────────────────────────────────────────────────

  void _toggleFlash() {
    _controller?.toggleTorch();
    setState(() => _flashOn = !_flashOn);
  }

  // ── Build ──────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    // 1️⃣ Tab is NOT active → return nothing (no camera resources)
    if (!widget.isActive) return const SizedBox.shrink();

    // 2️⃣ Checking permissions
    if (!_permissionChecked) {
      return _buildShell(
        child: const Center(
          child: CircularProgressIndicator(color: AppColors.cyan),
        ),
      );
    }

    // 3️⃣ Permission denied
    if (!_hasPermission) {
      return _buildShell(child: SafeArea(child: _buildPermissionUI(l10n)));
    }

    // 4️⃣ Camera error / simulator fallback
    if (_cameraError) {
      return _buildShell(child: _buildErrorUI());
    }

    // 5️⃣ Controller not ready yet (brief init state)
    if (_controller == null) {
      return _buildShell(
        child: const Center(
          child: CircularProgressIndicator(color: AppColors.cyan),
        ),
      );
    }

    // 6️⃣ Camera ready — show scanner
    return _buildShell(
      child: GestureDetector(
        onTap: () {
          FocusManager.instance.primaryFocus?.unfocus();
          SystemChannels.textInput.invokeMethod('TextInput.hide');
        },
        behavior: HitTestBehavior.translucent,
        child: Stack(
          children: [
            // Camera feed
            MobileScanner(
              controller: _controller!,
              onDetect: _onDetect,
              errorBuilder: (context, error) {
                return _buildErrorUI(detail: error.errorCode.toString());
              },
            ),

            // Overlay UI
            _buildOverlay(l10n),
          ],
        ),
      ),
    );
  }

  // ── UI Building Blocks ─────────────────────────────────────────────────

  Widget _buildShell({required Widget child}) {
    return Scaffold(
      backgroundColor: AppColors.darkBackground,
      resizeToAvoidBottomInset: false,
      body: child,
    );
  }

  Widget _buildOverlay(AppLocalizations l10n) {
    return SafeArea(
      child: Column(
        children: [
          // Top bar — flash toggle
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [_FlashButton(isOn: _flashOn, onTap: _toggleFlash)],
            ),
          ),

          const Spacer(),

          // Scanner frame
          const SizedBox(
            width: 280,
            height: 280,
            child: CustomPaint(painter: _ScannerFramePainter()),
          ),

          const SizedBox(height: 32),

          // Hint pill
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            decoration: BoxDecoration(
              color: AppColors.darkSurface.withValues(alpha: 0.85),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              l10n.alignQRCode,
              style: const TextStyle(
                color: AppColors.darkTextSecondary,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),

          const Spacer(),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildErrorUI({String? detail}) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.darkSurface,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.videocam_off_rounded,
                color: AppColors.darkTextSecondary,
                size: 56,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Camera not available',
              style: TextStyle(
                color: AppColors.darkTextPrimary,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              detail ?? 'Simulator or hardware error',
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppColors.darkTextSecondary,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPermissionUI(AppLocalizations l10n) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.darkSurface,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.camera_alt_outlined,
                color: AppColors.darkTextSecondary,
                size: 56,
              ),
            ),
            const SizedBox(height: 32),
            Text(
              l10n.cameraPermissionRequired,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppColors.darkTextPrimary,
                fontSize: 20,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              l10n.cameraPermissionMessage,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppColors.darkTextSecondary,
                fontSize: 15,
              ),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton.icon(
                onPressed:
                    _isPermanentlyDenied
                        ? () => openAppSettings()
                        : _requestPermission,
                icon: Icon(
                  _isPermanentlyDenied ? Icons.settings : Icons.camera_alt,
                ),
                label: Text(
                  _isPermanentlyDenied
                      ? l10n.openSettings
                      : l10n.grantPermission,
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.cyan,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  textStyle: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Flash Button ─────────────────────────────────────────────────────────

class _FlashButton extends StatelessWidget {
  final bool isOn;
  final VoidCallback onTap;

  const _FlashButton({required this.isOn, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: AppColors.darkSurface.withValues(alpha: 0.85),
          shape: BoxShape.circle,
          border: Border.all(
            color:
                isOn
                    ? AppColors.cyan.withValues(alpha: 0.6)
                    : Colors.transparent,
            width: 1.5,
          ),
        ),
        child: Icon(
          isOn ? Icons.flash_on_rounded : Icons.flash_off_rounded,
          color: isOn ? AppColors.cyan : AppColors.darkTextPrimary,
          size: 22,
        ),
      ),
    );
  }
}

// ── Scanner Frame Painter ────────────────────────────────────────────────

class _ScannerFramePainter extends CustomPainter {
  const _ScannerFramePainter();

  @override
  void paint(Canvas canvas, Size size) {
    final paint =
        Paint()
          ..color = AppColors.cyan
          ..strokeWidth = 3.5
          ..style = PaintingStyle.stroke
          ..strokeCap = StrokeCap.round;

    const corner = 48.0;
    const r = 16.0;

    // Top-left
    canvas.drawPath(
      Path()
        ..moveTo(0, corner)
        ..lineTo(0, r)
        ..quadraticBezierTo(0, 0, r, 0)
        ..lineTo(corner, 0),
      paint,
    );

    // Top-right
    canvas.drawPath(
      Path()
        ..moveTo(size.width - corner, 0)
        ..lineTo(size.width - r, 0)
        ..quadraticBezierTo(size.width, 0, size.width, r)
        ..lineTo(size.width, corner),
      paint,
    );

    // Bottom-left
    canvas.drawPath(
      Path()
        ..moveTo(0, size.height - corner)
        ..lineTo(0, size.height - r)
        ..quadraticBezierTo(0, size.height, r, size.height)
        ..lineTo(corner, size.height),
      paint,
    );

    // Bottom-right
    canvas.drawPath(
      Path()
        ..moveTo(size.width - corner, size.height)
        ..lineTo(size.width - r, size.height)
        ..quadraticBezierTo(
          size.width,
          size.height,
          size.width,
          size.height - r,
        )
        ..lineTo(size.width, size.height - corner),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
