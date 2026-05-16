import 'dart:math';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:familyapp/model/user_model.dart' as appUser;
import 'package:firebase_messaging/firebase_messaging.dart';

class UserService {
  static bool _isStrongPassword(String password) {
    return password.length >= 8 &&
        RegExp(r'[A-Z]').hasMatch(password) &&
        RegExp(r'\d').hasMatch(password);
  }

  static Future<User> signUpWithGroup(
    String email,
    String password,
    String name,
    bool createNewGroup,
    String? groupCode,
    bool isParent,
  ) async {
    final trimmedPassword = password.trim();

    if (trimmedPassword.isEmpty) {
      throw Exception("Password cannot be empty");
    }

    if (!_isStrongPassword(trimmedPassword)) {
      throw Exception(
        "Password must be at least 8 characters, include an uppercase letter and a number",
      );
    }

    if (!createNewGroup) {
      final code = (groupCode ?? '').trim();
      if (code.isEmpty) {
        throw Exception("You have to enter your family code");
      }
      groupCode = code.toUpperCase();
    }

    final cred = await FirebaseAuth.instance.createUserWithEmailAndPassword(
      email: email,
      password: trimmedPassword,
    );
    final user = cred.user!;

    String groupId;
    late String finalGroupCode;

    try {
      if (createNewGroup) {
        finalGroupCode = _generateGroupCode();

        final groupReference = FirebaseFirestore.instance
            .collection('group')
            .doc();
        await groupReference.set({
          'createdBy': user.uid,
          'createdAt': FieldValue.serverTimestamp(),
          'groupCode': finalGroupCode,
          'name': "$name's Family",
        });

        groupId = groupReference.id;
      } else {
        final query = await FirebaseFirestore.instance
            .collection('group')
            .where('groupCode', isEqualTo: groupCode)
            .limit(1)
            .get();

        if (query.docs.isEmpty) {
          throw Exception("This family code does not exist");
        }

        final doc = query.docs.first;
        groupId = doc.id;
        finalGroupCode = (doc.data()['groupCode'] as String?) ?? groupCode!;
      }

      await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
        'email': email,
        'groupCode': finalGroupCode,
        'groupId': groupId,
        'name': name,
        'isParent': isParent,
      });

      await FirebaseFirestore.instance
          .collection('group')
          .doc(groupId)
          .collection('members')
          .doc(user.uid)
          .set({'userid': user.uid});

