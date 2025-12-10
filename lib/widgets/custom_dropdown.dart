import 'package:flutter/material.dart';

class CustomDropdown extends StatelessWidget {
  final String? value;
  final List<String> items;
  final ValueChanged<String?>? onChanged;
  final String? label;
  final String hint;
  final bool enabled;
  final Widget? prefixIcon;

  // Color constants
  static const Color bgColor = Color(0xFF2B2B2B);
  static const Color textColor = Color(0xFFFAFAFA);
  static const Color blueButton = Color(0xFF3991D9);

  const CustomDropdown({
    super.key,
    this.value,
    required this.items,
    this.onChanged,
    this.label,
    this.hint = 'Pilih',
    this.enabled = true,
    this.prefixIcon,
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
              color: textColor,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 8),
        ],

        // Dropdown Container
        Container(
          width: double.infinity, // Full width
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            // Enable: Background putih, Disable: Background hitam
            color: enabled ? Colors.white : bgColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: enabled ? Colors.grey.shade300 : Colors.grey.shade700,
              width: 1,
            ),
          ),
          child: Row(
            children: [
              // Prefix Icon (opsional)
              if (prefixIcon != null) ...[
                prefixIcon!,
                const SizedBox(width: 8),
              ],

              // Dropdown
              Expanded(
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: value,
                    isExpanded: true, // Full width
                    dropdownColor: enabled ? Colors.white : bgColor,
                    icon: Icon(
                      Icons.keyboard_arrow_down,
                      color: enabled ? Colors.black : textColor,
                    ),
                    items: items.map((item) {
                      return DropdownMenuItem(
                        value: item,
                        child: Text(
                          item,
                          style: TextStyle(
                            color: enabled ? Colors.black : textColor,
                          ),
                        ),
                      );
                    }).toList(),
                    onChanged: enabled ? onChanged : null,
                    hint: Text(
                      hint,
                      style: TextStyle(
                        color: enabled
                            ? Colors.black.withOpacity(0.5)
                            : textColor.withOpacity(0.6),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}