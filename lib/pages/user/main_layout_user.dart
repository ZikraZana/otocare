import 'package:flutter/material.dart';
import 'dashboard_user.dart';
import 'form_booking.dart';
import 'daftar_antrian.dart';
import 'riwayat_antrian.dart';

class MainLayoutUser extends StatefulWidget {
  const MainLayoutUser({super.key});

  @override
  State<MainLayoutUser> createState() => _MainLayoutUserState();
}

class _MainLayoutUserState extends State<MainLayoutUser> {
  int _selectedIndex = 0; // Default ke Beranda (index 0)

  // --- STYLE CONSTANTS ---
  static const Color _backgroundColor = Color(0xFF333333);
  static const Color _secondaryColor = Color(0xFFE53935);
  static const Color _neutralColor = Color(0xFF6B6B6B);

  TextStyle _nunitoTextStyle({
    Color color = Colors.white,
    double fontSize = 16,
    FontWeight fontWeight = FontWeight.normal,
  }) {
    return TextStyle(
      fontFamily: 'Nunito',
      color: color,
      fontSize: fontSize,
      fontWeight: fontWeight,
    );
  }

  // Fungsi untuk mengganti tab dari halaman anak (misal: dari Dashboard)
  void _changeTab(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    // List Halaman
    // Kita passing fungsi _changeTab ke Dashboard agar tombolnya berfungsi
    final List<Widget> pages = [
      DashboardPage(onTabChange: _changeTab), // Index 0
      const BookingFormScreen(), // Index 1
      const DaftarAntrianScreen(), // Index 2
      const RiwayatAntrianPage(), // Index 3
    ];

    return Scaffold(
      backgroundColor: _backgroundColor,

      // --- 1. APP BAR (Satu untuk semua halaman) ---
      appBar: AppBar(
        backgroundColor: _backgroundColor,
        elevation: 0,
        automaticallyImplyLeading: false, // Hilangkan tombol back default
        title: Text(
          'OtoCare',
          style: _nunitoTextStyle(fontSize: 32, fontWeight: FontWeight.bold),
        ),
      ),

      body: Column(
        children: [
          // --- 2. DIVIDER (Pemisah AppBar & Body) ---
          Divider(
            color: _neutralColor.withOpacity(0.5),
            thickness: 1,
            height: 1,
          ),

          // --- 3. KONTEN BERUBAH DI SINI ---
          Expanded(child: pages[_selectedIndex]),
        ],
      ),

      // --- 4. BOTTOM NAVIGATION BAR ---
      bottomNavigationBar: Theme(
        data: Theme.of(context).copyWith(
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
        ),
        child: BottomNavigationBar(
          backgroundColor: _backgroundColor,
          selectedItemColor: _secondaryColor,
          unselectedItemColor: Colors.white.withOpacity(0.6),
          currentIndex: _selectedIndex,
          onTap: (index) {
            setState(() {
              _selectedIndex = index;
            });
          },
          type: BottomNavigationBarType.fixed,
          showUnselectedLabels: true,
          selectedLabelStyle: _nunitoTextStyle(
            fontSize: 12,
            color: _secondaryColor,
          ),
          unselectedLabelStyle: _nunitoTextStyle(
            fontSize: 12,
            color: Colors.white60,
          ),
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Beranda'),
            BottomNavigationBarItem(
              icon: Icon(Icons.calendar_today),
              label: 'Booking',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.calendar_month),
              label: 'Antrian',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.history),
              label: 'Riwayat',
            ),
          ],
        ),
      ),
    );
  }
}
