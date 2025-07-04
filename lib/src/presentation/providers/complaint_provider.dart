// lib/src/presentation/screens/faq_screen/faq_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import 'package:property_manager_app/src/core/constants/api_constants.dart';
import 'package:property_manager_app/src/data/models/ticket_model.dart';
import 'package:property_manager_app/src/presentation/providers/dio_provider.dart';
import 'package:property_manager_app/src/presentation/providers/society_provider.dart';


// Future<http.StreamedResponse> addComplaints(
//       Map<String, dynamic> body, List<String> filePaths, WidgetRef ref) async {
//     try {
//       final response = await ApiConfig.postMultipartRequest(
//         'complaint',
//         'files',
//         ApiConfig.addComplaintApi,
//         body,
//         filePaths,
//         ref,
//         isPrivate: true,
//       );
//       return response;
//     } catch (error) {
//       throw Exception(error);
//     }
//   }


// final complaintProvider = FutureProvider.autoDispose<List<TicketModel>>((ref) async {
//   final dio = ref.read(dioProvider);
//   final selectedCommunity = ref.watch(selectedCommunityProvider);
//   try {
//     final response = await dio.get(
//         '${ApiConstants.getComplaintsEndpoint}/${selectedCommunity?.societyId}/${selectedCommunity?.apartmentId}',
//       );
//     if (response.statusCode == 200) {
//       final List<dynamic> data = response.data["data"];
//       if (data.isEmpty) {
//         return [];
//       }
//       print(data);
//       return data.map((json) => TicketModel.fromJson(json)).toList();
//     } else {
//       throw Exception('Server error: ${response.statusCode}');
//     }
//   } on DioException catch (e) {
//     throw Exception(e.response?.data?['message'] ?? 'Failed to load complaints');
//   }
// });

  

// complaint_provider.dart


class ComplaintNotifier extends AsyncNotifier<List<TicketModel>> {
  @override
  Future<List<TicketModel>> build() async {
    return _fetchComplaints();
  }

  Future<List<TicketModel>> _fetchComplaints() async {
    final dio = ref.read(dioProvider);
    final selectedCommunity = ref.read(selectedCommunityProvider);

    if (selectedCommunity == null) return [];

    try {
      final response = await dio.get(
        '${ApiConstants.getComplaintsEndpoint}/${selectedCommunity.societyId}/${selectedCommunity.apartmentId}',
      );
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data["data"];
        return data.map((json) => TicketModel.fromJson(json)).toList();
      } else {
        throw Exception('Server error: ${response.statusCode}');
      }
    } on DioException catch (e) {
      throw Exception(e.response?.data?['message'] ?? 'Failed to load complaints');
    }
  }

  Future<void> refreshComplaints() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => _fetchComplaints());
  }
}

final complaintProvider = AsyncNotifierProvider<ComplaintNotifier, List<TicketModel>>(
  ComplaintNotifier.new,
);

