import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../theme/zuri_theme.dart';
import 'zuri_icons.dart';
import 'zuri_tokens.dart';

class ZuriPillButton extends StatelessWidget {
  const ZuriPillButton({
    required this.label,
    required this.onPressed,
    this.icon,
    this.height = 48,
    super.key,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final double height;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final enabled = onPressed != null;

    final style = TextButton.styleFrom(
      backgroundColor: enabled ? colors.primary : colors.outlineVariant,
      foregroundColor: const Color(0xFFF2EAE3),
      shape: const StadiumBorder(),
      textStyle: ZuriTextStyles.formControl,
    );

    return SizedBox(
      height: height,
      width: double.infinity,
      child: icon == null
          ? TextButton(
              onPressed: onPressed,
              style: style,
              child: Text(label),
            )
          : TextButton.icon(
              onPressed: onPressed,
              style: style,
              icon: Icon(icon),
              label: Text(label),
            ),
    );
  }
}

class ZuriCircleButton extends StatelessWidget {
  const ZuriCircleButton({
    required this.icon,
    required this.onPressed,
    this.foregroundColor,
    this.backgroundColor,
    this.size = 36,
    this.iconSize,
    super.key,
  });

  final IconData icon;
  final VoidCallback onPressed;
  final Color? foregroundColor;
  final Color? backgroundColor;
  final double size;
  final double? iconSize;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return SizedBox.square(
      dimension: size,
      child: IconButton(
        onPressed: onPressed,
        icon: Icon(icon, size: iconSize),
        color: foregroundColor ?? colors.primary,
        style: IconButton.styleFrom(
          // Spec: icon button bg = rgba(28,56,32,0.07)
          backgroundColor: backgroundColor ?? ZuriColors.iconButtonBg,
          shape: const CircleBorder(),
        ),
      ),
    );
  }
}

class ZuriBackButton extends StatelessWidget {
  const ZuriBackButton({
    required this.onPressed,
    super.key,
  });

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return ZuriCircleButton(
      icon: ZuriIcons.back,
      onPressed: onPressed,
      size: 36,
      iconSize: 22,
      foregroundColor: ZuriColors.ink,
      backgroundColor: ZuriColors.endedCallPill,
    );
  }
}

class ZuriTextField extends StatelessWidget {
  const ZuriTextField({
    required this.controller,
    required this.hintText,
    this.keyboardType,
    this.textInputAction,
    this.inputFormatters,
    this.autofocus = false,
    this.onChanged,
    super.key,
  });

  final TextEditingController controller;
  final String hintText;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final List<TextInputFormatter>? inputFormatters;
  final bool autofocus;
  final ValueChanged<String>? onChanged;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return TextField(
      controller: controller,
      autofocus: autofocus,
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      inputFormatters: inputFormatters,
      onChanged: onChanged,
      cursorColor: colors.primary,
      style: ZuriTextStyles.inputText.copyWith(color: colors.primary),
      decoration: InputDecoration(
        hintText: hintText,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 11,
        ),
      ),
    );
  }
}

class ZuriPanel extends StatelessWidget {
  const ZuriPanel({
    required this.child,
    this.padding = const EdgeInsets.all(22),
    super.key,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: colors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(ZuriRadius.panel),
        border: Border.all(color: colors.outline, width: 1.4),
      ),
      child: child,
    );
  }
}

class ZuriFieldLabel extends StatelessWidget {
  const ZuriFieldLabel(this.text, {super.key});

  final String text;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Text(
      text,
      style: ZuriTextStyles.chipLabel.copyWith(color: colors.onSurfaceVariant),
    );
  }
}

class ZuriScreenHeadline extends StatelessWidget {
  const ZuriScreenHeadline(this.text, {super.key});

  final String text;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Text(
      text,
      style: ZuriTextStyles.pageTitle.copyWith(color: colors.primary),
    );
  }
}

class ZuriAvatar extends StatelessWidget {
  const ZuriAvatar({
    required this.label,
    this.color,
    this.size = 44,
    this.badge,
    super.key,
  });

  final String label;
  final Color? color;
  final double size;

  /// Optional widget overlaid at the bottom-right of the avatar.
  /// Typically a flag emoji or status dot wrapped in a small Container.
  final Widget? badge;

  @override
  Widget build(BuildContext context) {
    final circle = Container(
      height: size,
      width: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: color ?? ZuriAvatarColors.forInitial(label),
        shape: BoxShape.circle,
      ),
      child: Text(
        label,
        style: ZuriTextStyles.avatarInitials.copyWith(color: Colors.white),
      ),
    );

    if (badge == null) return circle;

    return SizedBox.square(
      dimension: size,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          circle,
          Positioned(
            right: -2,
            bottom: 3,
            child: badge!,
          ),
        ],
      ),
    );
  }
}

class ZuriAvatarColors {
  const ZuriAvatarColors._();

  static const indigo = Color(0xFF7B68D9);
  static const coral = Color(0xFFE74C3C);
  static const teal = Color(0xFF2E86AB);
  static const amber = Color(0xFFD4845A);
  static const purple = Color(0xFF8E44AD);
  static const forestGreen = Color(0xFF1C7A3E);
  static const red = Color(0xFFC0392B);
  static const slate = Color(0xFF546E7A);

  static Color forInitial(String initial) {
    final first = initial.trim().characters.take(1).toString().toUpperCase();
    return switch (first) {
      'A' || 'H' || 'O' || 'V' => indigo,
      'B' || 'I' || 'P' || 'W' => coral,
      'C' || 'J' || 'Q' || 'X' => teal,
      'D' || 'K' || 'R' || 'Y' => amber,
      'E' || 'L' || 'S' || 'Z' => purple,
      'F' || 'M' || 'T' => forestGreen,
      'G' || 'N' || 'U' => red,
      _ => slate,
    };
  }
}

@Deprecated('Use ZuriAvatarColors.forInitial instead.')
class ZuriAvatarColor {
  const ZuriAvatarColor._();

  static Color fromLabel(String label) => ZuriAvatarColors.forInitial(label);
}
