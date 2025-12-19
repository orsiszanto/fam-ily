import 'package:firebase_auth/firebase_auth.dart';

class UserState{

}

class NotAuthenticated extends UserState{

}

class AuthInProgress extends UserState{

}

class RegisterSuccessful extends UserState{
  UserCredential userCredential;

  RegisterSuccessful(this.userCredential);
}

class LoggedIn extends UserState{
  UserCredential userCredential;

  LoggedIn(this.userCredential);
}

class FailedAuth extends UserState{
  String errorMessage;

  FailedAuth(this.errorMessage);
}