// lib/src/domain/repositories/auth_repository.dart
import 'package:dio/dio.dart';
import 'package:property_manager_app/src/data/models/ticket_detail_model.dart';

abstract class IComplaintService {
  Future<TicketDetailModel> fetchTicketById(String id);
  Future<Response> sendComment(
    Map<String, dynamic> body,
    List<String> filePaths,
  );
  Future<Response> createComplaint(
    Map<String, dynamic> body,
    List<String> filePaths,
  );
  Future<Response> getCommentListByComplaintId(String complaintId);
  Future<Response> getAllCategoryList(String societyId);
  Future<Response> getNoticeBySocietyAndAreaAndApartment({
    required String societyId,
    required String areaId,
    required String apartmentId,
  });
}
