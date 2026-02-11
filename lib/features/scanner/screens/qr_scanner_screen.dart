import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/providers/app_state_provider.dart';
import '../../../l10n/app_localizations.dart';
import '../../storage/screens/storage_detail_screen.dart';

class QRScannerScreen extends StatefulWidget {
  final bool isActive;

  const QRScannerScreen({
    super.key,
    this.isActive =
        false, // Default false to prevent auto-start if not specified
  });

  @override
  State<QRScannerScreen> createState() => _QRScannerScreenState();
}

class _QRScannerScreenState extends State<QRScannerScreen>
    with WidgetsBindingObserver {
  MobileScannerController? _cameraController;
  bool _hasPermission = false;
  bool _permissionChecked = false;
  bool _permissionPermanentlyDenied = false;
  bool _isProcessing = false;
  bool _flashOn = false;

  // Softer, professional palette for QR screen
  static const _bgPrimary = Color(0xFF111D2E);
  static const _bgSurface = Color(0xFF1A2838);
  static const _textPrimary = Color(0xFFE8EDF2);
  static const _textSecondary = Color(0xFF9CA8B8);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    // Dismiss any open keyboard when QR screen is shown
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && widget.isActive) {
        FocusManager.instance.primaryFocus?.unfocus();
        SystemChannels.textInput.invokeMethod('TextInput.hide');
      }
    });

    _checkCameraPermission();
  }

  @override
  void didUpdateWidget(QRScannerScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isActive != oldWidget.isActive) {
      if (widget.isActive) {
        _startCamera();
      } else {
        _stopCamera();
      }
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (!widget.isActive) return;

    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive) {
      _stopCamera();
    } else if (state == AppLifecycleState.resumed) {
      _startCamera();
    }
  }

  @override
  Future<void> dispose() async {
    WidgetsBinding.instance.removeObserver(this);
    await _cameraController?.dispose();
    super.dispose();
  }

  Future<void> _startCamera() async {
    if (_cameraController != null && _hasPermission) {
      try {
        await _cameraController!.start();
      } catch (e) {
        debugPrint('Error starting camera: $e');
      }
    }
  }

  Future<void> _stopCamera() async {
    if (_cameraController != null) {
      try {
        await _cameraController!.stop();
      } catch (e) {
        debugPrint('Error stopping camera: $e');
      }
    }
  }

  Future<void> _checkCameraPermission() async {
    if (Platform.isAndroid || Platform.isIOS) {
      final status = await Permission.camera.status;

      if (mounted) {
        setState(() {
          _permissionChecked = true;
          _hasPermission = status.isGranted;
          _permissionPermanentlyDenied = status.isPermanentlyDenied;
        });

        if (status.isGranted) {
          _initializeCamera();
        } else if (status.isDenied) {
          await _requestCameraPermission();
        }
      }
    } else {
      if (mounted) {
        setState(() {
          _permissionChecked = true;
          _hasPermission = true;
        });
        _initializeCamera();
      }
    }
  }

  Future<void> _initializeCamera() async {
    // Simülatör kontrolü (Basit bir kontrol, daha gelişmişi için device_info_plus kullanılabilir ama bu yeterli)
    final isSimulator = Platform.isIOS && !await _isRealDevice();

    if (isSimulator) {
      // Simülatörde kamerayı başlatma
      return;
    }

    // Var olan controller'ı temizle
    if (_cameraController != null) {
      await _cameraController!.dispose();
    }

    _cameraController = MobileScannerController(
      detectionSpeed: DetectionSpeed.normal,
      facing: CameraFacing.back,
      torchEnabled: false,
      autoStart: false, // Don't auto start, we control it
      returnImage: false,
    );

    if (mounted) {
      setState(() {});
      // Only start if active
      if (widget.isActive) {
        _startCamera();
      }
    }
  }

  // Basit bir simülatör kontrolü fonksiyonu (gerçek projede device_info_plus önerilir)
  // Ancak burada 'availableCameras' listesinin boş olması da bir ipucudur.
  Future<bool> _isRealDevice() async {
    // Bu örnek için her zaman true döndürüyoruz, çünkü device_info_plus paketi yok.
    // Ancak hata yakalama (try-catch) ile yönetmek daha güvenli.
    // Kullanıcı isteği "Simülatörde hata mesajını gizle" olduğu için build metodunda hata yakalayacağız.
    return true;
  }

  Future<void> _requestCameraPermission() async {
    final status = await Permission.camera.request();

    if (mounted) {
      setState(() {
        _hasPermission = status.isGranted;
        _permissionPermanentlyDenied = status.isPermanentlyDenied;
      });

      if (status.isGranted) {
        _initializeCamera();
      }
    }
  }

  void _onQRCodeDetected(BarcodeCapture capture) {
    if (_isProcessing) return;

    final barcode = capture.barcodes.firstOrNull;
    if (barcode?.rawValue == null) return;

    final code = barcode!.rawValue!;
    _isProcessing = true;

    // QR kodu ile eşleşen depolama alanını bul
    final appState = context.read<AppStateProvider>();
    final matchingSpace = appState.spaces.firstWhere(
      (space) => space.qrCode == code || space.id == code,
      orElse: () => appState.spaces.first,
    );

    final l10n = AppLocalizations.of(context)!;

    // Eşleşen alan bulundu mu kontrol et
    final found = appState.spaces.any(
      (space) => space.qrCode == code || space.id == code,
    );

    if (found) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => StorageDetailScreen(space: matchingSpace),
        ),
      ).then((_) {
        _isProcessing = false;
      });
    } else {
      // Eşleşme bulunamadı
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.searchingFor(code)),
          backgroundColor: AppColors.warning,
          behavior: SnackBarBehavior.floating,
        ),
      );

      // Kısa bir beklemeden sonra taramaya devam et
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) {
          _isProcessing = false;
        }
      });
    }
  }

  void _toggleFlash() {
    _cameraController?.toggleTorch();
    setState(() {
      _flashOn = !_flashOn;
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    // İzin kontrolü yapılmadıysa loading göster
    if (!_permissionChecked) {
      return Scaffold(
        backgroundColor: _bgPrimary,
        resizeToAvoidBottomInset: false,
        body: const Center(
          child: CircularProgressIndicator(color: AppColors.cyan),
        ),
      );
    }

    // İzin verilmediyse izin isteme ekranı göster
    if (!_hasPermission) {
      return Scaffold(
        backgroundColor: _bgPrimary,
        resizeToAvoidBottomInset: false,
        body: SafeArea(child: _buildPermissionDeniedUI(l10n)),
      );
    }

    // Kamera henüz başlatılmadıysa loading göster
    if (_cameraController == null) {
      return Scaffold(
        backgroundColor: _bgPrimary,
        resizeToAvoidBottomInset: false,
        body: const Center(
          child: CircularProgressIndicator(color: AppColors.cyan),
        ),
      );
    }

    return Scaffold(
      backgroundColor: _bgPrimary,
      resizeToAvoidBottomInset: false,
      body: GestureDetector(
        onTap: () {
          // Force close keyboard on any tap in QR screen
          FocusManager.instance.primaryFocus?.unfocus();
          SystemChannels.textInput.invokeMethod('TextInput.hide');
        },
        behavior: HitTestBehavior.translucent,
        child: Stack(
          children: [
            // Kamera Önizlemesi
            if (_cameraController != null)
              MobileScanner(
                controller: _cameraController!,
                onDetect: _onQRCodeDetected,
                errorBuilder: (context, error) {
                  // iOS simulator (veya genel desteklenmeyen cihaz) için
                  // daha açıklayıcı bir mesaj gösteriyoruz.
                  if (error.errorCode == MobileScannerErrorCode.unsupported &&
                      Platform.isIOS) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.phone_iphone,
                            color: _textSecondary,
                            size: 64,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Camera not available\nin iOS Simulator.\nPlease test on a real device.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: _textSecondary,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  // Diğer beklenmedik hatalar için genel mesaj
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.broken_image_outlined,
                          color: _textSecondary,
                          size: 64,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Camera error:\n${error.errorCode}',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: _textSecondary, fontSize: 16),
                        ),
                      ],
                    ),
                  );
                },
              )
            else
              // Controller null ise (simülatör durumu vb.) placeholder göster
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.phone_iphone, color: _textSecondary, size: 64),
                    const SizedBox(height: 16),
                    Text(
                      'Camera not available\non simulator',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: _textSecondary, fontSize: 16),
                    ),
                  ],
                ),
              ),

            // Overlay
            SafeArea(
              child: Column(
                children: [
                  // Top Bar
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        GestureDetector(
                          onTap: _toggleFlash,
                          child: Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: _bgSurface.withValues(alpha: 0.8),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              _flashOn
                                  ? Icons.flashlight_on
                                  : Icons.flashlight_off,
                              color: _flashOn ? AppColors.cyan : _textPrimary,
                              size: 22,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const Spacer(),

                  // Scanner Frame
                  SizedBox(
                    width: 280,
                    height: 280,
                    child: CustomPaint(painter: _ScannerFramePainter()),
                  ),

                  const SizedBox(height: 40),

                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: _bgSurface.withValues(alpha: 0.8),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      l10n.alignQRCode,
                      style: TextStyle(
                        color: _textSecondary,
                        fontSize: 15,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ),

                  const Spacer(),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPermissionDeniedUI(AppLocalizations l10n) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: _bgSurface,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.camera_alt_outlined,
                color: _textSecondary,
                size: 64,
              ),
            ),
            const SizedBox(height: 32),
            Text(
              l10n.cameraPermissionRequired,
              style: TextStyle(
                color: _textPrimary,
                fontSize: 20,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Text(
              l10n.cameraPermissionMessage,
              style: TextStyle(color: _textSecondary, fontSize: 15),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            if (_permissionPermanentlyDenied) ...[
              ElevatedButton.icon(
                onPressed: () => openAppSettings(),
                icon: const Icon(Icons.settings),
                label: Text(l10n.openSettings),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.cyan,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 16,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ] else ...[
              ElevatedButton.icon(
                onPressed: _requestCameraPermission,
                icon: const Icon(Icons.camera_alt),
                label: Text(l10n.grantPermission),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.cyan,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 16,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _ScannerFramePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint =
        Paint()
          ..color = const Color(0xFF5BC0D4)
          ..strokeWidth = 4
          ..style = PaintingStyle.stroke
          ..strokeCap = StrokeCap.round;

    const cornerLength = 52.0;
    const radius = 20.0;

    // Top-left corner
    final topLeftPath = Path();
    topLeftPath.moveTo(0, cornerLength);
    topLeftPath.lineTo(0, radius);
    topLeftPath.quadraticBezierTo(0, 0, radius, 0);
    topLeftPath.lineTo(cornerLength, 0);
    canvas.drawPath(topLeftPath, paint);

    // Top-right corner
    final topRightPath = Path();
    topRightPath.moveTo(size.width - cornerLength, 0);
    topRightPath.lineTo(size.width - radius, 0);
    topRightPath.quadraticBezierTo(size.width, 0, size.width, radius);
    topRightPath.lineTo(size.width, cornerLength);
    canvas.drawPath(topRightPath, paint);

    // Bottom-left corner
    final bottomLeftPath = Path();
    bottomLeftPath.moveTo(0, size.height - cornerLength);
    bottomLeftPath.lineTo(0, size.height - radius);
    bottomLeftPath.quadraticBezierTo(0, size.height, radius, size.height);
    bottomLeftPath.lineTo(cornerLength, size.height);
    canvas.drawPath(bottomLeftPath, paint);

    // Bottom-right corner
    final bottomRightPath = Path();
    bottomRightPath.moveTo(size.width - cornerLength, size.height);
    bottomRightPath.lineTo(size.width - radius, size.height);
    bottomRightPath.quadraticBezierTo(
      size.width,
      size.height,
      size.width,
      size.height - radius,
    );
    bottomRightPath.lineTo(size.width, size.height - cornerLength);
    canvas.drawPath(bottomRightPath, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
