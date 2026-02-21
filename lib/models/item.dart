import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class Item {
  final String id;
  final String name;
  final String? description;
  final String spaceId;
  final int quantity;
  final String? note;
  final String? iconPath;
  final DateTime createdAt;
  final DateTime? updatedAt;

  Item({
    required this.id,
    required this.name,
    this.description,
    required this.spaceId,
    this.quantity = 1,
    this.note,
    this.iconPath,
    DateTime? createdAt,
    this.updatedAt,
  }) : createdAt = createdAt ?? DateTime.now();

  // ── Firestore serialization ──

  factory Item.fromMap(Map<String, dynamic> map, String id) {
    return Item(
      id: id,
      name: map['name'] as String? ?? '',
      description: map['description'] as String?,
      spaceId: map['spaceId'] as String? ?? '',
      quantity: map['quantity'] as int? ?? 1,
      note: map['note'] as String?,
      iconPath: map['iconPath'] as String?,
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (map['updatedAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      if (description != null) 'description': description,
      'spaceId': spaceId,
      'quantity': quantity,
      if (note != null) 'note': note,
      if (iconPath != null) 'iconPath': iconPath,
      'createdAt': Timestamp.fromDate(createdAt),
      if (updatedAt != null) 'updatedAt': Timestamp.fromDate(updatedAt!),
    };
  }

  Item copyWith({
    String? id,
    String? name,
    String? description,
    String? spaceId,
    int? quantity,
    String? note,
    String? iconPath,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Item(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      spaceId: spaceId ?? this.spaceId,
      quantity: quantity ?? this.quantity,
      note: note ?? this.note,
      iconPath: iconPath ?? this.iconPath,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  // ── UI helper ──

  IconData get icon => Icons.inventory_2_outlined;
}

// ── Notification Model (unchanged) ──

class NotificationItem {
  final String id;
  final String title;
  final String message;
  final NotificationType type;
  final DateTime createdAt;
  final bool isRead;
  final IconData icon;
  final Color iconBgColor;

  NotificationItem({
    required this.id,
    required this.title,
    required this.message,
    required this.type,
    required this.createdAt,
    this.isRead = false,
    required this.icon,
    required this.iconBgColor,
  });

  NotificationItem copyWith({
    String? id,
    String? title,
    String? message,
    NotificationType? type,
    DateTime? createdAt,
    bool? isRead,
    IconData? icon,
    Color? iconBgColor,
  }) {
    return NotificationItem(
      id: id ?? this.id,
      title: title ?? this.title,
      message: message ?? this.message,
      type: type ?? this.type,
      createdAt: createdAt ?? this.createdAt,
      isRead: isRead ?? this.isRead,
      icon: icon ?? this.icon,
      iconBgColor: iconBgColor ?? this.iconBgColor,
    );
  }

  String get timeAgo {
    final now = DateTime.now();
    final difference = now.difference(createdAt);

    if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h';
    } else {
      return '${difference.inDays}d';
    }
  }

  String getLocalizedTitle(
    String itemAdded,
    String spaceCreated,
    String welcome,
    String systemUpdate,
  ) {
    switch (type) {
      case NotificationType.itemAdded:
        return itemAdded;
      case NotificationType.spaceCreated:
        return spaceCreated;
      case NotificationType.welcome:
        return welcome;
      case NotificationType.systemUpdate:
        return systemUpdate;
    }
  }
}

enum NotificationType { itemAdded, spaceCreated, welcome, systemUpdate }
