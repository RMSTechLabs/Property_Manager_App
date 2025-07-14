
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:property_manager_app/src/data/models/user_profile_response_model.dart';
import 'package:property_manager_app/src/domain/usecases/get_user_profile_usecase.dart';

final userProfileProvider = FutureProvider.family<UserProfileDataModel, String>((ref, userId) async {
  final getUserProfileUseCase = ref.read(getUserProfileUseCaseProvider);
  final result = await getUserProfileUseCase(userId);
  
  return result.fold(
    (failure) => throw Exception(failure.message),
    (profile) => profile,
  );
});