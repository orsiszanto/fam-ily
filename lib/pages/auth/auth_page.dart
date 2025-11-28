import 'package:flutter/material.dart';
import './registration_page.dart';
import './login_page.dart';

class AuthPage extends StatelessWidget {
  const AuthPage({super.key});

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
              child: const Text('Sign in'),
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
            ),
          ),
          SizedBox(height: 16),
          ElevatedButton(
            child: const Text('Log in'),
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

