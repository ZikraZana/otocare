import 'package:flutter/material.dart';
import 'package:otocare/widgets/custom_dropdown.dart';
import 'package:otocare/widgets/custom_text_field.dart';
import 'package:otocare/widgets/date_picker.dart';
import 'package:otocare/widgets/time_selector.dart';
import '../widgets/popup_konfirmasi.dart';

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
  final List<TimeSlot> jamList = [
    TimeSlot(time: "08:00", isAvailable: true),
    TimeSlot(time: "10:00", isAvailable: false),
    TimeSlot(time: "12:00", isAvailable: true),
    TimeSlot(time: "14:00", isAvailable: true),
    TimeSlot(time: "16:00", isAvailable: false),
    TimeSlot(time: "18:00", isAvailable: true),
  ];
  String? selectedJam;
  DateTime? selectedDate;

  bool isFormEnabled = true;
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
    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: bgColor,
        elevation: 0,
        title: const Text(
          'Form Booking',
          style: TextStyle(color: textColor, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        iconTheme: const IconThemeData(color: textColor),
        actions: [
          IconButton(
            icon: Icon(isFormEnabled ? Icons.lock_open : Icons.lock),
            onPressed: () {
              setState(() {
                isFormEnabled = !isFormEnabled;
              });
            },
          ),
        ],
      ),

      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
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
                label: 'Tanggal Booking', // Tambahkan label
                hint: 'Pilih tanggal',
              ),

              const SizedBox(height: 22),

              TimeSelector(
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
      ),
    );
  }
}