import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/providers/app_state_provider.dart';
import '../../../l10n/app_localizations.dart';
import '../../../models/item.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor:
          isDark ? AppColors.darkBackground : AppColors.lightBackground,
      appBar: AppBar(
        backgroundColor:
            isDark ? AppColors.darkBackground : AppColors.lightBackground,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color:
                isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          l10n.notifications,
          style: TextStyle(
            color:
                isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: Consumer<AppStateProvider>(
        builder: (context, appState, child) {
          if (appState.notifications.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.notifications_off_outlined,
                    size: 64,
                    color:
                        isDark
                            ? AppColors.darkTextSecondary
                            : AppColors.lightTextSecondary,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    l10n.noNotificationsYet,
                    style: TextStyle(
                      color:
                          isDark
                              ? AppColors.darkTextSecondary
                              : AppColors.lightTextSecondary,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: appState.notifications.length,
            itemBuilder: (context, index) {
              final notification = appState.notifications[index];
              return Dismissible(
                key: Key(notification.id),
                direction: DismissDirection.endToStart,
                onDismissed: (direction) {
                  appState.deleteNotification(notification.id);
                },
                background: Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.only(right: 20),
                  decoration: BoxDecoration(
                    color: AppColors.error,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Icon(
                    Icons.delete_outline,
                    color: Colors.white,
                    size: 28,
                  ),
                ),
                child: _NotificationCard(
                  notification: notification,
                  onTap: () {
                    appState.markNotificationAsRead(notification.id);
                  },
                  isDark: isDark,
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class _NotificationCard extends StatelessWidget {
  final NotificationItem notification;
  final VoidCallback onTap;
  final bool isDark;

  const _NotificationCard({
    required this.notification,
    required this.onTap,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    // Get localized title based on notification type
    String localizedTitle;
    String localizedMessage;

    switch (notification.type) {
      case NotificationType.itemAdded:
        localizedTitle = l10n.notificationItemAdded;
        // Extract item name and space name from original message
        // Format: "Vintage Lamp added to 'Basement'"
        final parts = notification.message.split(" added to '");
        if (parts.length == 2) {
          final itemName = parts[0];
          final spaceName = parts[1].replaceAll("'", "");
          localizedMessage = l10n.notificationItemAddedMessage(itemName, spaceName);
        } else {
          localizedMessage = notification.message;
        }
        break;
      case NotificationType.spaceCreated:
        localizedTitle = l10n.notificationSpaceCreated;
        // Extract space name from original message
        // Format: "You successfully created 'Garage'"
        final match = RegExp(r"'([^']+)'").firstMatch(notification.message);
        if (match != null) {
          localizedMessage = l10n.notificationSpaceCreatedMessage(match.group(1)!);
        } else {
          localizedMessage = notification.message;
        }
        break;
      case NotificationType.welcome:
        localizedTitle = l10n.notificationWelcome;
        localizedMessage = l10n.notificationWelcomeMessage;
        break;
      case NotificationType.systemUpdate:
        localizedTitle = l10n.notificationSystemUpdate;
        localizedMessage = l10n.notificationSystemUpdateMessage;
        break;
    }

    // Get localized time ago
    final timeAgoText = '${notification.timeAgo} ${l10n.ago}';

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkCard : AppColors.lightCard,
          borderRadius: BorderRadius.circular(16),
          boxShadow:
              isDark
                  ? null
                  : [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: notification.iconBgColor.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                notification.icon,
                color: notification.iconBgColor,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    localizedTitle,
                    style: TextStyle(
                      color:
                          isDark
                              ? AppColors.darkTextPrimary
                              : AppColors.lightTextPrimary,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    localizedMessage,
                    style: TextStyle(
                      color:
                          isDark
                              ? AppColors.darkTextSecondary
                              : AppColors.lightTextSecondary,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    timeAgoText,
                    style: TextStyle(
                      color:
                          isDark
                              ? AppColors.darkTextSecondary
                              : AppColors.lightTextSecondary,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            if (!notification.isRead)
              Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  color:
                      notification.type == NotificationType.itemAdded
                          ? AppColors.cyan
                          : AppColors.orange,
                  shape: BoxShape.circle,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
