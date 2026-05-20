import 'package:familyapp/cubit/user_cubit/user_bloc.dart';
import 'package:familyapp/cubit/user_cubit/user_state.dart';
import 'package:familyapp/design/app_button.dart';
import 'package:familyapp/design/spacing.dart';
import 'package:flutter/material.dart';
import 'package:familyapp/pages/auth/login_page.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:familyapp/design/app_bar.dart';

class RegScreen extends StatefulWidget {
  const RegScreen({super.key});

  @override
  State<RegScreen> createState() => _RegScreenState();
}

class _RegScreenState extends State<RegScreen> {
  final _formKey = GlobalKey<FormState>();
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  final groupCodeController = TextEditingController();
  bool isParent = false;
  bool createNewGroup = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    groupCodeController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarStyles.subpage(
        title: 'SIGN UP',
        onBack: () => Navigator.pop(context),
      ),
      body: wholeBody(context),
    );
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
            if (state is FailedAuth) {
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text(state.errorMessage)));
            }
          },
          builder: (context, state) {
            if (state is AuthInProgress) {
              return const CircularProgressIndicator();
            }

            return SingleChildScrollView(
              child: Column(
                children: [
                  Form(
                    key: _formKey,
                    autovalidateMode: AutovalidateMode.onUserInteraction,
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
                        SizedBox(height: AppSpacing.l),

                        TextFormField(
                          controller: passwordController,
                          validator: validatePassword,
                          decoration: InputDecoration(
                            labelText: "Password",
                            border: OutlineInputBorder(),
                            errorMaxLines: 4,
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscurePassword
                                    ? Icons.visibility_off
                                    : Icons.visibility,
                              ),
                              onPressed: () {
                                setState(() {
                                  _obscurePassword = !_obscurePassword;
                                });
                              },
                            ),
                          ),
                          obscureText: _obscurePassword,
                        ),
                        SizedBox(height: AppSpacing.l),

                        TextFormField(
                          controller: confirmPasswordController,
                          validator: validateConfirmPassword,
                          decoration: InputDecoration(
                            labelText: "Confirm password",
                            border: OutlineInputBorder(),
                            errorMaxLines: 3,
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscureConfirmPassword
                                    ? Icons.visibility_off
                                    : Icons.visibility,
                              ),
                              onPressed: () {
                                setState(() {
                                  _obscureConfirmPassword =
                                      !_obscureConfirmPassword;
                                });
                              },
                            ),
                          ),
                          obscureText: _obscureConfirmPassword,
                        ),
                        SizedBox(height: AppSpacing.l),

                        TextFormField(
                          controller: nameController,
                          decoration: InputDecoration(
                            labelText: "Name",
                            border: OutlineInputBorder(),
                          ),
                        ),
                        SizedBox(height: AppSpacing.l),

                        CheckboxListTile(
                          value: isParent,
                          onChanged: (value) {
                            setState(() {
                              isParent = value ?? false;
                            });
                          },
                          title: const Text("Sign up as a Parent"),
                          controlAffinity: ListTileControlAffinity.leading,
                          contentPadding: EdgeInsets.zero,
                        ),
                        SizedBox(height: AppSpacing.l),

                        CheckboxListTile(
                          value: createNewGroup,
                          onChanged: (value) {
                            setState(() {
                              createNewGroup = value ?? false;
                            });
                          },
                          title: const Text("Make a new family group"),
                          controlAffinity: ListTileControlAffinity.leading,
                          contentPadding: EdgeInsets.zero,
                        ),

                        if (!createNewGroup) ...[
                          SizedBox(height: AppSpacing.l),
                          TextFormField(
                            controller: groupCodeController,
                            decoration: InputDecoration(
                              labelText: "Existing family group code",
                              border: OutlineInputBorder(),
                            ),
                          ),
                        ],

                        SizedBox(height: AppSpacing.l),
                        signupButton(context),
                      ],
                    ),
                  ),
                  SizedBox(height: AppSpacing.l),
                  Text('If you already have an account, please log in'),
                  AppButton(
                    text: 'Log in',
                    type: ButtonType.inverse,
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
          },
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
        ? 'Please enter a vaild email address!'
        : null;
  }

  String? validatePassword(String? value) {
    final password = value?.trim() ?? '';

    if (password.isEmpty) {
      return 'Please enter a password';
    }

    final hasMinimumLength = password.length >= 8;
    final hasUppercase = RegExp(r'[A-Z]').hasMatch(password);
    final hasNumber = RegExp(r'\d').hasMatch(password);

    if (!hasMinimumLength || !hasUppercase || !hasNumber) {
      return '''Password must:
• be at least 8 characters long
• include an uppercase letter
• include a number''';
    }

    return null;
  }

  String? validateConfirmPassword(String? value) {
    final confirmPassword = value?.trim() ?? '';

    if (confirmPassword.isEmpty) {
      return 'Please confirm your password';
    }

    if (confirmPassword != passwordController.text.trim()) {
      return 'Passwords do not match';
    }

    return null;
  }

  Widget signupButton(BuildContext context) => AppButton(
    text: 'Sign up',
    type: ButtonType.inverse,
    onPressed: () {
      if (!(_formKey.currentState?.validate() ?? false)) {
        return;
      }

      final email = emailController.text.trim();
      final password = passwordController.text.trim();
      final confirmPassword = confirmPasswordController.text.trim();
      final name = nameController.text.trim();
      final groupCode = groupCodeController.text.trim();

      if (email.isEmpty ||
          password.isEmpty ||
          confirmPassword.isEmpty ||
          name.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("You must fill out every field")),
        );
      } else if (!createNewGroup && groupCode.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              "If you do not make a family group, you have to join one",
            ),
          ),
        );
      } else {
        context.read<UserBloc>().signUpWithGroup(
          email,
          password,
          name,
          createNewGroup,
          createNewGroup ? null : groupCode,
          isParent,
        );
      }
    },
  );
}
