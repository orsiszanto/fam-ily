import 'package:familyapp/cubit/user_cubit/user_bloc.dart';
import 'package:familyapp/cubit/user_cubit/user_state.dart';
import 'package:familyapp/firebase_options.dart';
import 'package:familyapp/pages/auth/auth_page.dart';
import 'package:familyapp/pages/dashboard/main_page.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}


class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => UserBloc(),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        home: BlocBuilder<UserBloc, UserState>(
          builder: (context, state) {
            if (state is AuthInProgress) {
              return const Scaffold(
                body: Center(child: CircularProgressIndicator()),
              );
            }

            if (state is LoggedIn) {
              return const Dashboard();
            }

            return const AuthPage();
          },
        ),
      ),
    );
  }
}
