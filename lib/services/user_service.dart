import 'dart:math';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';


class UserService {
  static Future<User> signUpWithGroup(String email, String password, String name, bool createNewGroup, String?groupCode, bool isParent) async {

    if(!createNewGroup){
      final code = (groupCode ?? '').trim();
      if(code.isEmpty){
        throw Exception("You have to enter your family code");
      }
      groupCode = code.toUpperCase();
    }

    final cred = await FirebaseAuth.instance.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    final user = cred.user!;

    String groupId;
    late String finalGroupCode;

    try{if(createNewGroup){
      finalGroupCode = _generateGroupCode();

      final groupReference = FirebaseFirestore.instance.collection('group').doc();
      await groupReference.set({
        'createdBy': user.uid,
        'createdAt': FieldValue.serverTimestamp(),
        'groupCode' : finalGroupCode,
        'name' : "$name's Family",
      });

      groupId = groupReference.id;
    }else{
      final query = await FirebaseFirestore.instance.collection('group').where('groupCode', isEqualTo: groupCode).limit(1).get();

      if(query.docs.isEmpty){
        throw Exception("This family code does not exist");
      }

      final doc = query.docs.first;
      groupId = doc.id;
      finalGroupCode = (doc.data()['groupCode'] as String?) ?? groupCode!;

    }
    
    await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
      'email' : email,
      'groupCode' : finalGroupCode,
      'groupId' : groupId,
      'name' : name,
      'isParent' : isParent,
    });

      await FirebaseFirestore.instance.collection('group').doc(groupId).collection('members').doc(user.uid).set({
        'userid' : user.uid,
      });
    return user;
  }catch(e){
      try {
        await user.delete();
      }catch(_){}
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
  
  static Future<String> getGroupIdByUserId(String uid) async{
    final doc = await FirebaseFirestore.instance.collection('users').doc(uid).get();
    final data = doc.data()!;
    final groupId = data['groupId'];

    if(groupId == null || groupId.toString().isEmpty){
      throw Exception("GroupId not found");
    }

    return groupId.toString();
  }
}
