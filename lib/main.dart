import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.lightGreen,
          title: const Text('FAM-ILY'),
        ),
        body: const AuthPage(),
      ),
    );
  }
}

class AuthPage extends StatelessWidget {
  const AuthPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      child: const Text('Register'),
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const RegScreen()),
        );
      },
    );
  }
}

class RegScreen extends StatelessWidget {
  const RegScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: const Center(child: Text("You made it to the Reg page")),
    );
  }
}
