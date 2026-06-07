import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../app/routing/app_routes.dart';
import '../../core/ui/zuri_ui.dart';
import 'application/auth_scope.dart';
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
    final authController = AuthScope.of(context);
    final authState = authController.state;
    final isBusy = authState.isBusy;

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
          if (authState.errorMessage != null) ...[
            Text(
              authState.errorMessage!,
              style: ZuriTextStyles.bodyText.copyWith(
                color: Theme.of(context).colorScheme.error,
              ),
            ),
            const SizedBox(height: 18),
          ],
          ZuriPillButton(
            label: isBusy ? 'Creating...' : 'Create an account',
            onPressed: canContinue && !isBusy
                ? () async {
                    final didCreate = await authController.createProfile(
                      nameController.text,
                    );
                    if (!context.mounted || !didCreate) return;
                    context.go(AppRoutes.root);
                  }
                : null,
          ),
        ],
      ),
    );
  }
}
