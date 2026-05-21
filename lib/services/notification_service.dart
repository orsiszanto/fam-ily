import 'dart:convert';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:familyapp/cubit/note_cubit/note_bloc.dart';
import 'package:familyapp/pages/functions/notes/notes_page.dart';
import 'package:familyapp/services/note_service.dart';

class NotificationService {
  NotificationService._internal();

  factory NotificationService() => _instance;

  static final NotificationService _instance = NotificationService._internal();
  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();
  static Map<String, dynamic>? _pendingNotificationTap;
  static bool _pendingNotificationRetryScheduled = false;

  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  bool _isInitialized = false;

  static final AndroidNotificationChannel _androidChannel =
      AndroidNotificationChannel(
        'high_importance_channel',
        'High Importance Notifications',
        description: 'Used to show notifications while the app is open.',
        importance: Importance.high,
      );

  Future<void> initFCM() async {
    if (_isInitialized) {
      return;
    }
    _isInitialized = true;

    await _firebaseMessaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    if (!kIsWeb) {
      final androidInitializationSettings = AndroidInitializationSettings(
        '@mipmap/ic_launcher',
      );

      final initializationSettings = InitializationSettings(
        android: androidInitializationSettings,
      );

      await _localNotificationsPlugin.initialize(
        initializationSettings,
        onDidReceiveNotificationResponse: _handleLocalNotificationTap,
      );

      await _localNotificationsPlugin
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >()
          ?.createNotificationChannel(_androidChannel);

      await _localNotificationsPlugin
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >()
          ?.requestNotificationsPermission();

      await _firebaseMessaging.setForegroundNotificationPresentationOptions(
        alert: true,
        badge: true,
        sound: true,
      );
    }

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      _handleNotificationTap(message.data);
    });

    final initialMessage = await _firebaseMessaging.getInitialMessage();
    if (initialMessage != null) {
      _handleNotificationTap(initialMessage.data);
    }

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {

      final notification = message.notification;
      final android = notification?.android;

      if (notification != null && android != null && !kIsWeb) {
        _localNotificationsPlugin.show(
          notification.hashCode,
          notification.title,
          notification.body,
          const NotificationDetails(
            android: AndroidNotificationDetails(
              'high_importance_channel',
              'High Importance Notifications',
              channelDescription:
                  'Used to show notifications while the app is open.',
              importance: Importance.high,
              priority: Priority.high,
              icon: '@mipmap/ic_launcher',
            ),
          ),
          payload: message.data.isNotEmpty ? jsonEncode(message.data) : null,
        );
      }
    });
  }

  void _handleLocalNotificationTap(NotificationResponse response) {
    final payload = response.payload;
    if (payload == null || payload.isEmpty) {
      return;
    }

    try {
      final decoded = jsonDecode(payload);
      if (decoded is Map<String, dynamic>) {
        _handleNotificationTap(decoded);
      }
    } catch (_) {
      // Ignore malformed payloads.
    }
  }

  void _handleNotificationTap(Map<String, dynamic> data) {
    final target = data['target']?.toString();
    if (target != 'notes') {
      return;
    }

    final groupId = data['groupId']?.toString();
    if (groupId == null || groupId.isEmpty) {
      return;
    }

    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      return;
    }

    final navigator = navigatorKey.currentState;
    if (navigator == null) {
      _pendingNotificationTap = data;
      _schedulePendingNotificationRetry();
      return;
    }

    _pendingNotificationTap = null;

    navigator.push(
      MaterialPageRoute(
        builder: (_) => BlocProvider(
          create: (_) => NoteBloc(NoteService()),
          child: Notes(groupId: groupId, createdBy: currentUser.uid),
        ),
      ),
    );
  }

  void _schedulePendingNotificationRetry() {
    if (_pendingNotificationRetryScheduled) {
      return;
    }

    _pendingNotificationRetryScheduled = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _pendingNotificationRetryScheduled = false;

      final pendingTap = _pendingNotificationTap;
      if (pendingTap == null) {
        return;
      }

      _pendingNotificationTap = null;
      _handleNotificationTap(pendingTap);
    });
  }
}
