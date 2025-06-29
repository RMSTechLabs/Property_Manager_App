// lib/src/domain/usecases/login_usecase.dart
import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/errors/failures.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../repositories/auth_repository.dart';

class ValidateOtpUseCase {
  final AuthRepository repository;

  ValidateOtpUseCase(this.repository);

  Future<Either<Failure, bool>> call(String otp,String otpIdentifier) {
    return repository.validateOtp(otp,otpIdentifier);
  }
}

final validateOtpUseCaseProvider = Provider<ValidateOtpUseCase>((ref) {
  final repository = ref.watch(authRepositoryProvider);
  return ValidateOtpUseCase(repository);
});
