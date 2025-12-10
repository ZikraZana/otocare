import 'package:flutter/material.dart';

class DatePickerField extends StatelessWidget {
  final DateTime? selectedDate; // Ubah jadi nullable
  final ValueChanged<DateTime> onDateSelected;
  final String hint;
  final String? label; // Tambahkan parameter label

  const DatePickerField({
    super.key,
    this.selectedDate, // Tidak wajib diisi
    required this.onDateSelected,
    this.hint = 'Pilih tanggal',
    this.label, // Label opsional
  });

  @override
  Widget build(BuildContext context) {
    // Format tanggal jika sudah dipilih
    String displayText = selectedDate != null
        ? "${selectedDate!.day.toString().padLeft(2, '0')}-${selectedDate!.month.toString().padLeft(2, '0')}-${selectedDate!.year}"
        : '';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Label (opsional)
        if (label != null) ...[
          Text(
            label!,
            style: const TextStyle(color: Colors.white, fontSize: 14),
          ),
          const SizedBox(height: 8),
        ],

        // Date Picker Field
        GestureDetector(
          onTap: () async {
            DateTime? picked = await showDatePicker(
              context: context,
              initialDate: selectedDate ?? DateTime.now(),
              firstDate: DateTime.now(),
              lastDate: DateTime.now().add(const Duration(days: 30)),
              builder: (context, child) {
                return Theme(
                  data: ThemeData.dark().copyWith(
                    colorScheme: const ColorScheme.dark(
                      primary: Color(0xFF3991D9),
                      onPrimary: Colors.white,
                      surface: Color(0xFF2B2B2B),
                      onSurface: Colors.white,
                    ),
                    textButtonTheme: TextButtonThemeData(
                      style: TextButton.styleFrom(
                        foregroundColor: Color(0xFF3991D9),
                      ),
                    ),
                    dialogTheme: DialogThemeData(
                      backgroundColor: const Color(0xFF2B2B2B),
                    ),
                  ),
                  child: child!,
                );
              },
            );

            if (picked != null) {
              onDateSelected(picked);
            }
          },
          child: AbsorbPointer(
            child: TextField(
              controller: TextEditingController(text: displayText),
              style: const TextStyle(color: Colors.black),
              decoration: InputDecoration(
                hintText: hint,
                hintStyle: TextStyle(color: Colors.black.withOpacity(0.5)),
                filled: true,
                fillColor: Colors.white,
                // Icon kalender di kiri
                prefixIcon: const Icon(
                  Icons.calendar_today,
                  color: Color(0xFF3991D9),
                  size: 20,
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 12,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(
                    color: Color(0xFF3991D9),
                    width: 1.5,
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}