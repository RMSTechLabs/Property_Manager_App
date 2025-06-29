// lib/src/data/datasources/auth_remote_datasource.dart
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logger/logger.dart';
import 'package:property_manager_app/src/data/models/society_state_model.dart';

import '../../core/constants/api_constants.dart';
import '../../core/errors/exceptions.dart';
import '../../presentation/providers/dio_provider.dart';

abstract class MasterRemoteDataSource {
  Future<SocietyStateModel> getCommunityForResident(String email);
}

class MasterRemoteDataSourceImpl implements MasterRemoteDataSource {
  final Dio dio;
  var logger = Logger(printer: PrettyPrinter());

  MasterRemoteDataSourceImpl(this.dio);

  @override
  Future<SocietyStateModel> getCommunityForResident(String email) async {
    try {
      final response = await dio.get(
        '${ApiConstants.getCommunityForResidentEndpoint}?ownerEmail=$email',
      );
      print(response.data);
      if (response.statusCode == 200) {
        if (response.data["success"] == false) {
          throw AuthException("Check Your EmailId");
        }
        return SocietyStateModel.fromJson(response.data);
      } else {
        throw ServerException('Server Error!');
      }
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        throw NetworkException('Connection timeout');
      } else {
        final message =
            e.response?.data?['message'] ??
            e.response?.data?['error'] ??
            'Server error';
        throw ServerException(message);
      }
    } catch (e) {
      if (e is NetworkException || e is ServerException) {
        rethrow; // Re-throw our custom exceptions
      }
      throw ServerException('Unexpected error occurred');
    }
  }
}

final masterRemoteDataSourceProvider = Provider<MasterRemoteDataSource>((ref) {
  final dio = ref.read(dioProvider);
  return MasterRemoteDataSourceImpl(dio);
});
