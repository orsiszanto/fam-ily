
import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
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

        body: ElevatedButton(
          child: Text('Register'),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => RegScreen()),
            );
          },
        ),
        

        /*body: Container(
          child: Column(
            children: <Widget> [
              const ElevatedButton(
                onPressed: (){
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder:(_) RegScreen(),
                      ),
                      );
                },
                child: Text('Registrate')
                 ),
              const SizedBox(height: 30),
              ElevatedButton(
                onPressed: null,
                child: const Text('Log in')
                ),
            ],
          ),
        ),*/
      ),
    );
  }
}

class RegScreen extends StatelessWidget {
  const RegScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(appBar: AppBar());
  }
}
