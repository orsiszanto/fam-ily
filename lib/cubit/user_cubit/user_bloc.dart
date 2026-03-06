import 'package:familyapp/cubit/user_cubit/user_state.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:familyapp/services/user_service.dart';

class UserBloc extends Cubit<UserState> {
  UserBloc() : super(AuthInProgress()) {
    _init();
  }

  void _init() {
    FirebaseAuth.instance.authStateChanges().listen((user) {
      if (user == null) {
        emit(NotAuthenticated());
      } else {
        emit(LoggedIn(user));
      }
    });
  }

  void logIn(String email, String password) {
    emit(AuthInProgress());
    UserService.logIn(email, password)
        .catchError((error){
          if (error is FirebaseAuthException) {
            emit(FailedAuth(error.message ?? "Unknown error occured"));
          }else{
            emit(FailedAuth(error.toString()));
          }
        });
  }

  /*void signUp(String email, String password) {
    emit(AuthInProgress());

    UserService.signUp(email, password)
        .then((user) {
          emit(RegisterSuccessful(user));
        })
        .catchError((error) {
          if (error is FirebaseAuthException) {
            emit(FailedAuth(error.message ?? "Unknown error occured"));
          }else{
            emit(FailedAuth(error.toString()));
          }
        });
  }*/

  void signUpWithGroup(String email, String password, String name, bool createNewGroup, String?groupCode){
    emit(AuthInProgress());

    UserService.signUpWithGroup(email, password, name, createNewGroup, groupCode)
    .then((user){
      emit(RegisterSuccessful(user));
    }).catchError((error){
      if( error is FirebaseAuthException){
        emit(FailedAuth((error.message ?? "Unknown error occured"))
        );
      }else{
        emit(FailedAuth(error.toString()));
      }
    });
  }

  void signOut() {
    FirebaseAuth.instance.signOut();
    emit(NotAuthenticated());
  }
}
