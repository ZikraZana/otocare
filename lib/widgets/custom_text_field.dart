import 'package:flutter/material.dart';

class CustomTextField extends StatelessWidget {
  final TextEditingController controller;
  final String? hint;
  final String? label;
  final int maxLines;
  final bool useGrayFill;
  final TextInputType keyboard;
  final bool enabled; // Parameter untuk enable/disable
  final Widget? prefixIcon;
  final Widget? suffixIcon;

  // Color constants
  static const Color bgColor = Color(0xFF2B2B2B);
  static const Color textColor = Color(0xFFFAFAFA);
  static const Color inputGrayFill60 = Color(0x996B6B6B);
  static const Color blueButton = Color(0xFF3991D9);
  static const Color disabledColor = Color(0xFF4A4A4A);

  const CustomTextField({
    super.key,
    required this.controller,
    this.hint,
    this.label,
    this.maxLines = 1,
    this.useGrayFill = false,
    this.keyboard = TextInputType.text,
    this.enabled = true, // Default enabled
    this.prefixIcon,
    this.suffixIcon,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Label (opsional)
        if (label != null) ...[
          Text(
            label!,
            style: TextStyle(
              color:textColor,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 8),
        ],

        // TextField
        TextField(
          controller: controller,
          keyboardType: keyboard,
          maxLines: maxLines,
          enabled: enabled,
          style: TextStyle(
            color: enabled ? Colors.black : textColor,
          ),
          decoration: InputDecoration(
            filled: true,
            // Enable: Background putih, Disable: Background hitam
            fillColor: enabled ? Colors.white : bgColor,
            hintText: hint,
            hintStyle: TextStyle(
              color: enabled
                  ? Colors.black.withOpacity(0.5)
                  : textColor.withOpacity(0.6),
            ),
            prefixIcon: prefixIcon,
            suffixIcon: suffixIcon,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 12,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: enabled ? Colors.grey.shade300 : inputGrayFill60,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            disabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: inputGrayFill60),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: blueButton, width: 1.5),
            ),
          ),
        ),
      ],
    );
  }
}