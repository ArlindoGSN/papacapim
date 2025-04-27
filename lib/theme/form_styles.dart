import 'package:flutter/material.dart';

class FormStyles {
  static InputDecoration inputDecoration({
    required String label,
    required IconData icon,
    String? hint,
  }) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      prefixIcon: Icon(icon),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: const BorderSide(width: 2),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: BorderSide(
          color: Colors.grey.shade300,
          width: 2,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: const BorderSide(
          color: Colors.green,
          width: 2,
        ),
      ),
      filled: true,
      fillColor: Colors.grey.shade50,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 16,
      ),
    );
  }

  static ButtonStyle elevatedButtonStyle(BuildContext context) {
    return ElevatedButton.styleFrom(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(30),
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: 32,
        vertical: 16,
      ),
      backgroundColor: Theme.of(context).colorScheme.primary,
      foregroundColor: Theme.of(context).colorScheme.onPrimary,
    );
  }
}