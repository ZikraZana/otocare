import 'package:cloud_firestore/cloud_firestore.dart'; // Akses Database
import 'package:firebase_auth/firebase_auth.dart';     // Akses Auth
import 'package:flutter/material.dart';
import 'package:otocare/pages/auth/login.dart';        // Arahkan ke Login saat logout

class DashboardAdminPage extends StatefulWidget {
  // Callback ini dipanggil saat tombol menu "Kelola Antrian" diklik
  final VoidCallback? onGoToAntrian;

  const DashboardAdminPage({super.key, this.onGoToAntrian});

  @override
  State<DashboardAdminPage> createState() => _DashboardAdminPageState();
}

class _DashboardAdminPageState extends State<DashboardAdminPage> {
  // Ambil user yang sedang login
  final user = FirebaseAuth.instance.currentUser;

  // Fungsi Logout
  Future<void> _handleLogout() async {
    await FirebaseAuth.instance.signOut();
    if (mounted) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const LoginPage()),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // StreamBuilder membungkus seluruh halaman agar data real-time
    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance
          .collection('users')
          .doc(user?.uid)
          .snapshots(),
      builder: (context, snapshot) {
        // Default nama kalau loading/error
        String namaPanggilan = "Admin";

        if (snapshot.hasData && snapshot.data!.exists) {
          var data = snapshot.data!.data() as Map<String, dynamic>;
          // Ambil nama dari database, ambil kata pertama saja biar akrab
          String namaLengkap = data['nama'] ?? "Admin";
          namaPanggilan = namaLengkap.split(" ")[0]; 
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Salam Sapaan (Dinamis + Tombol Logout)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween, // Biar logout di kanan
                children: [
                  Text(
                    "Halo $namaPanggilan! 👋", // <--- Berubah sesuai database
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    onPressed: _handleLogout,
                    icon: const Icon(Icons.logout, color: Colors.redAccent),
                    tooltip: "Keluar",
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // 2. Bagian Antrian (Masih Statis sesuai request)
              const Text(
                "Antrian saat ini",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),

              // List Item Antrian
              _buildQueueCard(
                name: "Damara Rafiandriza P",
                date: "12 Desember 2026 - 16:00 WIB",
                isActive: true,
              ),
              const SizedBox(height: 12),
              _buildQueueCard(
                name: "Nathania Ardelia",
                date: "12 Desember 2026 - 18:00 WIB",
                isActive: false,
              ),
              const SizedBox(height: 12),
              _buildQueueCard(
                name: "Endah Retno Kinanti",
                date: "13 Desember 2026 - 08:00 WIB",
                isActive: false,
              ),

              const SizedBox(height: 30),

              // 3. Bagian Menu
              const Text(
                "Menu",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),

              // Grid Menu
              Row(
                children: [
                  _buildMenuCard(
                    icon: Icons.calendar_month,
                    label: "Kelola Antrian",
                    onTap: () {
                      // Panggil fungsi untuk pindah tab di parent
                      if (widget.onGoToAntrian != null) widget.onGoToAntrian!();
                    },
                  ),
                  // Tambah menu lain di sini jika perlu
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildQueueCard({
    required String name,
    required String date,
    required bool isActive,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isActive ? const Color(0xFF4CAF50) : const Color(0xFF424242),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            name,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 4),
          Text(date, style: const TextStyle(color: Colors.white, fontSize: 14)),
        ],
      ),
    );
  }

  Widget _buildMenuCard({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 150,
        height: 120,
        margin: const EdgeInsets.only(right: 12),
        decoration: BoxDecoration(
          color: const Color(0xFF424242),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white, size: 32),
            const SizedBox(height: 8),
            Text(
              label,
              style: const TextStyle(color: Colors.white, fontSize: 14),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}