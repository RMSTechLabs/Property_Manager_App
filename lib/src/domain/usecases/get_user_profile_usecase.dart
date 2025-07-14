// lib/src/domain/usecases/get_user_profile_usecase.dart
import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/errors/failures.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../data/models/user_profile_response_model.dart';
import '../repositories/auth_repository.dart';

class GetUserProfileUseCase {
  final AuthRepository repository;

  GetUserProfileUseCase(this.repository);

  Future<Either<Failure, UserProfileDataModel>> call(String userId) {
    return repository.getUserProfile(userId);
  }
}

final getUserProfileUseCaseProvider = Provider<GetUserProfileUseCase>((ref) {
  final repository = ref.watch(authRepositoryProvider);
  return GetUserProfileUseCase(repository);
});