import 'package:flutter/material.dart';

enum SpaceType {
  box,
  drawer,
  shelf,
  cabinet,
}

class Space {
  final String id;
  final String name;
  final String location;
  final SpaceType type;
  final int itemCount;
  final String qrCode;
  final IconData icon;
  final Color iconColor;
  final bool isActive;
  final DateTime createdAt;

  Space({
    required this.id,
    required this.name,
    required this.location,
    required this.type,
    required this.itemCount,
    required this.qrCode,
    required this.icon,
    required this.iconColor,
    this.isActive = true,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  Space copyWith({
    String? id,
    String? name,
    String? location,
    SpaceType? type,
    int? itemCount,
    String? qrCode,
    IconData? icon,
    Color? iconColor,
    bool? isActive,
    DateTime? createdAt,
  }) {
    return Space(
      id: id ?? this.id,
      name: name ?? this.name,
      location: location ?? this.location,
      type: type ?? this.type,
      itemCount: itemCount ?? this.itemCount,
      qrCode: qrCode ?? this.qrCode,
      icon: icon ?? this.icon,
      iconColor: iconColor ?? this.iconColor,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  static IconData getIconForType(SpaceType type) {
    switch (type) {
      case SpaceType.box:
        return Icons.inventory_2_outlined;
      case SpaceType.drawer:
        return Icons.view_agenda_outlined;
      case SpaceType.shelf:
        return Icons.shelves;
      case SpaceType.cabinet:
        return Icons.kitchen_outlined;
    }
  }

  static String getTypeLabel(SpaceType type) {
    switch (type) {
      case SpaceType.box:
        return 'Box';
      case SpaceType.drawer:
        return 'Drawer';
      case SpaceType.shelf:
        return 'Shelf';
      case SpaceType.cabinet:
        return 'Cabinet';
    }
  }
}
