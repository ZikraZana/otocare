import 'package:flutter/material.dart';
import 'package:otocare/pages/user/daftar_antrian.dart';
import 'package:otocare/pages/user/riwayat_antrian.dart';

// --- PLACEHOLDER UNTUK HALAMAN YANG BELUM ADA ---
// (Bisa kamu hapus nanti kalau file aslinya sudah ada)
class BerandaPlaceholder extends StatelessWidget {
  const BerandaPlaceholder({super.key});
  @override
  Widget build(BuildContext context) => const Center(child: Text("Halaman Beranda", style: TextStyle(color: Colors.white)));
}

class BookingPlaceholder extends StatelessWidget {
  const BookingPlaceholder({super.key});
  @override
  Widget build(BuildContext context) => const Center(child: Text("Halaman Booking", style: TextStyle(color: Colors.white)));
}
// ------------------------------------------------

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

  // List Halaman (Urutan harus sesuai dengan icon di BottomBar)
  final List<Widget> _pages = [
    const BerandaPlaceholder(),      // Index 0
    const BookingPlaceholder(),      // Index 1
    const DaftarAntrianScreen(),     // Index 2
    const RiwayatAntrianPage(),      // Index 3
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _backgroundColor,

      // --- 1. APP BAR (Satu untuk semua) ---
      appBar: AppBar(
        backgroundColor: _backgroundColor,
        elevation: 0,
        automaticallyImplyLeading: false, // Hilangkan tombol back
        title: Text(
          'OtoCare',
          style: _nunitoTextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
          ),
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
          Expanded(
            child: _pages[_selectedIndex],
          ),
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
          onTap: _onItemTapped,
          type: BottomNavigationBarType.fixed,
          showUnselectedLabels: true,
          selectedLabelStyle: _nunitoTextStyle(fontSize: 12, color: _secondaryColor),
          unselectedLabelStyle: _nunitoTextStyle(fontSize: 12, color: Colors.white60),
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: 'Beranda',
            ),
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