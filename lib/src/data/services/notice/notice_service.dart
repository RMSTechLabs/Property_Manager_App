// lib/src/domain/repositories/auth_repository.dart
import 'package:property_manager_app/src/data/models/notice_model.dart';

abstract class INoticeService {
  Future<NoticeModel> fetchNoticeById(String id);
}
