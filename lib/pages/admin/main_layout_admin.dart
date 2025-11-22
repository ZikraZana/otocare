import 'package:flutter/material.dart';
import 'package:otocare/pages/admin/dashboard_admin.dart';
import 'package:otocare/pages/admin/kelola_antrian.dart';

class MainLayoutAdmin extends StatefulWidget {
  const MainLayoutAdmin({super.key});

  @override
  State<MainLayoutAdmin> createState() => _MainLayoutAdminState();
}

class _MainLayoutAdminState extends State<MainLayoutAdmin> {
  int _selectedIndex = 0;

  // Fungsi untuk mengganti halaman saat menu bawah diklik
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  // Fungsi khusus untuk tombol "Kelola Antrian" yang ada di dalam Dashboard
  void _goToAntrianTab() {
    setState(() {
      _selectedIndex = 1; // Pindah ke tab index 1 (Antrian)
    });
  }

  @override
  Widget build(BuildContext context) {
    // List halaman disimpan di sini agar bisa diakses index-nya
    final List<Widget> pages = [
      // Halaman 0: Dashboard (kita oper fungsi _goToAntrianTab ke dalamnya)
      DashboardAdminPage(onGoToAntrian: _goToAntrianTab),

      // Halaman 1: Kelola Antrian
      const KelolaAntrian(),
    ];

    return Scaffold(
      backgroundColor: const Color(0xFF212121),

      // --- APP BAR (Satu untuk semua halaman) ---
      appBar: AppBar(
        backgroundColor: const Color(0xFF212121),
        elevation: 0,
        automaticallyImplyLeading: false,
        title: const Text(
          "OtoCare",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.0),
          child: Container(color: Colors.grey[800], height: 1.0),
        ),
      ),

      // --- BODY (Isi berubah sesuai menu yg dipilih) ---
      body: pages[_selectedIndex],

      // --- BOTTOM NAVIGATION BAR ---
      bottomNavigationBar: Theme(
        data: Theme.of(context).copyWith(
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
        ),
        child: BottomNavigationBar(
          backgroundColor: const Color(0xFF212121),
          selectedItemColor: const Color(0xFFD72638), // Merah Branding
          unselectedItemColor: Colors.grey,
          currentIndex: _selectedIndex,
          onTap: _onItemTapped,
          type: BottomNavigationBarType.fixed,
          selectedFontSize: 12,
          unselectedFontSize: 12,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_filled),
              label: 'Beranda',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.calendar_today),
              label: 'Antrian',
            ),
          ],
        ),
      ),
    );
  }
}
