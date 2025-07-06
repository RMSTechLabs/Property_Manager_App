// lib/src/presentation/screens/notifications/notifications_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:property_manager_app/src/presentation/providers/notification_provider.dart';
import 'package:property_manager_app/src/presentation/widgets/notification_tile.dart';


class NotificationsScreen extends ConsumerWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notificationState = ref.watch(notificationProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        actions: [
          if (notificationState.notifications.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.mark_email_read),
              onPressed: () => _markAllAsRead(ref),
            ),
        ],
      ),
      body: notificationState.isLoading
          ? const Center(child: CircularProgressIndicator())
          : notificationState.notifications.isEmpty
              ? const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.notifications_none,
                        size: 64,
                        color: Colors.grey,
                      ),
                      SizedBox(height: 16),
                      Text(
                        'No notifications yet',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  itemCount: notificationState.notifications.length,
                  itemBuilder: (context, index) {
                    final notification = notificationState.notifications[index];
                    return NotificationTile(
                      notification: notification,
                      onTap: () => _handleNotificationTap(ref, notification.id),
                      onDismiss: () => _deleteNotification(ref, notification.id),
                    );
                  },
                ),
    );
  }

  void _handleNotificationTap(WidgetRef ref, String id) {
    ref.read(notificationProvider.notifier).markAsRead(id);
    // Navigate to relevant screen based on notification type
  }

  void _deleteNotification(WidgetRef ref, String id) {
    ref.read(notificationProvider.notifier).deleteNotification(id);
  }

  void _markAllAsRead(WidgetRef ref) {
    final notifications = ref.read(notificationProvider).notifications;
    for (final notification in notifications) {
      if (!notification.isRead) {
        ref.read(notificationProvider.notifier).markAsRead(notification.id);
      }
    }
  }
}