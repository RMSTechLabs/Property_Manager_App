// // lib/src/core/logging/notification_logger.dart
// import 'package:logger/logger.dart';

// class NotificationLogger {
//   static final Logger _logger = Logger(
//     printer: PrettyPrinter(
//       methodCount: 3,
//       errorMethodCount: 8,
//       lineLength: 120,
//       colors: true,
//       printEmojis: true,
//       printTime: true,
//     ),
//   );
  
//   static void logInfo(String message, [dynamic data]) {
//     _logger.i('🔔 $message', data);
//   }
  
//   static void logWarning(String message, [dynamic data]) {
//     _logger.w('⚠️ $message', data);
//   }
  
//   static void logError(String message, [dynamic error, StackTrace? stackTrace]) {
//     _logger.e('❌ $message', error, stackTrace);
//   }
  
//   static void logNotificationReceived(Map<String, dynamic> data) {
//     _logger.i('📨 Notification received', data);
//   }
  
//   static void logNotificationProcessed(String id, String type) {
//     _logger.i('✅ Notification processed: $id ($type)');
//   }
  
//   static void logTokenRefresh(String newToken) {
//     _logger.i('🔄 FCM Token refreshed: ${newToken.substring(0, 20)}...');
//   }
// }