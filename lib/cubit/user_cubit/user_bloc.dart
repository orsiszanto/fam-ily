import 'package:familyapp/cubit/user_cubit/user_state.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:familyapp/services/user_service.dart';

String? currentGroup;

class UserBloc extends Cubit<UserState> {
  UserBloc() : super(AuthInProgress()) {
    _init();
  }

  void _init() {
    FirebaseAuth.instance.authStateChanges().listen((user) async {
      if (user == null) {
        currentGroup = null;
        emit(NotAuthenticated());
      } else {
        currentGroup = await UserService.getGroupIdByUserId(user.uid);
        emit(LoggedIn(user));
      }
    });
  }

  void logIn(String email, String password) async {
    emit(AuthInProgress());
    try {
      final user = await UserService.logIn(email, password);
      currentGroup = await UserService.getGroupIdByUserId(user.uid);
      emit(LoggedIn(user));
    } catch (error) {
      if (error is FirebaseAuthException) {
        emit(FailedAuth(error.message ?? "Unknown error occured"));
      } else {
        emit(FailedAuth(error.toString()));
      }
    }
  }

  void signUpWithGroup(
    String email,
    String password,
    String name,
    bool createNewGroup,
    String? groupCode,
    bool isParent,
  ) {
    emit(AuthInProgress());

    UserService.signUpWithGroup(
          email,
          password,
          name,
          createNewGroup,
          groupCode,
          isParent,
        )
        .then((user) {
          emit(RegisterSuccessful(user));
        })
        .catchError((error) {
          if (error is FirebaseAuthException) {
            emit(FailedAuth((error.message ?? "Unknown error occured")));
          } else {
            emit(FailedAuth(error.toString()));
          }
        });
  }

  void loadUserInfo() async {
    emit(UserInfoLoading());
    try {
      final userinfo = await UserService.loadUserInfo();
      emit(UserInfoLoaded(userinfo));
    } catch (error) {
      emit(UserError(error.toString()));
    }
  }

  void updateEmail(String newEmail, String currentPassword) async {
    emit(UserInfoLoading());
    try {
      await UserService.updateEmail(newEmail, currentPassword);
      final userInfo = await UserService.loadUserInfo();
      emit(UserInfoUpdated(userInfo));
    } catch (error) {
      emit(UserError(error.toString()));
    }
  }

  void updateName(String newName) async {
    emit(UserInfoLoading());
    try {
      await UserService.updateName(newName);
      final userInfo = await UserService.loadUserInfo();
      emit(UserInfoUpdated(userInfo));
    } catch (error) {
      emit(UserError(error.toString()));
    }
  }

  void updatePassword(String newPassword, String currentPassword) async {
    emit(UserInfoLoading());
    try {
      await UserService.updatePassword(newPassword, currentPassword);
      final userInfo = await UserService.loadUserInfo();
      emit(UserInfoUpdated(userInfo));
    } catch (error) {
      emit(UserError(error.toString()));
    }
  }

  void deleteProfile(String currentPassword) async {
    emit(AuthInProgress());
    try {
      await UserService.deleteCurrentUser(currentPassword);
      currentGroup = null;
      emit(NotAuthenticated());
    } catch (error) {
      emit(UserError(error.toString()));
    }
  }

  void signOut() {
    FirebaseAuth.instance.signOut();
    emit(NotAuthenticated());
  }
}
