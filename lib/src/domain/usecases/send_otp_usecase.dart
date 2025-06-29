// lib/src/domain/usecases/login_usecase.dart
import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:property_manager_app/src/data/models/send_otp_response_model.dart';

import '../../core/errors/failures.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../repositories/auth_repository.dart';

class SendOtpUseCase {
  final AuthRepository repository;

  SendOtpUseCase(this.repository);

  Future<Either<Failure, SendOtpResponseModel>> call(String email) {
    return repository.sendOtp(email);
  }
}

final sendOtpUseCaseProvider = Provider<SendOtpUseCase>((ref) {
  final repository = ref.watch(authRepositoryProvider);
  return SendOtpUseCase(repository);
});
