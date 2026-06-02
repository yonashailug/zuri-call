import 'package:flutter/material.dart';

import '../../core/theme/zuri_theme.dart';
import '../../core/ui/zuri_ui.dart';
import 'phone_entry_screen.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              padding: ZuriSpacing.welcome,
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: constraints.maxHeight < 520 ? 16 : 40),
                    const Center(child: _SignalMark()),
                    const SizedBox(height: 24),
                    const Text(
                      'Zuri',
                      style: ZuriTextStyles.display,
                    ),
                    const SizedBox(height: 14),
                    Text(
                      'Crystal-clear calls, wherever you are',
                      style: ZuriTextStyles.control.copyWith(
                        color: ZuriColors.muted,
                        height: 1.2,
                      ),
                    ),
                    SizedBox(height: constraints.maxHeight < 520 ? 32 : 80),
                    ZuriPillButton(
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
                        foregroundColor: ZuriColors.muted,
                        textStyle: ZuriTextStyles.label,
                      ),
                      child: const Text('I already have an account'),
                    ),
                  ],
                ),
              ),
            );
          },
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
              color: ZuriColors.ink.withValues(alpha: 0.08),
              border: Border.all(
                color: ZuriColors.ink.withValues(alpha: 0.25),
              ),
              shape: BoxShape.circle,
            ),
            child: const SizedBox(
              height: 72,
              width: 72,
              child: Icon(
                ZuriIcons.phone,
                color: ZuriColors.ink,
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
          color: ZuriColors.ink.withValues(alpha: opacity),
        ),
      ),
    );
  }
}
