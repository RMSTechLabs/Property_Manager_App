// lib/src/domain/repositories/notification_repository.dart
import 'package:dartz/dartz.dart';
import '../../core/errors/failures.dart';
import '../entities/notification.dart';

abstract class NotificationRepository {
  Future<Either<Failure, void>> initializeNotifications();
  Future<Either<Failure, String?>> getFCMToken();
  Future<Either<Failure, void>> saveFCMToken(String token);
  Future<Either<Failure, void>> subscribeToTopic(String topic);
  Future<Either<Failure, void>> unsubscribeFromTopic(String topic);
  Future<Either<Failure, List<NotificationEntity>>> getNotifications();
  Future<Either<Failure, void>> markNotificationAsRead(String id);
  Future<Either<Failure, void>> deleteNotification(String id);
  Stream<NotificationEntity> get notificationStream;
}