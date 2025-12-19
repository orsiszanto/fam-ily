import 'package:familyapp/services/user_service.dart';
import 'package:flutter/material.dart';
import 'package:familyapp/pages/auth/registration_page.dart';
import 'package:familyapp/pages/dashboard/main_page.dart';

class LoginScreen extends StatelessWidget {
  var emailController = TextEditingController();
  var passwordController = TextEditingController();

  LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(appBar: appBar(), body: wholeBody(context));
  }

  Center wholeBody(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Form(
              autovalidateMode: AutovalidateMode.always,
              child: Column(
                children: [
                  TextFormField(
                    controller: emailController,
                    validator: validateEmail,
                    decoration: InputDecoration(
                      labelText: "Email",
                      border: OutlineInputBorder(),
                    ),
                  ),
                  SizedBox(height: 26),
                  TextFormField(
                    controller: passwordController,
                    decoration: InputDecoration(
                      labelText: "Password",
                      border: OutlineInputBorder(),
                    ),
                    obscureText: true,
                  ),
                  SizedBox(height: 26),
                  ElevatedButton(
                    onPressed: () {
                      String email = emailController.text.trim();
                      String password = passwordController.text.trim();

                      if (email.isEmpty || password.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text("Fill out every field!")),
                        );
                      } else {
                        UserService.logIn(email, password)
                            .then((value) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text("Successful logging in!"),
                                ),
                              );
                              Navigator.push(context,
                              MaterialPageRoute(builder: (_) => Dashboard(),
                              )
                              );
                            }).catchError((error){
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text(error.toString())),
                              );
                            });
                      }
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
            ),
            SizedBox(height: 26),
            Text('If you have no account, please sign in'),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => RegScreen()),
                );
              },
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.lightGreen,
                padding: EdgeInsets.all(8.0),
                minimumSize: Size.fromHeight(50),
                textStyle: TextStyle(fontSize: 18),
              ),
              child: const Text('Sign in'),
            ),
          ],
        ),
      ),
    );
  }

  // Source - https://stackoverflow.com/a
  // Posted by JideGuru, modified by community. See post 'Timeline' for change history
  // Retrieved 2025-11-28, License - CC BY-SA 4.0
  String? validateEmail(String? value) {
    const pattern =
        r"(?:[a-z0-9!#$%&'*+/=?^_`{|}~-]+(?:\.[a-z0-9!#$%&'"
        r'*+/=?^_`{|}~-]+)*|"(?:[\x01-\x08\x0b\x0c\x0e-\x1f\x21\x23-\x5b\x5d-'
        r'\x7f]|\\[\x01-\x09\x0b\x0c\x0e-\x7f])*")@(?:(?:[a-z0-9](?:[a-z0-9-]*'
        r'[a-z0-9])?\.)+[a-z0-9](?:[a-z0-9-]*[a-z0-9])?|\[(?:(?:(2(5[0-5]|[0-4]'
        r'[0-9])|1[0-9][0-9]|[1-9]?[0-9]))\.){3}(?:(2(5[0-5]|[0-4][0-9])|1[0-9]'
        r'[0-9]|[1-9]?[0-9])|[a-z0-9-]*[a-z0-9]:(?:[\x01-\x08\x0b\x0c\x0e-\x1f\'
        r'x21-\x5a\x53-\x7f]|\\[\x01-\x09\x0b\x0c\x0e-\x7f])+)\])';
    final regex = RegExp(pattern);

    return value!.isNotEmpty && !regex.hasMatch(value)
        ? 'Enter a valid email address'
        : null;
  }

  AppBar appBar() {
    return AppBar(
      backgroundColor: Colors.lightGreen,
      title: const Text('LOG IN'),
    );
  }
}
