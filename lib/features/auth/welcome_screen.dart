import 'package:flutter/material.dart';

import '../../core/theme/zuri_theme.dart';
import '../../core/widgets/gradient_button.dart';
import '../../core/widgets/zuri_scaffold.dart';
import 'otp_screen.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ZuriScaffold(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
        child: Column(
          children: [
            const Spacer(),
            const _SignalMark(),
            const SizedBox(height: 24),
            const Text(
              'Zuri',
              style: TextStyle(
                fontSize: 36,
                fontWeight: FontWeight.w900,
                letterSpacing: 0,
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              'Crystal-clear calls, wherever you are',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: ZuriColors.muted,
                fontSize: 15,
                height: 1.4,
              ),
            ),
            const Spacer(),
            GradientButton(
              label: 'Continue with phone',
              icon: Icons.phone_iphone_rounded,
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => const OtpScreen(),
                ),
              ),
            ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => const OtpScreen(),
                ),
              ),
              child: const Text('I already have an account'),
            ),
          ],
        ),
      ),
    );
  }
}

class _SignalMark extends StatelessWidget {
  const _SignalMark();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 180,
      width: 180,
      child: Stack(
        alignment: Alignment.center,
        children: [
          const _Ring(size: 172, opacity: 0.16),
          const _Ring(size: 122, opacity: 0.22),
          DecoratedBox(
            decoration: BoxDecoration(
              color: ZuriColors.primary.withValues(alpha: 0.08),
              border: Border.all(
                color: ZuriColors.primary.withValues(alpha: 0.28),
              ),
              shape: BoxShape.circle,
            ),
            child: const SizedBox(
              height: 72,
              width: 72,
              child: Icon(
                Icons.call_rounded,
                color: ZuriColors.primary,
                size: 30,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Ring extends StatelessWidget {
  const _Ring({required this.size, required this.opacity});

  final double size;
  final double opacity;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: size,
      width: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: ZuriColors.primary.withValues(alpha: opacity),
        ),
      ),
    );
  }
}
