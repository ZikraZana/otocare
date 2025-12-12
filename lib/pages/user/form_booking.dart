import 'package:flutter/material.dart';

// ==========================================
// MAIN SCREEN: BOOKING FORM
// ==========================================

class BookingFormScreen extends StatefulWidget {
  const BookingFormScreen({super.key});

  @override
  State<BookingFormScreen> createState() => _BookingFormScreenState();
}

class _BookingFormScreenState extends State<BookingFormScreen> {
  final TextEditingController nameC = TextEditingController();
  final TextEditingController phoneC = TextEditingController();
  final TextEditingController jenisC = TextEditingController();
  final TextEditingController merkC = TextEditingController();
  final TextEditingController platC = TextEditingController();
  final TextEditingController detailC = TextEditingController();

  String? selectedKategori;
  final List<String> kategoriList = ["KSG", "KSB", "Others"];

  final List<BookingTimeSlot> jamList = [
    BookingTimeSlot(time: "08:00", isAvailable: true),
    BookingTimeSlot(time: "10:00", isAvailable: false),
    BookingTimeSlot(time: "12:00", isAvailable: true),
    BookingTimeSlot(time: "14:00", isAvailable: true),
    BookingTimeSlot(time: "16:00", isAvailable: false),
    BookingTimeSlot(time: "18:00", isAvailable: true),
  ];

  String? selectedJam;
  DateTime? selectedDate;
  bool isFormEnabled = true;

  // Colors
  static const Color bgColor = Color(0xFF2B2B2B);
  static const Color textColor = Color(0xFFFAFAFA);
  static const Color blueButton = Color(0xFF3991D9);

  @override
  void dispose() {
    nameC.dispose();
    phoneC.dispose();
    jenisC.dispose();
    merkC.dispose();
    platC.dispose();
    detailC.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // TIDAK PAKAI SCAFFOLD/APPBAR LAGI
    return Container(
      color: bgColor,
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- HEADER CUSTOM ---
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Form Booking',
                  style: TextStyle(
                    color: textColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 24,
                    fontFamily: 'Nunito',
                  ),
                ),
                IconButton(
                  icon: Icon(isFormEnabled ? Icons.lock_open : Icons.lock),
                  color: textColor,
                  onPressed: () {
                    setState(() {
                      isFormEnabled = !isFormEnabled;
                    });
                  },
                ),
              ],
            ),
            const SizedBox(height: 20),

            // ---------------------
            CustomTextField(
              controller: nameC,
              label: 'Nama',
              hint: 'Nama lengkap',
              useGrayFill: true,
              enabled: false,
            ),
            const SizedBox(height: 20),
            DatePickerField(
              selectedDate: selectedDate,
              onDateSelected: (date) => setState(() => selectedDate = date),
              label: 'Tanggal Booking',
              hint: 'Pilih tanggal',
            ),
            const SizedBox(height: 22),

            BookingTimeSelector(
              timeSlots: jamList,
              selectedTime: selectedJam,
              onTimeSelected: (time) => setState(() => selectedJam = time),
              enabled: isFormEnabled,
              label: 'Pilih Jam',
            ),

            const SizedBox(height: 22),
            CustomTextField(
              controller: jenisC,
              label: 'Jenis Kendaraan',
              hint: 'Motor / Mobil',
              enabled: isFormEnabled,
            ),
            const SizedBox(height: 14),
            CustomTextField(
              controller: merkC,
              label: 'Merk Kendaraan',
              hint: 'Contoh: Yamaha',
              enabled: isFormEnabled,
            ),
            const SizedBox(height: 14),
            CustomTextField(
              controller: platC,
              label: 'No Plat',
              hint: 'B 1234 XYZ',
              enabled: isFormEnabled,
            ),
            const SizedBox(height: 16),
            CustomTextField(
              controller: phoneC,
              label: 'No Handphone',
              hint: '08xxxxxxxxx',
              useGrayFill: true,
              keyboard: TextInputType.phone,
              enabled: false,
            ),
            const SizedBox(height: 14),
            CustomDropdown(
              value: selectedKategori,
              items: kategoriList,
              onChanged: (v) => setState(() => selectedKategori = v),
              label: 'Kategori Servis',
              hint: 'Pilih Kategori',
              enabled: isFormEnabled,
            ),
            const SizedBox(height: 14),
            CustomTextField(
              controller: detailC,
              label: 'Detail Kendala',
              hint: 'Jelaskan kerusakan',
              maxLines: 3,
              enabled: isFormEnabled,
            ),
            const SizedBox(height: 22),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: isFormEnabled
                    ? () {
                        showDialog(
                          context: context,
                          builder: (_) => const PopupKonfirmasi(
                            title:
                                'Apakah Kamu Yakin Ingin Melakukan Booking Servis?',
                          ),
                        );
                      }
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: blueButton,
                  disabledBackgroundColor: const Color(0xFF4A4A4A),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Booking Sekarang',
                  style: TextStyle(
                    color: textColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}

