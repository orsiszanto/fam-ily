import 'package:familyapp/cubit/user_cubit/user_bloc.dart';
import 'package:familyapp/pages/auth/auth_page.dart';
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
  Widget build(BuildContext ctx) {
    return BlocProvider(
      create: (ctx) => UserBloc(),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        home: const AuthPage()),
    );
  }
}
