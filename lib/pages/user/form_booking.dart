import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

// ==========================================
// MAIN SCREEN: BOOKING FORM (FILTER OTOMATIS)
// ==========================================

class BookingFormScreen extends StatefulWidget {
  const BookingFormScreen({super.key});

  @override
  State<BookingFormScreen> createState() => _BookingFormScreenState();
}

class _BookingFormScreenState extends State<BookingFormScreen> {
  final TextEditingController nameC = TextEditingController();
  final TextEditingController phoneC = TextEditingController();
  final TextEditingController platC = TextEditingController();
  final TextEditingController detailC = TextEditingController();

  // --- VARIABEL DROPDOWN ---
  String? selectedKategori;
  String? selectedJenis;
  String? selectedMerk;

  final List<String> kategoriList = ["KSG", "KSB", "Others"];

  // 1. Variabel Penampung Data Master (Mentah)
  List<Map<String, dynamic>> _masterDataKendaraan = [];

  // 2. List untuk Dropdown (Akan berubah dinamis)
  List<String> jenisList = []; // Daftar Jenis (Motor, Mobil)
  List<String> merkList = []; // Daftar Merk (sesuai jenis yang dipilih)

  // List Jam
  List<BookingTimeSlot> jamList = [];
  String? selectedJam;
  DateTime? selectedDate;

  bool isFormEnabled = true;
  bool isLoading = false;
  bool isCheckingSlots = false;

