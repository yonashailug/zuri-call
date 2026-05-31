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
              toolbarHeight: 84,
              title: Text(
                title!,
              ),
              actions: actions,
            ),
      bottomNavigationBar: bottomNavigationBar,
      body: SafeArea(
        child: Material(
          color: ZuriColors.surface,
          child: child,
        ),
      ),
    );
  }
}
