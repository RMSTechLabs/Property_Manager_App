// // lib/src/core/performance/notification_performance.dart
// import 'dart:async';

// class NotificationPerformance {
//   static final Map<String, Stopwatch> _timers = {};
  
//   static void startTimer(String operation) {
//     _timers[operation] = Stopwatch()..start();
//   }
  
//   static Duration stopTimer(String operation) {
//     final timer = _timers[operation];
//     if (timer != null) {
//       timer.stop();
//       final duration = timer.elapsed;
//       _timers.remove(operation);
//       return duration;
//     }
//     return Duration.zero;
//   }
  
//   static Future<T> measureAsync<T>(
//     String operation,
//     Future<T> Function() function,
//   ) async {
//     startTimer(operation);
//     try {
//       final result = await function();
//       final duration = stopTimer(operation);
//       NotificationLogger.logInfo(
//         'Performance: $operation completed in ${duration.inMilliseconds}ms'
//       );
//       return result;
//     } catch (e) {
//       stopTimer(operation);
//       rethrow;
//     }
//   }
// }