  // Colors
  static const Color bgColor = Color(0xFF2B2B2B);
  static const Color textColor = Color(0xFFFAFAFA);
  static const Color blueButton = Color(0xFF3991D9);

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _generateInitialTimeSlots();
    _fetchMasterDataKendaraan();
  }

  // --- LOGIC 1: AMBIL DATA & ISI JENIS ---
  Future<void> _fetchMasterDataKendaraan() async {
    try {
      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('data_kendaraan')
          .get();

      // Simpan semua data mentah ke variabel local
      List<Map<String, dynamic>> rawData = [];
      Set<String> uniqueJenis = {};

      for (var doc in snapshot.docs) {
        var data = doc.data() as Map<String, dynamic>;
        rawData.add(data); // Simpan {jenis: "Motor", merk: "Yamaha"}

        if (data['jenis'] != null) {
          uniqueJenis.add(data['jenis']); // Ambil jenis unik saja
        }
      }

      setState(() {
        _masterDataKendaraan = rawData;
        jenisList = uniqueJenis.toList()..sort(); // Isi dropdown Jenis
      });
    } catch (e) {
      print("Gagal ambil master data: $e");
    }
  }

  // --- LOGIC 2: FILTER MERK BERDASARKAN JENIS ---
  void _onJenisChanged(String? jenisBaru) {
    if (jenisBaru == null) return;

    setState(() {
      selectedJenis = jenisBaru;

      // Reset Merk karena Jenis berubah (cegah bug Mobil tapi merk Yamaha)
      selectedMerk = null;

      // Filter Merk yang sesuai dengan Jenis yang dipilih
      Set<String> filteredMerk = {};
      for (var item in _masterDataKendaraan) {
        if (item['jenis'] == jenisBaru && item['merk'] != null) {
          filteredMerk.add(item['merk']);
        }
      }

      merkList = filteredMerk.toList()..sort();
    });
  }

  void _generateInitialTimeSlots() {
    List<BookingTimeSlot> temp = [];
    for (int i = 8; i <= 17; i++) {
      String timeStr = "${i.toString().padLeft(2, '0')}:00";
      temp.add(BookingTimeSlot(time: timeStr, isAvailable: true));
    }
    setState(() {
      jamList = temp;
    });
  }

  void _loadUserData() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        DocumentSnapshot userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();

        if (userDoc.exists && mounted) {
          setState(() {
            nameC.text = userDoc['nama'] ?? '';
            phoneC.text = userDoc['nomor_hp'] ?? '';
          });
        }
      } catch (e) {
        print("Gagal ambil data user: $e");
      }
    }
  }

  Future<void> _checkAvailability(DateTime date) async {
    setState(() {
      isCheckingSlots = true;
      selectedJam = null;
      for (var slot in jamList) {
        slot.isAvailable = true;
      }
    });

    try {
      DateTime startOfDay = DateTime(date.year, date.month, date.day);
      DateTime endOfDay = startOfDay.add(const Duration(days: 1));

      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('bookings')
          .where(
            'tanggal_booking',
            isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay),
          )
          .where('tanggal_booking', isLessThan: Timestamp.fromDate(endOfDay))
          .get();

      List<String> bookedTimes = [];
      for (var doc in snapshot.docs) {
        var data = doc.data() as Map<String, dynamic>;
        if (data['status'] == 'Ditolak' || data['status'] == 'Dibatalkan')
          continue;
        if (data['jam_booking'] != null) {
          bookedTimes.add(data['jam_booking']);
        }
      }

      setState(() {
        for (var slot in jamList) {
          if (bookedTimes.contains(slot.time)) {
            slot.isAvailable = false;
          }
        }
        isCheckingSlots = false;
      });
    } catch (e) {
      print("Error checking slots: $e");
      setState(() => isCheckingSlots = false);
    }
  }

  Future<void> _submitBooking() async {
    if (selectedDate == null ||
        selectedJam == null ||
        selectedKategori == null ||
        selectedJenis == null ||
        selectedMerk == null ||
        platC.text.isEmpty ||
        detailC.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Mohon lengkapi semua data booking!"),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => isLoading = true);

    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      await FirebaseFirestore.instance.collection('bookings').add({
        'uid': user.uid,
        'nama': nameC.text,
        'no_hp': phoneC.text,
        'jenis_kendaraan': selectedJenis,
        'merk_kendaraan': selectedMerk,
        'plat_nomor': platC.text,
        'kategori_servis': selectedKategori,
        'detail_kendala': detailC.text,
        'tanggal_booking': Timestamp.fromDate(selectedDate!),
        'jam_booking': selectedJam,
        'status': 'Menunggu',
        'created_at': FieldValue.serverTimestamp(),
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Booking Berhasil!"),
            backgroundColor: Colors.green,
          ),
        );
        setState(() {
          platC.clear();
          detailC.clear();
          selectedJam = null;
          selectedDate = null;
          selectedKategori = null;
          selectedJenis = null;
          selectedMerk = null;
          isLoading = false;
          _generateInitialTimeSlots();
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Gagal: $e"), backgroundColor: Colors.red),
        );
        setState(() => isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: bgColor,
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
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

            CustomTextField(
              controller: nameC,
              label: 'Nama',
              useGrayFill: true,
              enabled: false,
            ),
            const SizedBox(height: 20),

            DatePickerField(
              selectedDate: selectedDate,
              onDateSelected: (date) {
                setState(() => selectedDate = date);
                _checkAvailability(date);
              },
              label: 'Tanggal Booking',
              hint: 'Pilih tanggal',
            ),
            const SizedBox(height: 22),

            if (isCheckingSlots)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 20),
                child: Center(
                  child: CircularProgressIndicator(color: blueButton),
                ),
              )
            else
              BookingTimeSelector(
                timeSlots: jamList,
                selectedTime: selectedJam,
                onTimeSelected: (time) => setState(() => selectedJam = time),
                enabled: isFormEnabled && selectedDate != null,
                label: selectedDate == null
                    ? 'Pilih Jam (Pilih tanggal dahulu)'
                    : 'Pilih Jam',
              ),

            const SizedBox(height: 22),

            // --- DROPDOWN JENIS (Memanggil Fungsi Filter) ---
            CustomDropdown(
              value: selectedJenis,
              items: jenisList,
              // Saat jenis dipilih, jalankan _onJenisChanged
              onChanged: isFormEnabled ? _onJenisChanged : null,
              label: 'Jenis Kendaraan',
              hint: 'Pilih Jenis (Motor/Mobil)',
              enabled: isFormEnabled,
            ),
            const SizedBox(height: 14),

            // --- DROPDOWN MERK (Dinamis) ---
            CustomDropdown(
              value: selectedMerk,
              items: merkList,
              onChanged: (v) => setState(() => selectedMerk = v),
              label: 'Merk Kendaraan',
              // Hint berubah kalau belum pilih jenis
              hint: selectedJenis == null
                  ? 'Pilih Jenis Kendaraan dulu'
                  : 'Pilih Merk',
              // Disable kalau belum pilih jenis
              enabled: isFormEnabled && selectedJenis != null,
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
              useGrayFill: true,
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
                onPressed: (isFormEnabled && !isLoading)
                    ? () {
                        showDialog(
                          context: context,
                          builder: (_) => PopupKonfirmasi(
                            title:
                                'Apakah Kamu Yakin Ingin Melakukan Booking Servis?',
                            onConfirm: () => _submitBooking(),
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
                child: isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : const Text(
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
// HELPER MODELS & WIDGETS
// ==========================================

class BookingTimeSlot {
  final String time;
  bool isAvailable;
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
    if (!isAvailable) return unavailableColor;
    if (isSelected) return blueButton;
    return availableColor;
  }

  Color _getTextColor(bool isSelected, bool isAvailable, bool enabled) {
    if (!enabled || !isAvailable) return textColor.withOpacity(0.3);
    return textColor;
  }

  String _getStatusText(bool isSelected, bool isAvailable) {
    if (!isAvailable) return 'Penuh';
    if (isSelected) return 'Dipilih';
    return 'Tersedia';
  }
}

class PopupKonfirmasi extends StatelessWidget {
  final String title;
  final VoidCallback? onConfirm;
  final VoidCallback? onCancel;

  const PopupKonfirmasi({
    super.key,
    required this.title,
    this.onConfirm,
    this.onCancel,
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
            BoxShadow(color: Colors.black.withOpacity(0.3), blurRadius: 20),
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
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey[700],
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Tidak',
                      style: TextStyle(color: Colors.white),
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
                      backgroundColor: const Color(0xFFD52C2C),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Iya',
                      style: TextStyle(color: Colors.white),
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
              builder: (context, child) =>
                  Theme(data: ThemeData.dark(), child: child!),
            );
            if (picked != null) onDateSelected(picked);
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
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class CustomDropdown extends StatelessWidget {
  final String? value;
  final List<String> items;
  final ValueChanged<String?>? onChanged;
  final String? label;
  final String hint;
  final bool enabled;

  const CustomDropdown({
    super.key,
    this.value,
    required this.items,
    this.onChanged,
    this.label,
    this.hint = 'Pilih',
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label != null) ...[
          Text(
            label!,
            style: const TextStyle(color: Color(0xFFFAFAFA), fontSize: 14),
          ),
          const SizedBox(height: 8),
        ],
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: enabled ? Colors.white : const Color(0xFF2B2B2B),
            borderRadius: BorderRadius.circular(12),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: value,
              isExpanded: true,
              dropdownColor: Colors.white,
              // Ubah warna icon jika disabled biar terlihat jelas
              icon: Icon(
                Icons.keyboard_arrow_down,
                color: enabled ? Colors.black : Colors.white24,
              ),
              items: items
                  .map(
                    (item) => DropdownMenuItem(
                      value: item,
                      child: Text(
                        item,
                        style: const TextStyle(color: Colors.black),
                      ),
                    ),
                  )
                  .toList(),
              onChanged: enabled ? onChanged : null,
              hint: Text(
                hint,
                style: TextStyle(
                  color: enabled
                      ? Colors.black.withOpacity(0.5)
                      : Colors.white24,
                ),
              ),
            ),
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
  final bool enabled;

  const CustomTextField({
    super.key,
    required this.controller,
    this.hint,
    this.label,
    this.maxLines = 1,
    this.useGrayFill = false,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label != null) ...[
          Text(
            label!,
            style: const TextStyle(color: Color(0xFFFAFAFA), fontSize: 14),
          ),
          const SizedBox(height: 8),
        ],
        TextField(
          controller: controller,
          maxLines: maxLines,
          enabled: enabled,
          style: TextStyle(
            color: enabled ? Colors.black : const Color(0xFFFAFAFA),
          ),
          decoration: InputDecoration(
            filled: true,
            fillColor: enabled ? Colors.white : const Color(0xFF2B2B2B),
            hintText: hint,
            hintStyle: TextStyle(
              color: enabled ? Colors.black.withOpacity(0.5) : Colors.white60,
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 12,
            ),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
      ],
    );
  }
}
