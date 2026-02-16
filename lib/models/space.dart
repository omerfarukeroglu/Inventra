import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';

enum StorageType { box, drawer, shelf, cabinet }

class Space {
  final String id;
  final String name;
  final String location;
  final StorageType type;
  final int itemCount;
  final DateTime createdAt;

  Space({
    required this.id,
    required this.name,
    required this.location,
    required this.type,
    this.itemCount = 0,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  // ── Firestore serialization ──

  factory Space.fromMap(Map<String, dynamic> map, String id) {
    return Space(
      id: id,
      name: map['name'] as String? ?? '',
      location: map['location'] as String? ?? '',
      type: StorageType.values.firstWhere(
        (e) => e.name == (map['type'] as String?),
        orElse: () => StorageType.box,
      ),
      itemCount: map['itemCount'] as int? ?? 0,
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'location': location,
      'type': type.name,
      'itemCount': itemCount,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  Space copyWith({
    String? id,
    String? name,
    String? location,
    StorageType? type,
    int? itemCount,
    DateTime? createdAt,
  }) {
    return Space(
      id: id ?? this.id,
      name: name ?? this.name,
      location: location ?? this.location,
      type: type ?? this.type,
      itemCount: itemCount ?? this.itemCount,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  // ── UI helpers (derived from type) ──

  IconData get icon => getIconForType(type);
  Color get iconColor => getColorForType(type);
  String get qrCode => id;

  static IconData getIconForType(StorageType type) {
    switch (type) {
      case StorageType.box:
        return Icons.inventory_2_outlined;
      case StorageType.drawer:
        return Icons.view_agenda_outlined;
      case StorageType.shelf:
        return Icons.shelves;
      case StorageType.cabinet:
        return Icons.kitchen_outlined;
    }
  }

  static Color getColorForType(StorageType type) {
    switch (type) {
      case StorageType.box:
        return AppColors.cyan;
      case StorageType.drawer:
        return AppColors.orange;
      case StorageType.shelf:
        return AppColors.teal;
      case StorageType.cabinet:
        return AppColors.cyan;
    }
  }

  static String getTypeLabel(StorageType type) {
    switch (type) {
      case StorageType.box:
        return 'Box';
      case StorageType.drawer:
        return 'Drawer';
      case StorageType.shelf:
        return 'Shelf';
      case StorageType.cabinet:
        return 'Cabinet';
    }
  }
}
