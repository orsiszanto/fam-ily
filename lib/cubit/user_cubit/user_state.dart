import 'package:firebase_auth/firebase_auth.dart';
import 'package:familyapp/model/user_model.dart' as appUser;

class UserState {}

class NotAuthenticated extends UserState {}

class AuthInProgress extends UserState {}

class UserInfoLoading extends UserState {}

class UserInfoLoaded extends UserState {
  appUser.User user;

  UserInfoLoaded(this.user);
}

class UserInfoUpdated extends UserState {
  appUser.User user;

  UserInfoUpdated(this.user);
}

class RegisterSuccessful extends UserState {
  User user;
  RegisterSuccessful(this.user);
}

class LoggedIn extends UserState {
  User user;
  LoggedIn(this.user);
}

class FailedAuth extends UserState {
  final String errorMessage;
  FailedAuth(this.errorMessage);
}

class UserError extends UserState {
  final String message;
  UserError(this.message);
}
