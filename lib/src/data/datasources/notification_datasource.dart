// lib/src/data/datasources/notification_datasource.dart
import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:property_manager_app/src/core/constants/notification_constant.dart';
import 'package:property_manager_app/src/presentation/providers/notification_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/errors/exceptions.dart';
import '../models/notification_model.dart';

abstract class NotificationDataSource {
  Future<void> initialize();
  Future<String?> getFCMToken();
  Future<void> saveFCMToken(String token);
  Future<void> subscribeToTopic(String topic);
  Future<void> unsubscribeFromTopic(String topic);
  Future<List<NotificationModel>> getStoredNotifications();
  Future<void> storeNotification(NotificationModel notification);
  Future<void> markAsRead(String id);
  Future<void> deleteNotification(String id);
  Stream<NotificationModel> get notificationStream;
}

class NotificationDataSourceImpl implements NotificationDataSource {
  final FirebaseMessaging _firebaseMessaging;
  final FlutterLocalNotificationsPlugin _localNotifications;
  final SharedPreferences _prefs;
  final StreamController<NotificationModel> _notificationController;

  NotificationDataSourceImpl(
    this._firebaseMessaging,
    this._localNotifications,
    this._prefs,
  ) : _notificationController = StreamController<NotificationModel>.broadcast();

  @override
  Future<void> initialize() async {
    try {
      // Request permissions
      await _requestPermissions();
      
      // Initialize local notifications
      await _initializeLocalNotifications();
      
      // Setup Firebase messaging
      await _setupFirebaseMessaging();
      
      // Get and save FCM token
      final token = await _firebaseMessaging.getToken();
      //print('✅FCM Token: $token');
      if (token != null) {
        await saveFCMToken(token);
      }
      
      // Listen for token refresh
      _firebaseMessaging.onTokenRefresh.listen((token) {
        saveFCMToken(token);
      });
      
    } catch (e) {
      throw NotificationException('Failed to initialize notifications: $e');
    }
  }

  Future<void> _requestPermissions() async {
    if (Platform.isAndroid) {
      final status = await Permission.notification.request();
      if (status != PermissionStatus.granted) {
        throw NotificationException('Notification permission denied');
      }
    }
    
    final settings = await _firebaseMessaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
    );
    
