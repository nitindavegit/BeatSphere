import 'package:client/core/theme/app_pallete.dart';
import 'package:flutter/material.dart';

class AuthSignupButton extends StatelessWidget {
  final String buttonText;
  final VoidCallback onTap;
  const AuthSignupButton({
    super.key,
    required this.buttonText,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Pallete.gradient1, Pallete.gradient2],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          fixedSize: const Size(395, 55),
          backgroundColor: Pallete.transparentColor,
          shadowColor: Pallete.transparentColor,
        ),
        onPressed: onTap,
        child: Text(
          buttonText,
          style: const TextStyle(
            fontSize: 19,
            fontWeight: FontWeight.bold,
            color: Pallete.gradient3,
          ),
        ),
      ),
    );
  }
}
