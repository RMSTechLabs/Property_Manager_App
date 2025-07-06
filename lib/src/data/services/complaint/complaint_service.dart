import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:property_manager_app/src/core/constants/api_constants.dart';
import 'package:property_manager_app/src/core/dio/dio_client.dart';
import 'package:property_manager_app/src/data/models/category_model.dart';
import 'package:property_manager_app/src/data/models/ticket_detail_model.dart';
import 'package:property_manager_app/src/data/services/complaint/complaint_service_impl.dart';
import 'package:property_manager_app/src/presentation/providers/dio_provider.dart';
import 'package:http_parser/http_parser.dart'; // Required for contentType

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
  Future<Response> createComplaint(
    Map<String, dynamic> body,
    List<String> filePaths,
  ) async {
    final formData = FormData();

    // ✅ Send complaint JSON with correct Content-Type: application/json
    formData.files.add(
      MapEntry(
        'complaint',
        MultipartFile.fromString(
          jsonEncode(body),
          filename: 'complaint.json',
          contentType: MediaType('application', 'json'), // ⬅️ FIXED!
        ),
      ),
    );

    // ✅ Attach each file with field name 'files'
    for (final path in filePaths) {
      formData.files.add(MapEntry('files', await MultipartFile.fromFile(path)));
    }

    final response = await _dioClient.post(
      ApiConstants.addComplaintEndpoint,
      data: formData,
      options: Options(headers: {'Content-Type': 'multipart/form-data'}),
    );

    print('Complaint created: ${response.data}');
    return response;
  }

  @override
  Future<Response> sendComment(
    Map<String, dynamic> body,
    List<String> filePaths,
  ) async {
    final formData = FormData();

    // Add the comment body as a JSON string part
    formData.files.add(
      MapEntry(
        'comment',
        MultipartFile.fromString(jsonEncode(body), filename: 'blob.json'),
      ),
    );

    // Add files (e.g., images) without setting contentType explicitly
    for (final path in filePaths) {
      formData.files.add(
        MapEntry('imageFile', await MultipartFile.fromFile(path)),
      );
    }

    final response = await _dioClient.post(
      ApiConstants.getComplaintEndpoint,
      data: formData,
      options: Options(headers: {'Content-Type': 'multipart/form-data'}),
    );

    return response;
  }

  @override
  Future<List<CategoryModel>> getAllCategoryList(String societyId) async {
    try {
      final response = await _dioClient.get(
        '${ApiConstants.getAllCategoryApi}/$societyId',
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to load categories');
      }

      final List<dynamic> dataList = response.data["data"];

      // Assuming the response is a List of category objects
      return dataList.map((json) => CategoryModel.fromJson(json)).toList();
    } catch (error) {
      throw Exception('Failed to fetch categories: $error');
    }
  }

  @override
  Future<Response> getCommentListByComplaintId(String complaintId) async {
    try {
      final response = await _dioClient.get(
        '${ApiConstants.getCommentListByComplaintIdEndpoint}/$complaintId',
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            // 'Authorization': 'Bearer YOUR_TOKEN', // optional
          },
        ),
      );
      return response;
    } catch (error) {
      throw Exception('Failed to fetch comments: $error');
    }
  }

  @override
  Future<Response> getNoticeBySocietyAndAreaAndApartment({
    required String societyId,
    required String areaId,
    required String apartmentId,
  }) async {
    try {
      final response = await _dioClient.get(
        ApiConstants.getNoticesEndpoint,
        queryParameters: {
          'societyId': societyId,
          'areaId': areaId,
          'apartmentId': apartmentId,
        },
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            // 'Authorization': 'Bearer YOUR_TOKEN', // If not using an interceptor
          },
        ),
      );
      return response;
    } catch (error) {
      throw Exception('Failed to fetch notices: $error');
    }
  }
}

final complaintServiceProvider = Provider<ComplaintService>((ref) {
  final dioClient = ref.watch(dioClientProvider);
  return ComplaintService(dioClient);
});
