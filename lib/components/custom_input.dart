// lib/components/custom_input.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CustomInput extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final bool obscureText;
  final Widget? suffixIcon;
  final TextInputType keyboardType;
  final String? hintText;
  final bool readOnly;  // Added readOnly parameter
  final List<TextInputFormatter>? inputFormatters;  // Added inputFormatters

  const CustomInput({
    super.key,
    required this.label,
    required this.controller,
    this.obscureText = false,
    this.suffixIcon,
    this.keyboardType = TextInputType.text,
    this.hintText,
    this.readOnly = false,  // Default to false
    this.inputFormatters,  // Default null
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,  // Apply inputFormatters
      decoration: InputDecoration(
        labelText: label,
        hintText: hintText,
        border: const OutlineInputBorder(),
        suffixIcon: suffixIcon,
      ),
      readOnly: readOnly,  // Apply readOnly here
    );
  }
}
