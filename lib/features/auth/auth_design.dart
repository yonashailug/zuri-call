import 'package:flutter/material.dart';

import '../../core/ui/zuri_ui.dart';

class AuthScaffold extends StatelessWidget {
  const AuthScaffold({
    required this.child,
    this.onBack,
    this.onClose,
    super.key,
  });

  final Widget child;
  final VoidCallback? onBack;
  final VoidCallback? onClose;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 22, 20, 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ZuriCircleButton(
                    icon: ZuriIcons.back,
                    onPressed: onBack ?? () => Navigator.maybePop(context),
                  ),
                  ZuriCircleButton(
                    icon: ZuriIcons.close,
                    onPressed: onClose ??
                        () => Navigator.of(context).popUntil(
                              (route) => route.isFirst,
                            ),
                  ),
                ],
              ),
            ),
            Expanded(child: child),
          ],
        ),
      ),
    );
  }
}
