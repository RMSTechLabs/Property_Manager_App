import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:property_manager_app/src/core/constants/api_constants.dart';
import 'package:property_manager_app/src/core/dio/dio_client.dart';
import 'package:property_manager_app/src/data/models/ticket_detail_model.dart';
import 'package:property_manager_app/src/data/services/complaint/complaint_service_impl.dart';
import 'package:property_manager_app/src/presentation/providers/dio_provider.dart';

class ComplaintService extends IComplaintService {
  final DioClient _dioClient;

  ComplaintService(this._dioClient);

  @override
  Future<TicketDetailModel> fetchTicketById(String id) async {
    final res = await _dioClient.get(
      '${ApiConstants.getComplaintEndpoint}/$id',
    );
    if (res.statusCode != 200) {
      throw Exception('Failed to load ticket details');
    }
    return TicketDetailModel.fromJson(res.data);
  }

  @override
  Future<CommentModel> sendComment(
    String id,
    String content,
    String visibility,
  ) async {
    final res = await _dioClient.post(
      '${ApiConstants.getComplaintEndpoint}/$id/comments',
      data: {'comment': content, 'visibility': visibility},
    );

    return CommentModel.fromJson(res.data); // server returns created comment
  }
}

final complaintServiceProvider = Provider<ComplaintService>((ref) {
  final dioClient = ref.watch(dioClientProvider);
  return ComplaintService(dioClient);
});
