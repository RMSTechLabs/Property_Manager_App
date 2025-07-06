import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:property_manager_app/src/core/constants/api_constants.dart';
import 'package:property_manager_app/src/core/dio/dio_client.dart';
import 'package:property_manager_app/src/data/models/notice_model.dart';
import 'package:property_manager_app/src/data/services/notice/notice_service.dart';
import 'package:property_manager_app/src/presentation/providers/dio_provider.dart';

class NoticeService extends INoticeService {
  final DioClient _dioClient;

  NoticeService(this._dioClient);

  @override
  Future<NoticeModel> fetchNoticeById(String id) async {
    try {
      final res = await _dioClient.get('${ApiConstants.getNoticeEndpoint}/$id');

      if (res.statusCode != 200) {
        throw Exception('Failed to load notice details');
      }

      return NoticeModel.fromJson(res.data["data"]);
    } on DioException catch (e) {
      // DioException gives detailed control
      if (e.response != null) {
        final statusCode = e.response?.statusCode;
        final errorMessage =
            e.response?.data['message'] ??
            e.response?.statusMessage ??
            'Something went wrong (Status Code: $statusCode)';
        throw Exception(errorMessage);
      } else {
        // No server response (network issues, timeout, etc.)
        throw Exception('Network error. Please check your connection.');
      }
    } catch (e) {
      throw Exception('Unexpected error: ${e.toString()}');
    }
  }
}

final noticeServiceProvider = Provider<NoticeService>((ref) {
  final dioClient = ref.watch(dioClientProvider);
  return NoticeService(dioClient);
});
