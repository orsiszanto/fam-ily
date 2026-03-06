import 'dart:math';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';


class UserService {
 /* static Future<User> signUp(String email, String password) async {
    final cred = await FirebaseAuth.instance.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    return cred.user!;*/


  static Future<User> signUpWithGroup(String email, String password, String name, bool createNewGroup, String?groupCode) async {

    if(!createNewGroup){
      final code = (groupCode ?? '').trim();
      if(code.isEmpty){
        throw Exception("Szükséges a család-kód!");
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
        'name' : "$name család"
      });

      groupId = groupReference.id;
    }else{
      final query = await FirebaseFirestore.instance.collection('group').where('groupCode', isEqualTo: groupCode).limit(1).get();

      if(query.docs.isEmpty){
        throw Exception("Ez a kód nem létezik!");
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
}
