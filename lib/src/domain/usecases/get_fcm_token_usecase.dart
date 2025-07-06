// lib/src/domain/usecases/get_fcm_token_usecase.dart
import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/errors/failures.dart';
import '../../data/repositories/notification_repository_impl.dart';
import '../repositories/notification_repository.dart';

class GetFCMTokenUseCase {
  final NotificationRepository repository;

  GetFCMTokenUseCase(this.repository);

  Future<Either<Failure, String?>> call() {
    return repository.getFCMToken();
  }
}

final getFCMTokenUseCaseProvider = Provider<GetFCMTokenUseCase>((ref) {
  final repository = ref.watch(notificationRepositoryProvider);
  return GetFCMTokenUseCase(repository);
});