import 'package:flutter/material.dart';

import 'core/theme/zuri_theme.dart';
import 'features/auth/welcome_screen.dart';

class ZuriApp extends StatelessWidget {
  const ZuriApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Zuri',
      debugShowCheckedModeBanner: false,
      theme: ZuriTheme.light(),
      home: const WelcomeScreen(),
    );
  }
}
