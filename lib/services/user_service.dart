import 'package:firebase_auth/firebase_auth.dart';

class UserService  {

static Future<UserCredential> signUp (String email, String password){
  return FirebaseAuth.instance.createUserWithEmailAndPassword(email: email, password: password);
}

static Future<UserCredential> logIn (String email, String password){
  return FirebaseAuth.instance.signInWithEmailAndPassword(email: email, password: password);
}

}