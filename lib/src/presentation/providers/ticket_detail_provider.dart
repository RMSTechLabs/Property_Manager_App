import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:property_manager_app/src/data/models/ticket_detail_model.dart';
import 'package:property_manager_app/src/presentation/notifiers/ticket_detail_notifier.dart';



final ticketDetailProvider = AsyncNotifierProvider.family<TicketDetailNotifier, TicketDetailModel, String>(
  TicketDetailNotifier.new,
);
