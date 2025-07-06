// lib/src/presentation/providers/notification_provider.dart
import 'dart:async';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:property_manager_app/src/domain/repositories/notification_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../data/repositories/notification_repository_impl.dart';
import '../../domain/entities/notification.dart';

class NotificationState {
  final List<NotificationEntity> notifications;
  final bool isLoading;
  final String? error;
  final String? fcmToken;

  const NotificationState({
    this.notifications = const [],
    this.isLoading = false,
    this.error,
    this.fcmToken,
  });

  NotificationState copyWith({
    List<NotificationEntity>? notifications,
    bool? isLoading,
    String? error,
    String? fcmToken,
  }) {
    return NotificationState(
      notifications: notifications ?? this.notifications,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      fcmToken: fcmToken ?? this.fcmToken,
    );
  }
}

class NotificationNotifier extends StateNotifier<NotificationState> {
  final NotificationRepository _repository;
  StreamSubscription<NotificationEntity>? _notificationSubscription;

  NotificationNotifier(this._repository) : super(const NotificationState()) {
    _initializeNotifications();
    _listenToNotifications();
  }

  Future<void> _initializeNotifications() async {
    state = state.copyWith(isLoading: true);

    final result = await _repository.initializeNotifications();
    
    result.fold(
      (failure) => state = state.copyWith(
        isLoading: false,
        error: failure.message,
      ),
      (_) async {
        await _loadNotifications();
        await _loadFCMToken();
        state = state.copyWith(isLoading: false);
      },
    );
  }

  Future<void> _loadNotifications() async {
    final result = await _repository.getNotifications();
    
    result.fold(
      (failure) => state = state.copyWith(error: failure.message),
      (notifications) => state = state.copyWith(notifications: notifications),
    );
  }

  Future<void> _loadFCMToken() async {
    final result = await _repository.getFCMToken();
    
    result.fold(
      (failure) => state = state.copyWith(error: failure.message),
      (token) => state = state.copyWith(fcmToken: token),
    );
  }

  void _listenToNotifications() {
    _notificationSubscription = _repository.notificationStream.listen(
      (notification) {
        final updatedNotifications = [notification, ...state.notifications];
        state = state.copyWith(notifications: updatedNotifications);
      },
    );
  }

  Future<void> markAsRead(String id) async {
    final result = await _repository.markNotificationAsRead(id);
    
    result.fold(
      (failure) => state = state.copyWith(error: failure.message),
      (_) => _loadNotifications(),
    );
  }

  Future<void> deleteNotification(String id) async {
    final result = await _repository.deleteNotification(id);
    
    result.fold(
      (failure) => state = state.copyWith(error: failure.message),
      (_) => _loadNotifications(),
    );
  }

  Future<void> subscribeToTopic(String topic) async {
    final result = await _repository.subscribeToTopic(topic);
    
    result.fold(
      (failure) => state = state.copyWith(error: failure.message),
      (_) {}, // Success
    );
  }

  Future<void> unsubscribeFromTopic(String topic) async {
    final result = await _repository.unsubscribeFromTopic(topic);
    
    result.fold(
      (failure) => state = state.copyWith(error: failure.message),
      (_) {}, // Success
    );
  }

  @override
  void dispose() {
    _notificationSubscription?.cancel();
    super.dispose();
  }
}

final notificationProvider = StateNotifierProvider<NotificationNotifier, NotificationState>((ref) {
  final repository = ref.watch(notificationRepositoryProvider);
  return NotificationNotifier(repository);
});

final firebaseMessagingProvider = Provider<FirebaseMessaging>((ref) {
  return FirebaseMessaging.instance;
});

final localNotificationsProvider = Provider<FlutterLocalNotificationsPlugin>((ref) {
  return FlutterLocalNotificationsPlugin();
});

final sharedPreferencesProvider = FutureProvider<SharedPreferences>((ref) async {
  return await SharedPreferences.getInstance();
});

