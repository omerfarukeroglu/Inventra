import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/space.dart';
import '../../models/item.dart';

class StorageService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // ── Collection references ──

  CollectionReference<Map<String, dynamic>> _spacesRef(String uid) =>
      _db.collection('users').doc(uid).collection('spaces');

  CollectionReference<Map<String, dynamic>> _itemsRef(
    String uid,
    String spaceId,
  ) => _spacesRef(uid).doc(spaceId).collection('items');

  // ── Space operations ──

  Future<void> createSpace({
    required String uid,
    required String name,
    required String location,
    required StorageType type,
  }) async {
    await _spacesRef(uid).add({
      'name': name,
      'location': location,
      'type': type.name,
      'itemCount': 0,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> updateSpace({
    required String uid,
    required String spaceId,
    String? name,
    String? location,
  }) async {
    final data = <String, dynamic>{};
    if (name != null) data['name'] = name;
    if (location != null) data['location'] = location;
    if (data.isNotEmpty) {
      await _spacesRef(uid).doc(spaceId).update(data);
    }
  }

  Future<void> deleteSpace({
    required String uid,
    required String spaceId,
  }) async {
    // Delete all items in subcollection first
    final items = await _itemsRef(uid, spaceId).get();
    final batch = _db.batch();
    for (final doc in items.docs) {
      batch.delete(doc.reference);
    }
    batch.delete(_spacesRef(uid).doc(spaceId));
    await batch.commit();
  }

  Stream<List<Space>> getSpacesStream(String uid) {
    return _spacesRef(uid)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs
                  .map((doc) => Space.fromMap(doc.data(), doc.id))
                  .toList(),
        );
  }

  /// Fetches all items across all spaces for a user (one-shot).
  Future<List<Item>> getAllItems(String uid) async {
    final spacesSnapshot = await _spacesRef(uid).get();
    final List<Item> allItems = [];
    for (final spaceDoc in spacesSnapshot.docs) {
      final itemsSnapshot = await _itemsRef(uid, spaceDoc.id).get();
      allItems.addAll(
        itemsSnapshot.docs.map((doc) => Item.fromMap(doc.data(), doc.id)),
      );
    }
    return allItems;
  }

  // ── Item operations ──

  Future<void> addItem({
    required String uid,
    required String spaceId,
    required String name,
    int quantity = 1,
    String? description,
    String? note,
  }) async {
    final batch = _db.batch();

    final itemRef = _itemsRef(uid, spaceId).doc();
    batch.set(itemRef, {
      'name': name,
      'spaceId': spaceId,
      'quantity': quantity,
      if (description != null) 'description': description,
      if (note != null) 'note': note,
      'createdAt': FieldValue.serverTimestamp(),
    });

    // Increment itemCount on parent space
    batch.update(_spacesRef(uid).doc(spaceId), {
      'itemCount': FieldValue.increment(1),
    });

    await batch.commit();
  }

  Future<void> updateItem({
    required String uid,
    required String spaceId,
    required String itemId,
    String? name,
    int? quantity,
    String? description,
    String? note,
  }) async {
    final data = <String, dynamic>{'updatedAt': FieldValue.serverTimestamp()};
    if (name != null) data['name'] = name;
    if (quantity != null) data['quantity'] = quantity;
    if (description != null) data['description'] = description;
    if (note != null) data['note'] = note;

    await _itemsRef(uid, spaceId).doc(itemId).update(data);
  }

  Future<void> deleteItem({
    required String uid,
    required String spaceId,
    required String itemId,
  }) async {
    final batch = _db.batch();
    batch.delete(_itemsRef(uid, spaceId).doc(itemId));
    batch.update(_spacesRef(uid).doc(spaceId), {
      'itemCount': FieldValue.increment(-1),
    });
    await batch.commit();
  }

  Stream<List<Item>> getItemsStream(String uid, String spaceId) {
    return _itemsRef(uid, spaceId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs
                  .map((doc) => Item.fromMap(doc.data(), doc.id))
                  .toList(),
        );
  }

  Future<void> moveItem({
    required String uid,
    required String fromSpaceId,
    required String toSpaceId,
    required Item item,
  }) async {
    final batch = _db.batch();

    // Delete from source
    batch.delete(_itemsRef(uid, fromSpaceId).doc(item.id));
    batch.update(_spacesRef(uid).doc(fromSpaceId), {
      'itemCount': FieldValue.increment(-1),
    });

    // Add to destination
    final newItemRef = _itemsRef(uid, toSpaceId).doc();
    batch.set(newItemRef, {
      ...item.toMap(),
      'spaceId': toSpaceId,
      'updatedAt': FieldValue.serverTimestamp(),
    });
    batch.update(_spacesRef(uid).doc(toSpaceId), {
      'itemCount': FieldValue.increment(1),
    });

    await batch.commit();
  }
}
