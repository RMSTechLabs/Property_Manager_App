// lib/src/domain/repositories/auth_repository.dart
import 'package:dartz/dartz.dart';
import 'package:property_manager_app/src/data/models/society_state_model.dart';

import '../../core/errors/failures.dart';

abstract class MasterRepository {
  Future<Either<Failure, SocietyStateModel>> getCommunityForResident(
    String email,
  );
}
