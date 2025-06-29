// lib/src/domain/usecases/login_usecase.dart
import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:property_manager_app/src/core/errors/failures.dart';
import 'package:property_manager_app/src/data/models/send_otp_response_model.dart';
import 'package:property_manager_app/src/data/models/society_state_model.dart';
import 'package:property_manager_app/src/data/repositories/master_repository_impl.dart';
import 'package:property_manager_app/src/domain/repositories/master_respository.dart';




class GetCommunityForResidentUsecase {
  final MasterRepository repository;

  GetCommunityForResidentUsecase(this.repository);

  Future<Either<Failure, SocietyStateModel>> call(String email) {
    return repository.getCommunityForResident(email);
  }
}

final masterUseCaseProvider = Provider<GetCommunityForResidentUsecase>((ref) {
  final repository = ref.watch(masterRepositoryProvider);
  return GetCommunityForResidentUsecase(repository);
});
