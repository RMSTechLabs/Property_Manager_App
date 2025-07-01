// lib/src/data/repositories/auth_repository_impl.dart
import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:property_manager_app/src/data/datasources/master_remote_datasource.dart';
import 'package:property_manager_app/src/data/models/society_state_model.dart';
import 'package:property_manager_app/src/domain/repositories/master_respository.dart';

import '../../core/errors/exceptions.dart';
import '../../core/errors/failures.dart';

class MasterRepositoryImpl implements MasterRepository {
  final MasterRemoteDataSource remoteDataSource;

  MasterRepositoryImpl(this.remoteDataSource);

 
  @override
  Future<Either<Failure, List<SocietyStateModel>>> getCommunityForResident(String email) async {
    try {
      final communityResponse = await remoteDataSource.getCommunityForResident(email);
      return Right(communityResponse);
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Unexpected error occurred'));
    }
  }

  
}

final masterRepositoryProvider = Provider<MasterRepository>((ref) {
  final remoteDataSource = ref.watch(masterRemoteDataSourceProvider);
  return MasterRepositoryImpl(remoteDataSource);
});
