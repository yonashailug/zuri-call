import 'package:flutter/material.dart';

import 'auth_design.dart';
import 'phone_entry_screen.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AuthColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(28, 40, 28, 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Spacer(),
              const Center(child: _SignalMark()),
              const SizedBox(height: 24),
              const Text(
                'Zuri',
                style: TextStyle(
                  color: AuthColors.ink,
                  fontFamily: 'Georgia',
                  fontSize: 48,
                  height: 1,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0,
                ),
              ),
              const SizedBox(height: 14),
              const Text(
                'Crystal-clear calls, wherever you are',
                style: TextStyle(
                  color: AuthColors.muted,
                  fontSize: 22,
                  height: 1.2,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              AuthPillButton(
                label: 'Continue with phone',
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => const PhoneEntryScreen(),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              TextButton(
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => const PhoneEntryScreen(),
                  ),
                ),
                style: TextButton.styleFrom(
                  foregroundColor: AuthColors.muted,
                  textStyle: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                child: const Text('I already have an account'),
              ),
            ],
          ),
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
              color: AuthColors.ink.withValues(alpha: 0.08),
              border: Border.all(
                color: AuthColors.ink.withValues(alpha: 0.25),
              ),
              shape: BoxShape.circle,
            ),
            child: const SizedBox(
              height: 72,
              width: 72,
              child: Icon(
                Icons.call_rounded,
                color: AuthColors.ink,
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
          color: AuthColors.ink.withValues(alpha: opacity),
        ),
      ),
    );
  }
}
