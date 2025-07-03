// lib/src/domain/repositories/auth_repository.dart
import 'package:property_manager_app/src/data/models/ticket_detail_model.dart';

abstract class IComplaintService {
  Future<TicketDetailModel> fetchTicketById(String id);
  Future<dynamic> sendComment(String id, String content, String visibility);
}