    if (settings.authorizationStatus != AuthorizationStatus.authorized) {
      throw NotificationException('FCM permission denied');
    }
  }

  Future<void> _initializeLocalNotifications() async {
    const androidSettings = AndroidInitializationSettings('@drawable/ic_notification');
    const iosSettings = DarwinInitializationSettings(
      requestSoundPermission: true,
      requestBadgePermission: true,
      requestAlertPermission: true,
    );
    
    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );
    
    await _localNotifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );
    
    // Create notification channel for Android
    if (Platform.isAndroid) {
      await _createNotificationChannel();
    }
  }

  Future<void> _createNotificationChannel() async {
    const channel = AndroidNotificationChannel(
      NotificationConstants.channelId,
      NotificationConstants.channelName,
      description: NotificationConstants.channelDescription,
      importance: Importance.high,
      enableVibration: true,
      enableLights: true,
    );
    
    await _localNotifications
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);
  }

  Future<void> _setupFirebaseMessaging() async {
    // Handle foreground messages
    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);
    
    // Handle background messages
    FirebaseMessaging.onBackgroundMessage(_handleBackgroundMessage);
    
    // Handle notification taps when app is terminated
    final initialMessage = await _firebaseMessaging.getInitialMessage();
    if (initialMessage != null) {
      _handleMessageTap(initialMessage);
    }
    
    // Handle notification taps when app is in background
    FirebaseMessaging.onMessageOpenedApp.listen(_handleMessageTap);
  }

  Future<void> _handleForegroundMessage(RemoteMessage message) async {
    final notification = NotificationModel.fromRemoteMessage(message.data);
    
    // Store notification
    await storeNotification(notification);
    
    // Show local notification
    await _showLocalNotification(message);
    
    // Add to stream
    _notificationController.add(notification);
  }

  static Future<void> _handleBackgroundMessage(RemoteMessage message) async {
    // Handle background message processing
    //print('Background message: ${message.messageId}');
  }

  void _handleMessageTap(RemoteMessage message) {
    final notification = NotificationModel.fromRemoteMessage(message.data);
    _notificationController.add(notification);
  }

  void _onNotificationTapped(NotificationResponse response) {
    // Handle local notification tap
    if (response.payload != null) {
      final data = jsonDecode(response.payload!);
      final notification = NotificationModel.fromJson(data);
      _notificationController.add(notification);
    }
  }

  Future<void> _showLocalNotification(RemoteMessage message) async {
    const androidDetails = AndroidNotificationDetails(
      NotificationConstants.channelId,
      NotificationConstants.channelName,
      channelDescription: NotificationConstants.channelDescription,
      importance: Importance.high,
      priority: Priority.high,
      showWhen: true,
    );
    
    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );
    
    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );
    
    await _localNotifications.show(
      message.hashCode,
      message.notification?.title ?? 'Property Manager',
      message.notification?.body ?? 'You have a new notification',
      details,
      payload: jsonEncode(message.data),
    );
  }

  @override
  Future<String?> getFCMToken() async {
    try {
      return await _firebaseMessaging.getToken();
    } catch (e) {
      throw NotificationException('Failed to get FCM token: $e');
    }
  }

  @override
  Future<void> saveFCMToken(String token) async {
    try {
      await _prefs.setString(NotificationConstants.fcmTokenKey, token);
    } catch (e) {
      throw NotificationException('Failed to save FCM token: $e');
    }
  }

  @override
  Future<void> subscribeToTopic(String topic) async {
    try {
      await _firebaseMessaging.subscribeToTopic(topic);
    } catch (e) {
      throw NotificationException('Failed to subscribe to topic: $e');
    }
  }

  @override
  Future<void> unsubscribeFromTopic(String topic) async {
    try {
      await _firebaseMessaging.unsubscribeFromTopic(topic);
    } catch (e) {
      throw NotificationException('Failed to unsubscribe from topic: $e');
    }
  }

  @override
  Future<List<NotificationModel>> getStoredNotifications() async {
    try {
      final notifications = _prefs.getStringList('stored_notifications') ?? [];
      return notifications
          .map((json) => NotificationModel.fromJson(jsonDecode(json)))
          .toList();
    } catch (e) {
      throw NotificationException('Failed to get stored notifications: $e');
    }
  }

  @override
  Future<void> storeNotification(NotificationModel notification) async {
    try {
      final notifications = await getStoredNotifications();
      notifications.insert(0, notification);
      
      // Keep only last 50 notifications
      if (notifications.length > 50) {
        notifications.removeRange(50, notifications.length);
      }
      
      final jsonList = notifications.map((n) => jsonEncode(n.toJson())).toList();
      await _prefs.setStringList('stored_notifications', jsonList);
    } catch (e) {
      throw NotificationException('Failed to store notification: $e');
    }
  }

  @override
  Future<void> markAsRead(String id) async {
    try {
      final notifications = await getStoredNotifications();
      final index = notifications.indexWhere((n) => n.id == id);
      
      if (index != -1) {
        final updatedNotification = NotificationModel(
          id: notifications[index].id,
          title: notifications[index].title,
          body: notifications[index].body,
          type: notifications[index].type,
          data: notifications[index].data,
          createdAt: notifications[index].createdAt,
          isRead: true,
        );
        
        notifications[index] = updatedNotification;
        final jsonList = notifications.map((n) => jsonEncode(n.toJson())).toList();
        await _prefs.setStringList('stored_notifications', jsonList);
      }
    } catch (e) {
      throw NotificationException('Failed to mark notification as read: $e');
    }
  }

  @override
  Future<void> deleteNotification(String id) async {
    try {
      final notifications = await getStoredNotifications();
      notifications.removeWhere((n) => n.id == id);
      
      final jsonList = notifications.map((n) => jsonEncode(n.toJson())).toList();
      await _prefs.setStringList('stored_notifications', jsonList);
    } catch (e) {
      throw NotificationException('Failed to delete notification: $e');
    }
  }

  @override
  Stream<NotificationModel> get notificationStream => _notificationController.stream;
}

final notificationDataSourceProvider = Provider<NotificationDataSource>((ref) {
  final firebaseMessaging = ref.watch(firebaseMessagingProvider);
  final localNotifications = ref.watch(localNotificationsProvider);
  final sharedPreferences = ref.watch(sharedPreferencesProvider).value!;
  
  return NotificationDataSourceImpl(
    firebaseMessaging,
    localNotifications,
    sharedPreferences,
  );
});