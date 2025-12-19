import 'package:familyapp/cubit/user_cubit/user_bloc.dart';
import 'package:familyapp/cubit/user_cubit/user_state.dart';
import 'package:familyapp/services/user_service.dart';
import 'package:flutter/material.dart';
import 'package:familyapp/pages/auth/login_page.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class RegScreen extends StatelessWidget {
  var emailController = TextEditingController();
  var passwordController = TextEditingController();

  RegScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(appBar: appBar(), body: wholeBody(context));
  }

  Center wholeBody(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: BlocConsumer<UserBloc, UserState>(
          listener: (context, state) {
            if (state is RegisterSuccessful) {
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text("Successful signing up!")));
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => LoginScreen()),
              );
              return;
            }
            if(state is FailedAuth){
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text(state.errorMessage)));
            }

            if (state is FailedAuth) {
              debugPrint("in failed auth listener");
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text(state.errorMessage)));
            }
          },
          builder: (context, state) => state is AuthInProgress
              ? CircularProgressIndicator()
              : Column(
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
                          signupButton(context)
                        ],
                      ),
                    ),
                    SizedBox(height: 26),
                    Text('If you already have an account, please log in'),
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

  Widget signupButton(BuildContext context) => ElevatedButton(
    onPressed: () {
      String email = emailController.text.trim();
      String password = passwordController.text.trim();

      if (email.isEmpty || password.isEmpty) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Fill out every field")));
      } else {
        context.read<UserBloc>().signIn(email, password);
      }
    },

    style: ElevatedButton.styleFrom(
      foregroundColor: Colors.lightGreen,
      padding: EdgeInsets.all(8.0),
      minimumSize: Size.fromHeight(50),
      textStyle: TextStyle(fontSize: 18),
    ),
    child: const Text('Sign in'),
  );

  AppBar appBar() {
    return AppBar(
      backgroundColor: Colors.lightGreen,
      title: const Text('SIGN IN'),
    );
  }
}