// ==========================================
// HELPER WIDGETS
// ==========================================

class PopupKonfirmasi extends StatelessWidget {
  final String title;
  final VoidCallback? onConfirm;
  final VoidCallback? onCancel;
  final String confirmText;
  final String cancelText;

  const PopupKonfirmasi({
    super.key,
    required this.title,
    this.onConfirm,
    this.onCancel,
    this.confirmText = 'Iya',
    this.cancelText = 'Tidak',
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: const Color(0xFF2B2B2B),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.white,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      if (onCancel != null) onCancel!();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey[700],
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    child: Text(
                      cancelText,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      if (onConfirm != null) onConfirm!();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromARGB(255, 217, 57, 57),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    child: Text(
                      confirmText,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class DatePickerField extends StatelessWidget {
  final DateTime? selectedDate;
  final ValueChanged<DateTime> onDateSelected;
  final String hint;
  final String? label;

  const DatePickerField({
    super.key,
    this.selectedDate,
    required this.onDateSelected,
    this.hint = 'Pilih tanggal',
    this.label,
  });

  @override
  Widget build(BuildContext context) {
    String displayText = selectedDate != null
        ? "${selectedDate!.day.toString().padLeft(2, '0')}-${selectedDate!.month.toString().padLeft(2, '0')}-${selectedDate!.year}"
        : '';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label != null) ...[
          Text(
            label!,
            style: const TextStyle(color: Colors.white, fontSize: 14),
          ),
          const SizedBox(height: 8),
        ],
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
                        foregroundColor: const Color(0xFF3991D9),
                      ),
                    ),
                    dialogTheme: const DialogThemeData(
                      backgroundColor: Color(0xFF2B2B2B),
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

class BookingTimeSlot {
  final String time;
  final bool isAvailable;

  BookingTimeSlot({required this.time, this.isAvailable = true});
}

class BookingTimeSelector extends StatelessWidget {
  final List<BookingTimeSlot> timeSlots;
  final String? selectedTime;
  final ValueChanged<String> onTimeSelected;
  final bool enabled;
  final String? label;

  static const Color bgColor = Color(0xFF2B2B2B);
  static const Color textColor = Color(0xFFFAFAFA);
  static const Color blueButton = Color(0xFF3991D9);
  static const Color unavailableColor = Color(0xFF3A3A3A);
  static const Color availableColor = Color.fromARGB(255, 98, 98, 98);

  const BookingTimeSelector({
    super.key,
    required this.timeSlots,
    this.selectedTime,
    required this.onTimeSelected,
    this.enabled = true,
    this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label != null) ...[
          Text(
            label!,
            style: TextStyle(
              color: enabled ? textColor : textColor.withOpacity(0.5),
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 12),
        ],
        Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(12),
          ),
          child: SizedBox(
            height: 68,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: timeSlots.length,
              itemBuilder: (context, index) {
                final slot = timeSlots[index];
                final isSelected = selectedTime == slot.time;
                final canSelect = enabled && slot.isAvailable;

                return Padding(
                  padding: EdgeInsets.only(
                    right: index < timeSlots.length - 1 ? 6 : 0,
                  ),
                  child: GestureDetector(
                    onTap: canSelect ? () => onTimeSelected(slot.time) : null,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      curve: Curves.easeInOut,
                      width: 90,
                      padding: const EdgeInsets.symmetric(
                        vertical: 12,
                        horizontal: 12,
                      ),
                      decoration: BoxDecoration(
                        color: _getBackgroundColor(
                          isSelected,
                          slot.isAvailable,
                        ),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            slot.time,
                            style: TextStyle(
                              color: _getTextColor(
                                isSelected,
                                slot.isAvailable,
                                enabled,
                              ),
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            _getStatusText(isSelected, slot.isAvailable),
                            style: TextStyle(
                              color: _getTextColor(
                                isSelected,
                                slot.isAvailable,
                                enabled,
                              ).withOpacity(0.8),
                              fontSize: 9,
                              fontWeight: FontWeight.w500,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  Color _getBackgroundColor(bool isSelected, bool isAvailable) {
    if (isSelected && isAvailable) {
      return blueButton;
    } else if (!isAvailable) {
      return unavailableColor;
    } else {
      return availableColor;
    }
  }

  Color _getTextColor(bool isSelected, bool isAvailable, bool enabled) {
    if (!enabled) {
      return textColor.withOpacity(0.3);
    } else {
      return textColor;
    }
  }

  String _getStatusText(bool isSelected, bool isAvailable) {
    if (isSelected && isAvailable) {
      return 'Dipilih';
    } else if (!isAvailable) {
      return 'Tidak Tersedia';
    } else {
      return 'Tersedia';
    }
  }
}

class CustomDropdown extends StatelessWidget {
  final String? value;
  final List<String> items;
  final ValueChanged<String?>? onChanged;
  final String? label;
  final String hint;
  final bool enabled;
  final Widget? prefixIcon;

  static const Color bgColor = Color(0xFF2B2B2B);
  static const Color textColor = Color(0xFFFAFAFA);

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
        if (label != null) ...[
          Text(label!, style: TextStyle(color: textColor, fontSize: 14)),
          const SizedBox(height: 8),
        ],
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: enabled ? Colors.white : bgColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: enabled ? Colors.grey.shade300 : Colors.grey.shade700,
              width: 1,
            ),
          ),
          child: Row(
            children: [
              if (prefixIcon != null) ...[
                prefixIcon!,
                const SizedBox(width: 8),
              ],
              Expanded(
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: value,
                    isExpanded: true,
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

class CustomTextField extends StatelessWidget {
  final TextEditingController controller;
  final String? hint;
  final String? label;
  final int maxLines;
  final bool useGrayFill;
  final TextInputType keyboard;
  final bool enabled;
  final Widget? prefixIcon;
  final Widget? suffixIcon;

  static const Color bgColor = Color(0xFF2B2B2B);
  static const Color textColor = Color(0xFFFAFAFA);
  static const Color inputGrayFill60 = Color(0x996B6B6B);
  static const Color blueButton = Color(0xFF3991D9);

  const CustomTextField({
    super.key,
    required this.controller,
    this.hint,
    this.label,
    this.maxLines = 1,
    this.useGrayFill = false,
    this.keyboard = TextInputType.text,
    this.enabled = true,
    this.prefixIcon,
    this.suffixIcon,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label != null) ...[
          Text(label!, style: TextStyle(color: textColor, fontSize: 14)),
          const SizedBox(height: 8),
        ],
        TextField(
          controller: controller,
          keyboardType: keyboard,
          maxLines: maxLines,
          enabled: enabled,
          style: TextStyle(color: enabled ? Colors.black : textColor),
          decoration: InputDecoration(
            filled: true,
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
