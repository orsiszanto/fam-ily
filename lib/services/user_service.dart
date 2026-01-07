import 'package:firebase_auth/firebase_auth.dart';

class UserService {
  static Future<User> signUp(String email, String password) async {
    final cred = await FirebaseAuth.instance.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    return cred.user!;
  }

  static Future<User> logIn(String email, String password) async {
    final cred = await FirebaseAuth.instance.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    return cred.user!;
  }
}
