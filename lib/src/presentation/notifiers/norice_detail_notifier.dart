// lib/src/presentation/screens/ticket_detail/ticket_detail_notifier.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:property_manager_app/src/data/models/notice_model.dart';
import 'package:property_manager_app/src/data/services/notice/notice_service_impl.dart';
// assume this handles Dio


class NoticeDetailNotifier extends FamilyAsyncNotifier<NoticeModel, String> {
  late final NoticeService _noticeService;

  @override
  Future<NoticeModel> build(String noticeId) async {
    _noticeService = ref.watch(noticeServiceProvider);
    return await _noticeService.fetchNoticeById(noticeId);
  }
}
