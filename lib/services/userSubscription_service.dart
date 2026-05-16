import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

class UserSubscriptionService {
  static StreamSubscription? sub;
  static String? currentGroupId;

  static Future<void> init() async {
    final groupId = await getInitialGroupId();
    if (groupId != null && groupId.toString().isNotEmpty) {
      await FirebaseMessaging.instance.subscribeToTopic(groupId.toString());
    }
    startListening();
  }

  static Future<String?> getInitialGroupId() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return null;

    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .get();

    final groupId = doc.data()?['groupId'];

    currentGroupId = groupId;
    return groupId;
  }

  static void startListening() {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      stopListening();
      return;
    }

    sub?.cancel();

    sub = FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .snapshots()
        .listen((doc) async {
          if (!doc.exists || doc.data() == null) {
            return;
          }

          final newGroupId = doc.data()?['groupId'];

          if (newGroupId == null) {
            return;
          }

          if (newGroupId == currentGroupId) {
            return;
          }

          if (currentGroupId != null && currentGroupId != newGroupId) {
            await FirebaseMessaging.instance.unsubscribeFromTopic(
              currentGroupId!,
            );
          }

          currentGroupId = newGroupId;

          await FirebaseMessaging.instance.subscribeToTopic(newGroupId!);
        });
  }

  static void stopListening() async {
    sub?.cancel();
    sub = null;
    currentGroupId = null;
  }
}
