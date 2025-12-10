import 'package:flutter/material.dart';

// Model untuk status waktu
class TimeSlot {
  final String time;
  final bool isAvailable;

  TimeSlot({
    required this.time,
    this.isAvailable = true,
  });
}

class TimeSelector extends StatelessWidget {
  final List<TimeSlot> timeSlots;
  final String? selectedTime;
  final ValueChanged<String> onTimeSelected;
  final bool enabled;
  final String? label;

  // Color constants
  static const Color bgColor = Color(0xFF2B2B2B);
  static const Color textColor = Color(0xFFFAFAFA);
  static const Color blueButton = Color(0xFF3991D9);
  static const Color unavailableColor = Color(0xFF3A3A3A);
  static const Color availableColor = Color.fromARGB(255, 98, 98, 98);

  const TimeSelector({
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
        // Label (opsional)
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

        // Horizontal Scrollable Time Selector
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
                        color: _getBackgroundColor(isSelected, slot.isAvailable),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            slot.time,
                            style: TextStyle(
                              color: _getTextColor(isSelected, slot.isAvailable, enabled),
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            _getStatusText(isSelected, slot.isAvailable),
                            style: TextStyle(
                              color: _getTextColor(isSelected, slot.isAvailable, enabled).withOpacity(0.8),
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

  // Helper: Background color berdasarkan status
  Color _getBackgroundColor(bool isSelected, bool isAvailable) {
    if (isSelected && isAvailable) {
      return blueButton;
    } else if (!isAvailable) {
      return unavailableColor;
    } else {
      return availableColor;
    }
  }

  // Helper: Text color berdasarkan status
  Color _getTextColor(bool isSelected, bool isAvailable, bool enabled) {
    if (!enabled) {
      return textColor.withOpacity(0.3);
    } else {
      return textColor;
    }
  }

  // Helper: Status text
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