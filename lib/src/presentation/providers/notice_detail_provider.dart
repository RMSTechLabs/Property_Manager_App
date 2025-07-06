import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:property_manager_app/src/data/models/notice_model.dart';
import 'package:property_manager_app/src/presentation/notifiers/norice_detail_notifier.dart';

final noticeDetailProvider =
    AsyncNotifierProvider.family<NoticeDetailNotifier, NoticeModel, String>(
      NoticeDetailNotifier.new,
    );
