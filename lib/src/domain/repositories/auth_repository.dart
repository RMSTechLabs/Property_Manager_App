// lib/src/domain/repositories/auth_repository.dart
import 'package:dartz/dartz.dart';
import 'package:property_manager_app/src/data/models/send_otp_response_model.dart';
import '../../core/errors/failures.dart';
import '../entities/user.dart';

abstract class AuthRepository {
  Future<Either<Failure, (String, String, User)>> login(
    String email,
    String password,
  );
  Future<Either<Failure, String>> refreshToken(String refreshToken);
  Future<Either<Failure, void>> logout(String email);
  Future<Either<Failure, User>> getCurrentUser();
  Future<Either<Failure, SendOtpResponseModel>> sendOtp(String email);
  Future<Either<Failure, bool>> validateOtp(String otp, String otpIdentifier);
}
