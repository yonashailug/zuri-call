import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AuthColors {
  const AuthColors._();

  static const background = Color(0xFFFFF6EF);
  static const ink = Color(0xFF0B4A2F);
  static const muted = Color(0xFF706961);
  static const border = Color(0xFFAAA298);
  static const control = Color(0xFFF0EADD);
  static const field = Color(0xFFFFFCFA);
  static const disabled = Color(0xFFB8C8C0);
}

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
      backgroundColor: AuthColors.background,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(28, 22, 28, 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  AuthCircleButton(
                    icon: Icons.arrow_back_rounded,
                    onPressed: onBack ?? () => Navigator.maybePop(context),
                  ),
                  AuthCircleButton(
                    icon: Icons.close_rounded,
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

class AuthCircleButton extends StatelessWidget {
  const AuthCircleButton({
    required this.icon,
    required this.onPressed,
    super.key,
  });

  final IconData icon;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 50,
      width: 50,
      child: IconButton(
        onPressed: onPressed,
        icon: Icon(icon),
        color: AuthColors.ink,
        style: IconButton.styleFrom(
          backgroundColor: AuthColors.control,
          shape: const CircleBorder(),
        ),
      ),
    );
  }
}

class AuthHeadline extends StatelessWidget {
  const AuthHeadline(this.text, {super.key});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        color: AuthColors.ink,
        fontFamily: 'Georgia',
        fontSize: 35,
        height: 1.08,
        fontWeight: FontWeight.w700,
        letterSpacing: 0,
      ),
    );
  }
}

class AuthFieldLabel extends StatelessWidget {
  const AuthFieldLabel(this.text, {super.key});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        color: AuthColors.muted,
        fontSize: 17,
        fontWeight: FontWeight.w700,
      ),
    );
  }
}

class AuthTextField extends StatelessWidget {
  const AuthTextField({
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
    return TextField(
      controller: controller,
      autofocus: autofocus,
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      inputFormatters: inputFormatters,
      onChanged: onChanged,
      cursorColor: AuthColors.ink,
      style: const TextStyle(
        color: AuthColors.ink,
        fontSize: 22,
        fontWeight: FontWeight.w700,
      ),
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: const TextStyle(
          color: AuthColors.muted,
          fontWeight: FontWeight.w500,
        ),
        filled: true,
        fillColor: AuthColors.field,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 18,
          vertical: 17,
        ),
        border: _border(AuthColors.border),
        enabledBorder: _border(AuthColors.border),
        focusedBorder: _border(AuthColors.ink),
      ),
    );
  }

  static OutlineInputBorder _border(Color color) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: BorderSide(color: color, width: 1.4),
    );
  }
}

class AuthPillButton extends StatelessWidget {
  const AuthPillButton({
    required this.label,
    required this.onPressed,
    super.key,
  });

  final String label;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final enabled = onPressed != null;
    return SizedBox(
      height: 66,
      width: double.infinity,
      child: TextButton(
        onPressed: onPressed,
        style: TextButton.styleFrom(
          backgroundColor: enabled ? AuthColors.ink : AuthColors.disabled,
          foregroundColor: Colors.white,
          shape: const StadiumBorder(),
          textStyle: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w700,
          ),
        ),
        child: Text(label),
      ),
    );
  }
}
