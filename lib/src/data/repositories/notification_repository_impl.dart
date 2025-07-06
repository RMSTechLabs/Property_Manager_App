// lib/src/data/repositories/notification_repository_impl.dart
import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/errors/exceptions.dart';
import '../../core/errors/failures.dart';
import '../../domain/entities/notification.dart';
import '../../domain/repositories/notification_repository.dart';
import '../datasources/notification_datasource.dart';

class NotificationRepositoryImpl implements NotificationRepository {
  final NotificationDataSource dataSource;

  NotificationRepositoryImpl(this.dataSource);

  @override
  Future<Either<Failure, void>> initializeNotifications() async {
    try {
      await dataSource.initialize();
      return const Right(null);
    } on NotificationException catch (e) {
      return Left(NotificationFailure(e.message));
    } catch (e) {
      return Left(NotificationFailure('Unexpected error: $e'));
    }
  }

  @override
  Future<Either<Failure, String?>> getFCMToken() async {
    try {
      final token = await dataSource.getFCMToken();
      return Right(token);
    } on NotificationException catch (e) {
      return Left(NotificationFailure(e.message));
    } catch (e) {
      return Left(NotificationFailure('Unexpected error: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> saveFCMToken(String token) async {
    try {
      await dataSource.saveFCMToken(token);
      return const Right(null);
    } on NotificationException catch (e) {
      return Left(NotificationFailure(e.message));
    } catch (e) {
      return Left(NotificationFailure('Unexpected error: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> subscribeToTopic(String topic) async {
    try {
      await dataSource.subscribeToTopic(topic);
      return const Right(null);
    } on NotificationException catch (e) {
      return Left(NotificationFailure(e.message));
    } catch (e) {
      return Left(NotificationFailure('Unexpected error: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> unsubscribeFromTopic(String topic) async {
    try {
      await dataSource.unsubscribeFromTopic(topic);
      return const Right(null);
    } on NotificationException catch (e) {
      return Left(NotificationFailure(e.message));
    } catch (e) {
      return Left(NotificationFailure('Unexpected error: $e'));
    }
  }

  @override
  Future<Either<Failure, List<NotificationEntity>>> getNotifications() async {
    try {
      final notifications = await dataSource.getStoredNotifications();
      return Right(notifications);
    } on NotificationException catch (e) {
      return Left(NotificationFailure(e.message));
    } catch (e) {
      return Left(NotificationFailure('Unexpected error: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> markNotificationAsRead(String id) async {
    try {
      await dataSource.markAsRead(id);
      return const Right(null);
    } on NotificationException catch (e) {
      return Left(NotificationFailure(e.message));
    } catch (e) {
      return Left(NotificationFailure('Unexpected error: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> deleteNotification(String id) async {
    try {
      await dataSource.deleteNotification(id);
      return const Right(null);
    } on NotificationException catch (e) {
      return Left(NotificationFailure(e.message));
    } catch (e) {
      return Left(NotificationFailure('Unexpected error: $e'));
    }
  }

  @override
  Stream<NotificationEntity> get notificationStream => 
      dataSource.notificationStream.cast<NotificationEntity>();
}

final notificationRepositoryProvider = Provider<NotificationRepository>((ref) {
  final dataSource = ref.watch(notificationDataSourceProvider);
  return NotificationRepositoryImpl(dataSource);
});