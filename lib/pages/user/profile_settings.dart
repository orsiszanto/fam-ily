import 'package:familyapp/cubit/user_cubit/user_bloc.dart';
import 'package:familyapp/cubit/user_cubit/user_state.dart';
import 'package:familyapp/design/app_bar.dart';
import 'package:familyapp/design/spacing.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ProfileSettingsPage extends StatefulWidget {
  const ProfileSettingsPage({super.key});

  @override
  State<ProfileSettingsPage> createState() => _ProfileSettingsPageState();
}

class _ProfileSettingsPageState extends State<ProfileSettingsPage> {
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final currentPasswordForEmailController = TextEditingController();
  final newPasswordController = TextEditingController();
  final currentPasswordForPasswordController = TextEditingController();

  bool _didFillInitialValues = false;

  @override
  void initState() {
    super.initState();
    context.read<UserBloc>().loadUserInfo();
  }

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    currentPasswordForEmailController.dispose();
    newPasswordController.dispose();
    currentPasswordForPasswordController.dispose();
    super.dispose();
  }

  void _fillControllers(UserState state) {
    if (!_didFillInitialValues) {
      if (state is UserInfoLoaded || state is UserInfoUpdated) {
        final user = (state is UserInfoLoaded)
            ? (state as UserInfoLoaded).user
            : (state as UserInfoUpdated).user;
        nameController.text = user.name;
        emailController.text = user.email;
        _didFillInitialValues = true;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarStyles.functions(
        title: 'PROFILE SETTINGS',
        onBack: () => Navigator.pop(context),
      ),
      body: BlocConsumer<UserBloc, UserState>(
        listener: (context, state) {
          if (state is UserError) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(state.message)));
          }

          if (state is FailedAuth) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(state.errorMessage)));
          }

          if (state is UserInfoLoaded) {
            _fillControllers(state);
          }

          if (state is UserInfoUpdated) {
            _fillControllers(state);
            currentPasswordForEmailController.clear();
            newPasswordController.clear();
            currentPasswordForPasswordController.clear();

            ScaffoldMessenger.of(
              context,
            ).showSnackBar(const SnackBar(content: Text("Profile updated")));
          }
        },
        builder: (context, state) {
          if (state is UserInfoLoading || state is AuthInProgress) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is UserInfoUpdated || state is UserInfoLoaded) {
            _fillControllers(state);

            return ListView(
              padding: const EdgeInsets.all(16),
              children: [
                const Text(
                  "Change name",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: AppSpacing.s),
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: AppSpacing.s),
                ElevatedButton(
                  onPressed: () {
                    if (nameController.text.trim().isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text("You must fill out every field!"),
                        ),
                      );
                    } else {
                      context.read<UserBloc>().updateName(nameController.text);
                    }
                  },
                  child: const Text("Save name"),
                ),

                const SizedBox(height: AppSpacing.xl),

                const Text(
                  "Change email",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: AppSpacing.s),
                TextFormField(
                  validator: validateEmail,
                  controller: emailController,
                  decoration: const InputDecoration(
                    labelText: "New email",
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: AppSpacing.s),
                TextField(
                  controller: currentPasswordForEmailController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: "Current password",
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: AppSpacing.s),
                ElevatedButton(
                  onPressed: () {
                    if (emailController.text.trim().isEmpty ||
                        currentPasswordForEmailController.text.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text("You must fill out every field!"),
                        ),
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            "Confirmation email sent out, please check your new email's spam folder!",
                          ),
                        ),
                      );
                      context.read<UserBloc>().updateEmail(
                        emailController.text,
                        currentPasswordForEmailController.text,
                      );
                    }
                  },
                  child: const Text("Save email"),
                ),

                const SizedBox(height: AppSpacing.xl),

                const Text(
                  "Change password",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: AppSpacing.s),
                TextField(
                  controller: newPasswordController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: "New password",
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: AppSpacing.s),
                TextField(
                  controller: currentPasswordForPasswordController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: "Current password",
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: AppSpacing.s),
                ElevatedButton(
                  onPressed: () {
                    if (currentPasswordForPasswordController.text
                            .trim()
                            .isEmpty ||
                        newPasswordController.text.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text("You must fill out every field!"),
                        ),
                      );
                    } else {
                      context.read<UserBloc>().updatePassword(
                        newPasswordController.text,
                        currentPasswordForPasswordController.text,
                      );
                    }
                  },
                  child: const Text("Save password"),
                ),
              ],
            );
          }

          if (state is FailedAuth) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Text(state.errorMessage, textAlign: TextAlign.center),
              ),
            );
          }

          return const Center(child: Text("Unable to load profile"));
        },
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
}
