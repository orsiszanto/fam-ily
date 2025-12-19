import 'package:flutter/material.dart';
import 'package:familyapp/pages/auth/registration_page.dart';
import 'package:familyapp/pages/auth/login_page.dart';


class AuthPage extends StatefulWidget {
  const AuthPage({super.key});

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(appBar: appBar(), body: wholeBody(context));
  }

  Center wholeBody(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('Organise everything'),
          SizedBox(height: 26),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) =>  RegScreen()),
                );
              },
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.lightGreen,
                padding: EdgeInsets.all(8.0),
                minimumSize: Size.fromHeight(50),
                textStyle: TextStyle(fontSize: 18),
              ),
              child: const Text('Sign up'),
            ),
          ),
          SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => LoginScreen()),
              );
            },
            style: ElevatedButton.styleFrom(
              foregroundColor: Colors.lightGreen,
              padding: EdgeInsets.all(8.0),
              minimumSize: Size.fromHeight(50),
              textStyle: TextStyle(fontSize: 18),
            ),
            child: const Text('Log in'),
          ),
        ],
      ),
    );
  }

  AppBar appBar() {
    return AppBar(
      backgroundColor: Colors.lightGreen,
      title: const Text('FAM-ILY'),
    );
  }
}

