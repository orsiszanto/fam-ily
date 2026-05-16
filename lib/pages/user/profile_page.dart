import 'package:familyapp/cubit/user_cubit/user_bloc.dart';
import 'package:familyapp/cubit/user_cubit/user_state.dart';
import 'package:familyapp/design/app_bar.dart';
import 'package:familyapp/design/app_button.dart';
import 'package:familyapp/design/spacing.dart';
import 'package:familyapp/services/user_service.dart';
import 'package:familyapp/pages/user/profile_settings.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  late UserBloc _userBloc;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _userBloc = context.read<UserBloc>();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<UserBloc, UserState>(
      listener: (BuildContext context, UserState state) {  },
      child: Scaffold(
        appBar: AppBarStyles.functions(
          title: 'SETTINGS',
          onBack: () => Navigator.pop(context),
        ),
        body: wholeBody(context),
      ),
    );
  }

  Widget wholeBody(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      padding: const EdgeInsets.all(AppSpacing.m),
      crossAxisSpacing: AppSpacing.m,
      mainAxisSpacing: AppSpacing.m,
      children: [
        _buildGridItem(context, Icons.person_2_outlined, "Account"),
        _buildGridItem(context, Icons.group_outlined, "Group code"),
        _buildGridItem(
          context,
          Icons.delete_forever_outlined,
          "Delete profile",
        ),
        _buildGridItem(context, Icons.logout_outlined, "Logout"),
        const SizedBox(),
      ],
    );
  }

  Future<void> _showGroupCodeDialog(BuildContext context) async {
    try {
      final user = await UserService.loadUserInfo();
      if (!context.mounted) return;

      final groupCode = user.groupCode;

      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text("Your family code"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SelectableText(
                groupCode,
                style: const TextStyle(fontSize: 18),
              ),
              const SizedBox(height: AppSpacing.m),
              const Text(
                "Share this code with your family members",
                textAlign: TextAlign.center,
              ),
            ],
          ),
          actions: [
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.m,
                vertical: AppSpacing.xs,
              ),
              child: Row(
                children: [
                  AppButton(
                    text: "Close",
                    onPressed: () => Navigator.pop(context),
                    type: ButtonType.dialogCancel,
                  ),
                  const SizedBox(width: AppSpacing.xl),
                  AppButton(
                    text: "Copy",
                    onPressed: () async {
                      await Clipboard.setData(ClipboardData(text: groupCode));
                      if (!context.mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("Group code copied!"),
                        ),
                      );
                    },
                    type: ButtonType.dialogSave,
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    } catch (_) {
      if (!context.mounted) return;
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text("Your family code"),
          content: const Text("Failed to load group code"),
          actions: [
            AppButton(
              text: "Close",
              onPressed: () => Navigator.pop(context),
              type: ButtonType.dialogCancel,
            ),
          ],
        ),
      );
    }
  }

  Widget _buildGridItem(BuildContext context, IconData icon, String label) {
    return GestureDetector(
      onTap: () async {
        switch (label) {
          case "Account":
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => BlocProvider.value(
                  value: _userBloc,
                  child: const ProfileSettingsPage(),
                ),
              ),
            );
            break;

          case "Group code":
            await _showGroupCodeDialog(context);
            break;

          case "Delete profile":
            final passwordController = TextEditingController();

            showDialog(
              context: context,
              builder: (_) => AlertDialog(
                title: const Text("Delete account"),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      "This action cannot be undone. Enter your password to continue.",
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: passwordController,
                      obscureText: true,
                      decoration: const InputDecoration(
                        labelText: "Current password",
                      ),
                    ),
                  ],
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text("Cancel"),
                  ),
                  TextButton(
                    onPressed: () {
                      final password = passwordController.text.trim();
                      Navigator.pop(context);
                      _userBloc.deleteProfile(password);
                    },
                    child: const Text("Delete"),
                  ),
                ],
              ),
            );
            break;

          case "Logout":
            context.read<UserBloc>().signOut();
            break;
        }
      },
      child: Card(
        margin: EdgeInsets.all(16),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 50, color: Colors.lightGreen),
              const SizedBox(height: 8),
              Text(label),
            ],
          ),
        ),
      ),
    );
  }
}
