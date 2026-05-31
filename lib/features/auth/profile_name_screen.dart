import 'package:flutter/material.dart';

import '../../core/ui/zuri_ui.dart';
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
        padding: ZuriSpacing.authBody,
        children: [
          const ZuriScreenHeadline(
            'Please enter your name to create an account.',
          ),
          const SizedBox(height: 50),
          const ZuriFieldLabel('Name'),
          const SizedBox(height: 8),
          ZuriTextField(
            controller: nameController,
            hintText: 'Enter your full name',
            textInputAction: TextInputAction.done,
            autofocus: true,
            onChanged: (_) => setState(() {}),
          ),
          const SizedBox(height: 34),
          ZuriPillButton(
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
