// lib/src/core/constants/notification_constants.dart
class NotificationConstants {
  static const String channelId = 'property_manager_channel';
  static const String channelName = 'Property Manager Notifications';
  static const String channelDescription = 'Notifications for property management updates';
  
  // Notification types
  static const String typePropertyUpdate = 'property_update';
  static const String typeMaintenanceRequest = 'maintenance_request';
  static const String typePaymentDue = 'payment_due';
  static const String typeGeneralAlert = 'general_alert';
  static const String updateTicketStatus = 'update_ticket_status';
  
  // Storage keys
  static const String fcmTokenKey = 'fcm_token';
  static const String notificationSettingsKey = 'notification_settings';
}