import 'package:flutter/material.dart';

import '../theme/zuri_theme.dart';

class ZuriScaffold extends StatelessWidget {
  const ZuriScaffold({
    required this.child,
    this.title,
    this.actions,
    this.bottomNavigationBar,
    super.key,
  });

  final Widget child;
  final String? title;
  final List<Widget>? actions;
  final Widget? bottomNavigationBar;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: title == null
          ? null
          : AppBar(
              title: Text(
                title!,
                style: const TextStyle(fontWeight: FontWeight.w800),
              ),
              actions: actions,
            ),
      bottomNavigationBar: bottomNavigationBar,
      body: SafeArea(
        child: DecoratedBox(
          decoration: const BoxDecoration(color: ZuriColors.surface),
          child: child,
        ),
      ),
    );
  }
}
