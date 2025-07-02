import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:property_manager_app/src/data/models/community_item_model.dart';
import 'package:property_manager_app/src/data/models/society_state_model.dart';
import 'package:property_manager_app/src/domain/usecases/master/get_community_for_resident_usecase.dart';
import 'package:property_manager_app/src/presentation/providers/auth_state_provider.dart';
import 'package:property_manager_app/src/presentation/screens/home_screen.dart';

// class SocietyStateNotifier extends StateNotifier<SocietyStateModel> {
//   final Ref _ref;
//   final GetCommunityForResidentUsecase _communityForResidentUsecase;

//   SocietyStateNotifier(this._ref, this._communityForResidentUsecase)
//       : super(SocietyStateModel(status: false));

//   /// Public method to initialize loading based on authenticated user
//   Future<void> initialize() async {
//     final authState = _ref.read(authStateProvider);

//     // Ensure auth is ready
//     if (!authState.isInitialized || !authState.isOtpVerified) {
//       state = state.copyWith(
//         status: false,
//         error: 'User not authenticated or OTP not verified',
//       );
//       return;
//     }

//     final email = authState.email ?? authState.user?.email;

//     if (email == null) {
//       state = state.copyWith(
//         status: false,
//         error: 'Email not found in authentication state',
//       );
//       return;
//     }

//     await _loadSocietyList(email);
//   }

//   /// Internal method to load society info using provided email
//   Future<void> _loadSocietyList(String email) async {
//     final result = await _communityForResidentUsecase(email);
//     print('Loading society for email: $result');
//     await result.fold(
//       (failure) async {
//         state = state.copyWith(
//           status: false,
//           error: failure.message,
//         );
//       },
//       (data) async {
//         state = state.copyWith(
//           status: true,
//           apartmentId: data.apartmentId,
//           areaId: data.areaId,
//           societyId: data.societyId,
//           block: data.block,
//           flat: data.flat,
//           id: data.id,
//           residentType: data.residentType,
//           society: data.society,
//           error: null,
//         );
//       },
//     );
//   }
// }

// final societyStateProvider =
//     StateNotifierProvider<SocietyStateNotifier, SocietyStateModel>((ref) {
//   return SocietyStateNotifier(
//     ref,
//     ref.read(masterUseCaseProvider),
//   );
// });

class SocietyListState {
  final bool isLoading;
  final String? error;
  final List<SocietyStateModel> societies;
  final String? ownerOrTenantName;
  const SocietyListState({
    this.isLoading = false,
    this.error,
    this.ownerOrTenantName,
    this.societies = const [],
  });

  SocietyListState copyWith({
    bool? isLoading,
    String? error,
    List<SocietyStateModel>? societies,
    String? ownerOrTenantName,
  }) {
    return SocietyListState(
      isLoading: isLoading ?? this.isLoading,
      error: error,
      societies: societies ?? this.societies,
      ownerOrTenantName: ownerOrTenantName ?? this.ownerOrTenantName,
    );
  }
}

class SocietyStateNotifier extends StateNotifier<SocietyListState> {
  final Ref _ref;
  final GetCommunityForResidentUsecase _communityForResidentUsecase;

  SocietyStateNotifier(this._ref, this._communityForResidentUsecase)
    : super(const SocietyListState());

  Future<void> initialize() async {
    final authState = _ref.read(authStateProvider);

    if (!authState.isInitialized || !authState.isOtpVerified) {
      state = state.copyWith(
        error: 'User not authenticated or OTP not verified',
        isLoading: false,
      );
      return;
    }
    final name = authState.user?.name ?? "Unknown";
    final email = authState.email ?? authState.user?.email;
    if (email == null) {
      state = state.copyWith(
        error: 'Email not found in authentication state',
        isLoading: false,
      );
      return;
    }

    await _loadSocietyList(email,name);
  }

  Future<void> _loadSocietyList(String email,String name) async {
    state = state.copyWith(isLoading: true, error: null);
    final result = await _communityForResidentUsecase(email);
    await result.fold(
      (failure) async {
        state = state.copyWith(isLoading: false, error: failure.message);
      },
      (dataList) async {
        state = state.copyWith(
          isLoading: false,
          societies: dataList,
          ownerOrTenantName: name,
          error: null,
        );
      },
    );
  }
}

final societyStateProvider =
    StateNotifierProvider<SocietyStateNotifier, SocietyListState>((ref) {
      return SocietyStateNotifier(ref, ref.read(masterUseCaseProvider));
    });

final selectedSocietyIdProvider = StateProvider<String?>((ref) => null);
final selectedCommunityProvider = StateProvider<CommunityItem?>((ref) => null);
