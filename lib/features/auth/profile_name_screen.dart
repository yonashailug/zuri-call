import 'package:flutter/material.dart';

import '../home/app_shell.dart';
import 'auth_design.dart';

class ProfileNameScreen extends StatefulWidget {
  const ProfileNameScreen({super.key});

  @override
  State<ProfileNameScreen> createState() => _ProfileNameScreenState();
}

class _ProfileNameScreenState extends State<ProfileNameScreen> {
  final nameController = TextEditingController();

  bool get canContinue => nameController.text.trim().length >= 2;

  @override
  void dispose() {
    nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AuthScaffold(
      child: ListView(
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        padding: const EdgeInsets.fromLTRB(28, 46, 28, 32),
        children: [
          const AuthHeadline('Please enter your name to create an account.'),
          const SizedBox(height: 50),
          const AuthFieldLabel('Name'),
          const SizedBox(height: 8),
          AuthTextField(
            controller: nameController,
            hintText: 'Enter your full name',
            textInputAction: TextInputAction.done,
            autofocus: true,
            onChanged: (_) => setState(() {}),
          ),
          const SizedBox(height: 34),
          AuthPillButton(
            label: 'Create an account',
            onPressed: canContinue
                ? () => Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute<void>(
                        builder: (_) => const AppShell(),
                      ),
                      (_) => false,
                    )
                : null,
          ),
        ],
      ),
    );
  }
}
