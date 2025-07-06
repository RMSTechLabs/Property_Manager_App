// lib/src/domain/usecases/initialize_notifications_usecase.dart
import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/errors/failures.dart';
import '../../data/repositories/notification_repository_impl.dart';
import '../repositories/notification_repository.dart';

class InitializeNotificationsUseCase {
  final NotificationRepository repository;

  InitializeNotificationsUseCase(this.repository);

  Future<Either<Failure, void>> call() {
    return repository.initializeNotifications();
  }
}

final initializeNotificationsUseCaseProvider = Provider<InitializeNotificationsUseCase>((ref) {
  final repository = ref.watch(notificationRepositoryProvider);
  return InitializeNotificationsUseCase(repository);
});