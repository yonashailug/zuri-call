import 'package:flutter/material.dart';

import '../../core/theme/zuri_theme.dart';
import '../../core/widgets/gradient_button.dart';
import '../../core/widgets/zuri_scaffold.dart';
import '../home/app_shell.dart';

class OtpScreen extends StatefulWidget {
  const OtpScreen({super.key});

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  final phoneController = TextEditingController();
  final codeController = TextEditingController();
  bool codeSent = false;

  @override
  void dispose() {
    phoneController.dispose();
    codeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ZuriScaffold(
      title: codeSent ? 'Verify your account' : 'Continue with phone',
      child: ListView(
        padding: const EdgeInsets.fromLTRB(24, 18, 24, 32),
        children: [
          Text(
            codeSent
                ? 'Enter the code sent to ${phoneController.text}'
                : 'Use your mobile number to sign in or create an account.',
            style: const TextStyle(
              color: ZuriColors.muted,
              fontSize: 15,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 24),
          TextField(
            controller: phoneController,
            enabled: !codeSent,
            keyboardType: TextInputType.phone,
            decoration: const InputDecoration(
              labelText: 'Phone number',
              hintText: '+1 206 555 0142',
              prefixIcon: Icon(Icons.phone_iphone_rounded),
            ),
          ),
          if (codeSent) ...[
            const SizedBox(height: 14),
            TextField(
              controller: codeController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Verification code',
                hintText: '123456',
                prefixIcon: Icon(Icons.password_rounded),
              ),
            ),
          ],
          const SizedBox(height: 24),
          GradientButton(
            label: codeSent ? 'Verify' : 'Send code',
            icon: codeSent ? Icons.verified_rounded : Icons.sms_rounded,
            onPressed: () {
              if (codeSent) {
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute<void>(
                    builder: (_) => const AppShell(),
                  ),
                  (_) => false,
                );
                return;
              }
              setState(() => codeSent = true);
            },
          ),
          if (codeSent) ...[
            const SizedBox(height: 12),
            TextButton(
              onPressed: () => setState(() => codeSent = false),
              child: const Text('Change phone number'),
            ),
          ],
        ],
      ),
    );
  }
}
