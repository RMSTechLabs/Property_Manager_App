// lib/src/presentation/screens/ticket_detail/ticket_detail_notifier.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:property_manager_app/src/data/models/ticket_detail_model.dart';
import 'package:property_manager_app/src/data/services/complaint/complaint_service.dart';
// assume this handles Dio


class TicketDetailNotifier extends FamilyAsyncNotifier<TicketDetailModel, String> {
  late final ComplaintService _ticketService;

  @override
  Future<TicketDetailModel> build(String ticketId) async {
    _ticketService = ref.watch(complaintServiceProvider);
    return await _ticketService.fetchTicketById(ticketId);
  }

  Future<void> sendComment(String content, String visibility) async {
    final newComment = await _ticketService.sendComment(arg, content, visibility);
    if (state case AsyncData(:final value)) {
      final updated = value.copyWith(
        comments: [...value.comments, newComment],
        responseCount: value.responseCount + 1,
      );
      state = AsyncData(updated);
    }
  }
}
