import 'package:flutter/material.dart';
import '../models/space.dart';
import '../models/item.dart';
import '../core/theme/app_colors.dart';

class MockData {
  static List<Space> spaces = [
    Space(
      id: 'INV-2024-001',
      name: 'Office Box 1',
      location: 'Study Room',
      type: SpaceType.box,
      itemCount: 42,
      qrCode: 'INV-2024-001',
      icon: Icons.inventory_2_outlined,
      iconColor: AppColors.cyan,
      isActive: true,
    ),
    Space(
      id: 'INV-2024-002',
      name: 'Kitchen Drawer',
      location: 'Kitchen',
      type: SpaceType.drawer,
      itemCount: 12,
      qrCode: 'INV-2024-002',
      icon: Icons.kitchen_outlined,
      iconColor: AppColors.orange,
      isActive: true,
    ),
    Space(
      id: 'INV-2024-003',
      name: 'Garage Shelf',
      location: 'Garage',
      type: SpaceType.shelf,
      itemCount: 28,
      qrCode: 'INV-2024-003',
      icon: Icons.garage_outlined,
      iconColor: AppColors.purple,
      isActive: true,
    ),
    Space(
      id: 'INV-2024-004',
      name: 'Winter Bin',
      location: 'Attic',
      type: SpaceType.box,
      itemCount: 23,
      qrCode: 'INV-2024-004',
      icon: Icons.person_outline,
      iconColor: AppColors.teal,
      isActive: true,
    ),
    Space(
      id: 'INV-2024-005',
      name: 'Archive',
      location: 'Basement',
      type: SpaceType.box,
      itemCount: 0,
      qrCode: 'INV-2024-005',
      icon: Icons.folder_outlined,
      iconColor: AppColors.lightTextSecondary,
      isActive: false,
    ),
  ];

  static List<Item> items = [
    Item(
      id: 'ITEM-001',
      name: 'USB-C Cable',
      description: '2m length',
      spaceId: 'INV-2024-001',
      spaceName: 'Office Box 1',
      location: 'Study Room',
      quantity: 2,
      icon: Icons.cable,
    ),
    Item(
      id: 'ITEM-002',
      name: 'Stapler',
      description: 'Red Swingline',
      spaceId: 'INV-2024-001',
      spaceName: 'Office Box 1',
      location: 'Study Room',
      quantity: 1,
      icon: Icons.content_cut,
    ),
    Item(
      id: 'ITEM-003',
      name: 'Notebooks',
      description: 'Moleskine Pack',
      spaceId: 'INV-2024-001',
      spaceName: 'Office Box 1',
      location: 'Study Room',
      quantity: 3,
      icon: Icons.book_outlined,
    ),
    Item(
      id: 'ITEM-004',
      name: 'Headphones',
      description: 'Backup pair',
      spaceId: 'INV-2024-001',
      spaceName: 'Office Box 1',
      location: 'Study Room',
      quantity: 1,
      icon: Icons.headphones,
    ),
    Item(
      id: 'ITEM-005',
      name: 'SSD Drive',
      description: '1TB Samsung T7',
      spaceId: 'INV-2024-001',
      spaceName: 'Office Box 1',
      location: 'Study Room',
      quantity: 1,
      icon: Icons.storage,
    ),
    Item(
      id: 'ITEM-006',
      name: 'HDMI Cable (2m)',
      description: 'High-speed 4K compatible cable, 2 meters length. Gold plated connectors.',
      spaceId: 'INV-2024-006',
      spaceName: 'HDMI Cables Box',
      location: 'Living Room - TV Stand Drawer',
      quantity: 1,
      icon: Icons.cable,
    ),
    Item(
      id: 'ITEM-007',
      name: 'USB-C to HDMI Adapter',
      description: '',
      spaceId: 'INV-2024-007',
      spaceName: 'Desk Drawer',
      location: 'Study Room',
      quantity: 1,
      icon: Icons.settings_input_hdmi,
    ),
    Item(
      id: 'ITEM-008',
      name: 'Generic HDMI Extender',
      description: '',
      spaceId: 'INV-2024-008',
      spaceName: 'Utility Box',
      location: 'Garage',
      quantity: 1,
      icon: Icons.cable,
    ),
    Item(
      id: 'ITEM-009',
      name: 'Wireless Mouse',
      description: 'Logitech MX Master 3',
      spaceId: 'INV-2024-001',
      spaceName: 'Office Box 1',
      location: 'Study Room',
      quantity: 1,
      icon: Icons.mouse,
    ),
  ];

  static List<NotificationItem> notifications = [
    NotificationItem(
      id: 'NOTIF-001',
      title: 'Item Added',
      message: "Vintage Lamp added to 'Basement'",
      type: NotificationType.itemAdded,
      createdAt: DateTime.now().subtract(const Duration(minutes: 2)),
      isRead: false,
      icon: Icons.inventory_2_outlined,
      iconBgColor: AppColors.teal,
    ),
    NotificationItem(
      id: 'NOTIF-002',
      title: 'New Space Created',
      message: "You successfully created 'Garage'",
      type: NotificationType.spaceCreated,
      createdAt: DateTime.now().subtract(const Duration(hours: 1)),
      isRead: false,
      icon: Icons.folder_outlined,
      iconBgColor: AppColors.orange,
    ),
    NotificationItem(
      id: 'NOTIF-003',
      title: 'Welcome to INVENTRA',
      message: 'Start by scanning your first item',
      type: NotificationType.welcome,
      createdAt: DateTime.now().subtract(const Duration(days: 1)),
      isRead: true,
      icon: Icons.waving_hand,
      iconBgColor: AppColors.purple,
    ),
    NotificationItem(
      id: 'NOTIF-004',
      title: 'System Update',
      message: 'INVENTRA v2.1 is now live',
      type: NotificationType.systemUpdate,
      createdAt: DateTime.now().subtract(const Duration(days: 2)),
      isRead: true,
      icon: Icons.check_box_outlined,
      iconBgColor: AppColors.lightTextSecondary,
    ),
  ];

  static List<Item> getItemsForSpace(String spaceId) {
    return items.where((item) => item.spaceId == spaceId).toList();
  }

  static List<Item> searchItems(String query) {
    if (query.isEmpty) return [];
    final lowerQuery = query.toLowerCase();
    return items.where((item) {
      return item.name.toLowerCase().contains(lowerQuery) ||
          (item.description?.toLowerCase().contains(lowerQuery) ?? false) ||
          item.spaceName.toLowerCase().contains(lowerQuery);
    }).toList();
  }

  static List<Space> searchSpaces(String query) {
    if (query.isEmpty) return [];
    final lowerQuery = query.toLowerCase();
    return spaces.where((space) {
      return space.name.toLowerCase().contains(lowerQuery) ||
          space.location.toLowerCase().contains(lowerQuery);
    }).toList();
  }
}
