import 'dart:async';
import 'package:flutter/foundation.dart';
import '../../models/space.dart';
import '../../models/item.dart';
import '../services/storage_service.dart';

class StorageProvider extends ChangeNotifier {
  final StorageService _service = StorageService();

  String? _uid;
  List<Space> _spaces = [];
  bool _isLoading = false;
  String? _errorMessage;
  StreamSubscription? _spacesSubscription;

  // ── Getters ──

  List<Space> get spaces => _spaces;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // ── Lifecycle ──

  void init(String uid) {
    if (_uid == uid) return; // Already listening
    _uid = uid;
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    _spacesSubscription?.cancel();
    _spacesSubscription = _service
        .getSpacesStream(uid)
        .listen(
          (spaces) {
            _spaces = spaces;
            _isLoading = false;
            _errorMessage = null;
            notifyListeners();
          },
          onError: (error) {
            _isLoading = false;
            _errorMessage = error.toString();
            notifyListeners();
          },
        );
  }

  void clear() {
    _spacesSubscription?.cancel();
    _spacesSubscription = null;
    _uid = null;
    _spaces = [];
    _isLoading = false;
    _errorMessage = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _spacesSubscription?.cancel();
    super.dispose();
  }

  // ── Space operations ──

  Future<bool> createSpace({
    required String name,
    required String location,
    required StorageType type,
  }) async {
    if (_uid == null) return false;
    try {
      _errorMessage = null;
      await _service.createSpace(
        uid: _uid!,
        name: name,
        location: location,
        type: type,
      );
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateSpace({
    required String spaceId,
    String? name,
    String? location,
  }) async {
    if (_uid == null) return false;
    try {
      _errorMessage = null;
      await _service.updateSpace(
        uid: _uid!,
        spaceId: spaceId,
        name: name,
        location: location,
      );
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteSpace(String spaceId) async {
    if (_uid == null) return false;
    try {
      _errorMessage = null;
      await _service.deleteSpace(uid: _uid!, spaceId: spaceId);
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  // ── Item operations ──

  Future<bool> addItem({
    required String spaceId,
    required String name,
    int quantity = 1,
    String? description,
    String? note,
    String? iconPath,
  }) async {
    if (_uid == null) return false;
    try {
      _errorMessage = null;
      await _service.addItem(
        uid: _uid!,
        spaceId: spaceId,
        name: name,
        quantity: quantity,
        description: description,
        note: note,
        iconPath: iconPath,
      );
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateItem({
    required String spaceId,
    required String itemId,
    String? name,
    int? quantity,
    String? description,
    String? note,
  }) async {
    if (_uid == null) return false;
    try {
      _errorMessage = null;
      await _service.updateItem(
        uid: _uid!,
        spaceId: spaceId,
        itemId: itemId,
        name: name,
        quantity: quantity,
        description: description,
        note: note,
      );
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteItem({
    required String spaceId,
    required String itemId,
  }) async {
    if (_uid == null) return false;
    try {
      _errorMessage = null;
      await _service.deleteItem(uid: _uid!, spaceId: spaceId, itemId: itemId);
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  Stream<List<Item>> getItemsStream(String spaceId) {
    if (_uid == null) return const Stream.empty();
    return _service.getItemsStream(_uid!, spaceId);
  }

  Future<bool> moveItem({
    required String fromSpaceId,
    required String toSpaceId,
    required Item item,
  }) async {
    if (_uid == null) return false;
    try {
      _errorMessage = null;
      await _service.moveItem(
        uid: _uid!,
        fromSpaceId: fromSpaceId,
        toSpaceId: toSpaceId,
        item: item,
      );
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  // ── Search (global: spaces + items) ──

  List<Space> searchSpaces(String query) {
    if (query.isEmpty) return [];
    final lowerQuery = query.toLowerCase();
    return _spaces.where((space) {
      return space.name.toLowerCase().contains(lowerQuery) ||
          space.location.toLowerCase().contains(lowerQuery);
    }).toList();
  }

  Future<SearchResult> searchGlobal(String query) async {
    final trimmed = query.trim();
    if (trimmed.isEmpty || _uid == null) return const SearchResult();
    final lowerQuery = trimmed.toLowerCase();

    final matchedSpaces =
        _spaces
            .where(
              (s) =>
                  s.name.toLowerCase().contains(lowerQuery) ||
                  s.location.toLowerCase().contains(lowerQuery),
            )
            .toList();

    final allItems = await _service.getAllItems(_uid!);
    final matchedItems =
        allItems
            .where(
              (item) =>
                  item.name.toLowerCase().contains(lowerQuery) ||
                  (item.note?.toLowerCase().contains(lowerQuery) ?? false),
            )
            .toList();

    return SearchResult(spaces: matchedSpaces, items: matchedItems);
  }

  Space? getSpaceById(String id) {
    try {
      return _spaces.firstWhere((s) => s.id == id);
    } catch (_) {
      return null;
    }
  }
}

class SearchResult {
  final List<Space> spaces;
  final List<Item> items;
  const SearchResult({this.spaces = const [], this.items = const []});
  bool get isEmpty => spaces.isEmpty && items.isEmpty;
}