      await FirebaseMessaging.instance.subscribeToTopic(groupId);
      return user;
    } catch (e) {
      try {
        await user.delete();
      } catch (_) {}
      rethrow;
    }
  }

  static String _generateGroupCode() {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final r = Random.secure();
    return List.generate(6, (_) => chars[r.nextInt(chars.length)]).join();
  }

  static Future<User> logIn(String email, String password) async {
    final cred = await FirebaseAuth.instance.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    return cred.user!;
  }

  static Future<String> getGroupIdByUserId(String uid) async {
    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .get();
    final data = doc.data()!;
    final groupId = data['groupId'];

    if (groupId == null || groupId.toString().isEmpty) {
      throw Exception("GroupId not found");
    }

    return groupId.toString();
  }

  static Future<appUser.User> loadUserInfo() async {
    final currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser == null) {
      throw Exception("User not logged in");
    }

    final uid = currentUser.uid;
    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .get();
    if (!doc.exists || doc.data() == null) {
      throw Exception("user doc not found");
    }

    final data = doc.data()!;

    final email = data['email'] ?? '';
    final groupCode = data['groupCode'] ?? '';
    final groupId = data['groupId'] ?? '';
    final isParent = data['isParent'] ?? false;
    final name = data['name'] ?? '';

    return appUser.User(email, groupCode, groupId, isParent, name);
  }

  static Future<void> updateName(String newName) async {
    final trimmedName = newName.trim();

    if (trimmedName.isEmpty) {
      throw Exception("Name cannot be empty");
    }

    final currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser == null) {
      throw Exception("User not logged in");
    }

    await FirebaseFirestore.instance
        .collection('users')
        .doc(currentUser.uid)
        .update({'name': trimmedName});
  }

  static Future<void> updateEmail(
    String newEmail,
    String currentPassword,
  ) async {
    final trimmedEmail = newEmail.trim();

    if (trimmedEmail.isEmpty) {
      throw Exception("Email cannot be empty");
    }

    final currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser == null) {
      throw Exception("User not logged in");
    }
    await reauthenticateUser(currentPassword);

    await currentUser.verifyBeforeUpdateEmail(trimmedEmail);

    await FirebaseFirestore.instance
        .collection('users')
        .doc(currentUser.uid)
        .update({'email': currentUser.email});
  }

  static Future<void> updatePassword(
    String newPassword,
    String currentPassword,
  ) async {
    final trimmedPassword = newPassword.trim();

    if (trimmedPassword.isEmpty) {
      throw Exception("Password cannot be empty");
    }

    final currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser == null) {
      throw Exception("User not logged in");
    }

    await reauthenticateUser(currentPassword);
    await currentUser.updatePassword(newPassword);
  }

  static Future<void> reauthenticateUser(String currentPassword) async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      throw Exception("User not logged in");
    }

    final email = currentUser.email;
    if (email == null || email.isEmpty) {
      throw Exception("No email found");
    }

    final credential = EmailAuthProvider.credential(
      email: email,
      password: currentPassword,
    );

    await currentUser.reauthenticateWithCredential(credential);
  }

  static Future<void> deleteCurrentUser(String currentPassword) async {
    final auth = FirebaseAuth.instance;
    final firestore = FirebaseFirestore.instance;
    final currentUser = auth.currentUser;

    if (currentUser == null) {
      throw Exception("No authenticated user found");
    }

    final uid = currentUser.uid;
    final userDocReference = firestore.collection('users').doc(uid);
    final userDoc = await userDocReference.get();

    if (!userDoc.exists || userDoc.data() == null) {
      throw Exception("User doc not found");
    }

    final data = userDoc.data();
    final groupId = data?['groupId'];

    if (groupId == null || groupId.toString().isEmpty) {
      throw Exception("groupId not found");
    }

    await reauthenticateUser(currentPassword);

    final batch = firestore.batch();

    final memberDocReference = firestore
        .collection('group')
        .doc(groupId)
        .collection('members')
        .doc(uid);

    batch.delete(memberDocReference);
    batch.delete(userDocReference);

    await batch.commit();

    final members = await firestore
        .collection('group')
        .doc(groupId)
        .collection('members')
        .limit(1)
        .get();

    if (members.docs.isEmpty) {
      await _deleteGroupCompletely(groupId);
    }

    await currentUser.delete();
  }

  static Future<void> _deleteGroupCompletely(String groupId) async {
    final firestore = FirebaseFirestore.instance;
    final groupReference = firestore.collection('group').doc(groupId);

    await _deleteCollection(groupReference.collection('members'));
    await _deleteCollection(groupReference.collection('calendarEvents'));
    await _deleteCollection(groupReference.collection('contacts'));
    await _deleteCollection(groupReference.collection('notes'));
    await _deleteTodoListWithItems(groupReference);

    await groupReference.delete();
  }

  static Future<void> _deleteCollection(CollectionReference collection) async {
    final snapshot = await collection.get();

    for (var doc in snapshot.docs) {
      await doc.reference.delete();
    }
  }

  static Future<void> _deleteTodoListWithItems(
    DocumentReference groupReference,
  ) async {
    final todoListSnapshot = await groupReference.collection('todoLists').get();
    for (var todoListDoc in todoListSnapshot.docs) {
      await _deleteCollection(todoListDoc.reference.collection('todoItems'));
      await todoListDoc.reference.delete();
    }
  }
}
