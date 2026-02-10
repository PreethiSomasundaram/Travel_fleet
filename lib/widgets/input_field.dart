import 'package:flutter/material.dart';

/// A reusable text input field with label, validation, and optional suffix.
class InputField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final TextInputType keyboardType;
  final String? Function(String?)? validator;
  final bool readOnly;
  final VoidCallback? onTap;
  final Widget? suffixIcon;
  final int maxLines;

  const InputField({
    super.key,
    required this.label,
    required this.controller,
    this.keyboardType = TextInputType.text,
    this.validator,
    this.readOnly = false,
    this.onTap,
    this.suffixIcon,
    this.maxLines = 1,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        validator: validator,
        readOnly: readOnly,
        onTap: onTap,
        maxLines: maxLines,
        decoration: InputDecoration(
          labelText: label,
          suffixIcon: suffixIcon,
        ),
      ),
    );
  }
}
