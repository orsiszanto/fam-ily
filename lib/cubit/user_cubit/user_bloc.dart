import 'package:familyapp/cubit/user_cubit/user_state.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:familyapp/services/user_service.dart';

class UserBloc extends Cubit<UserState>  {

UserBloc(): super(NotAuthenticated());

void logIn(String email, String password){
  emit(AuthInProgress());
  UserService.logIn(email, password).then((userCredentials){
    emit(LoggedIn(userCredentials));
  }).catchError((error){
    if(error is FirebaseAuthException){
      emit(FailedAuth(error.message ?? "Unknown error occured"));
    }
  });
}

void signIn(String email, String password){
  emit(AuthInProgress());

  UserService.signUp(email, password).then((userCredentials){
    emit(RegisterSuccessful(userCredentials));
  }).catchError((error){
    if(error is FirebaseAuthException){
      emit(FailedAuth(error.message ?? "Unknown error occured"));
    }
  });
}

}
