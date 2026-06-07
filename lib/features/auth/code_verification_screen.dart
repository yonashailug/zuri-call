import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import '../../app/routing/app_routes.dart';
import '../../core/theme/zuri_theme.dart';
import '../../core/ui/zuri_ui.dart';
import 'application/auth_scope.dart';
import 'auth_design.dart';

class CodeVerificationScreen extends StatefulWidget {
  const CodeVerificationScreen({super.key});

  @override
  State<CodeVerificationScreen> createState() => _CodeVerificationScreenState();
}

class _CodeVerificationScreenState extends State<CodeVerificationScreen> {
  final codeController = TextEditingController();
  final focusNode = FocusNode();

  bool get canContinue => codeController.text.length == 6;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) focusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    codeController.dispose();
    focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authController = AuthScope.of(context);
    final authState = authController.state;
    final phoneNumber = authState.phoneNumber;
    final isBusy = authState.isBusy;

    return AuthScaffold(
      child: ListView(
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        padding: ZuriSpacing.authBody,
        children: [
          const ZuriScreenHeadline(
              "We've sent you a security code. Please type it here:"),
          const SizedBox(height: 44),
          GestureDetector(
            onTap: focusNode.requestFocus,
            child: Stack(
              alignment: Alignment.center,
              children: [
                _CodeBoxes(value: codeController.text),
                Opacity(
                  opacity: 0,
                  child: TextField(
                    controller: codeController,
                    focusNode: focusNode,
                    autofocus: true,
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(6),
                    ],
                    onChanged: (_) => setState(() {}),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 46),
          TextButton(
            onPressed: isBusy
                ? null
                : () async {
                    if (phoneNumber == null) return;
                    await authController.startPhoneAuth(phoneNumber);
                  },
            style: TextButton.styleFrom(
              foregroundColor: ZuriColors.accent,
              textStyle: ZuriTextStyles.sectionHeader,
            ),
            child: const Text("I didn't get a text message"),
          ),
          const SizedBox(height: 46),
          if (authState.errorMessage != null) ...[
            Text(
              authState.errorMessage!,
              style: ZuriTextStyles.bodyText.copyWith(
                color: ZuriColors.danger,
              ),
            ),
            const SizedBox(height: 18),
          ],
          ZuriPillButton(
            label: isBusy ? 'Verifying...' : 'Continue',
            onPressed: canContinue && !isBusy
                ? () async {
                    final didVerify = await authController.verifyCode(
                      codeController.text,
                    );
                    if (!context.mounted || !didVerify) return;
                    context.push(AppRoutes.authProfile);
                  }
                : null,
          ),
        ],
      ),
    );
  }
}

class _CodeBoxes extends StatelessWidget {
  const _CodeBoxes({required this.value});

  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: List.generate(6, (index) {
        final hasValue = index < value.length;
        final focused = index == value.length.clamp(0, 5);
        return Container(
          height: 96,
          width: 54,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: ZuriColors.card,
            borderRadius: BorderRadius.circular(ZuriRadius.field),
            border: Border.all(
              color: focused ? ZuriColors.ink : ZuriColors.border,
              width: 1.4,
            ),
          ),
          child: Text(
            hasValue ? value[index] : '',
            style: ZuriTextStyles.inputText.copyWith(
              color: ZuriColors.ink,
            ),
          ),
        );
      }),
    );
  }
}
