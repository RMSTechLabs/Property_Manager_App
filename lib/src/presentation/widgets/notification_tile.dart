// lib/src/presentation/widgets/notification_tile.dart
import 'package:flutter/material.dart';
import '../../domain/entities/notification.dart';

class NotificationTile extends StatelessWidget {
  final NotificationEntity notification;
  final VoidCallback onTap;
  final VoidCallback onDismiss;

  const NotificationTile({
    super.key,
    required this.notification,
    required this.onTap,
    required this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: Key(notification.id),
      direction: DismissDirection.endToStart,
      onDismissed: (_) => onDismiss(),
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        color: Colors.red,
        child: const Icon(
          Icons.delete,
          color: Colors.white,
        ),
      ),
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        elevation: notification.isRead ? 1 : 3,
        child: ListTile(
          leading: CircleAvatar(
            backgroundColor: _getNotificationColor(),
            child: Icon(
              _getNotificationIcon(),
              color: Colors.white,
            ),
          ),
          title: Text(
            notification.title,
            style: TextStyle(
              fontWeight: notification.isRead ? FontWeight.normal : FontWeight.bold,
            ),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                notification.body,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Text(
                _formatDate(notification.createdAt),
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
          trailing: notification.isRead
              ? null
              : const Icon(
                  Icons.circle,
                  color: Colors.blue,
                  size: 12,
                ),
          onTap: onTap,
        ),
      ),
    );
  }

  Color _getNotificationColor() {
    switch (notification.type) {
      case 'property_update':
        return Colors.blue;
      case 'maintenance_request':
        return Colors.orange;
      case 'payment_due':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  IconData _getNotificationIcon() {
    switch (notification.type) {
      case 'property_update':
        return Icons.home;
      case 'maintenance_request':
        return Icons.build;
      case 'payment_due':
        return Icons.payment;
      default:
        return Icons.notifications;
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }
}