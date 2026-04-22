import 'package:flutter/material.dart';
import 'package:familyapp/pages/auth/registration_page.dart';
import 'package:familyapp/pages/auth/login_page.dart';
import 'package:familyapp/design/app_button.dart';
import 'package:familyapp/design/app_bar.dart';
import 'package:familyapp/design/spacing.dart';

class AuthPage extends StatefulWidget {
  const AuthPage({super.key});

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarStyles.auth(title: 'FAM-ILY'),
      body: wholeBody(context),
    );
  }

  Center wholeBody(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('Organise everything'),
          SizedBox(height: 26),
          Padding(
            padding: const EdgeInsets.all(AppSpacing.s),
            child: AppButton(
              text: 'Sign up',
              type: ButtonType.primary,
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => RegScreen()),
                );
              },
            ),
          ),
          SizedBox(height: AppSpacing.m),
          AppButton(
            text: 'Log in',
            type: ButtonType.primary,
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => LoginScreen()),
              );
            },
          ),
        ],
      ),
    );
  }
}
