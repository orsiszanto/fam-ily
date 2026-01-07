import 'package:firebase_auth/firebase_auth.dart';

class UserState {}

class NotAuthenticated extends UserState {}

class AuthInProgress extends UserState {}

class RegisterSuccessful extends UserState {
  User user;

  RegisterSuccessful(this.user);
}

class LoggedIn extends UserState {
  User user;

  LoggedIn(this.user);
}

class FailedAuth extends UserState {
  String errorMessage;

  FailedAuth(this.errorMessage);
}
