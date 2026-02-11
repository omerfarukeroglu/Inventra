import 'package:flutter/material.dart';

class Item {
  final String id;
  final String name;
  final String? description;
  final String spaceId;
  final String spaceName;
  final String location;
  final int quantity;
  final String? notes;
  final IconData icon;
  final DateTime createdAt;
  final DateTime? updatedAt;

  Item({
    required this.id,
    required this.name,
    this.description,
    required this.spaceId,
    required this.spaceName,
    required this.location,
    this.quantity = 1,
    this.notes,
    required this.icon,
    DateTime? createdAt,
    this.updatedAt,
  }) : createdAt = createdAt ?? DateTime.now();

  Item copyWith({
    String? id,
    String? name,
    String? description,
    String? spaceId,
    String? spaceName,
    String? location,
    int? quantity,
    String? notes,
    IconData? icon,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Item(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      spaceId: spaceId ?? this.spaceId,
      spaceName: spaceName ?? this.spaceName,
      location: location ?? this.location,
      quantity: quantity ?? this.quantity,
      notes: notes ?? this.notes,
      icon: icon ?? this.icon,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

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

  // Get localized title based on notification type
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

enum NotificationType {
  itemAdded,
  spaceCreated,
  welcome,
  systemUpdate,
}
