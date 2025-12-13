import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:otocare/pages/auth/login.dart';
import 'package:intl/intl.dart';

class DashboardAdminPage extends StatefulWidget {
  final VoidCallback? onGoToAntrian;

  const DashboardAdminPage({super.key, this.onGoToAntrian});

  @override
  State<DashboardAdminPage> createState() => _DashboardAdminPageState();
}

class _DashboardAdminPageState extends State<DashboardAdminPage> {
  final user = FirebaseAuth.instance.currentUser;

  Future<void> _handleLogout() async {
    bool confirm =
        await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            backgroundColor: const Color(0xFF2B2B2B),
            title: const Text("Keluar?", style: TextStyle(color: Colors.white)),
            content: const Text(
              "Yakin ingin keluar?",
              style: TextStyle(color: Colors.white70),
            ),
            actions: [
              TextButton(
                child: const Text("Batal"),
                onPressed: () => Navigator.pop(context, false),
              ),
              TextButton(
                child: const Text("Ya", style: TextStyle(color: Colors.red)),
                onPressed: () => Navigator.pop(context, true),
              ),
            ],
          ),
        ) ??
        false;

    if (confirm) {
      await FirebaseAuth.instance.signOut();
      if (mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const LoginPage()),
          (route) => false,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance
          .collection('users')
          .doc(user?.uid)
          .snapshots(),
      builder: (context, snapshot) {
        String namaPanggilan = "Admin";

        if (snapshot.hasData && snapshot.data!.exists) {
          var data = snapshot.data!.data() as Map<String, dynamic>;
          String namaLengkap = data['nama'] ?? "Admin";
          namaPanggilan = namaLengkap.split(" ")[0];
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Halo $namaPanggilan! 👋",
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

              // 2. Judul Section
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Jadwal Terdekat",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  GestureDetector(
                    onTap: widget.onGoToAntrian,
                    child: const Text(
                      "Lihat Semua",
                      style: TextStyle(
                        color: Colors.blue,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // 3. LIST ANTRIAN (FILTERED & SORTED)
              StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('bookings')
                    // --- REVISI QUERY ---
                    // 1. Hanya ambil yang statusnya AKTIF
                    .where(
                      'status',
                      whereIn: ['Menunggu', 'Diterima', 'Diproses'],
                    )
                    // 2. Urutkan berdasarkan Waktu Terdekat (Pagi ke Sore)
                    .orderBy('tanggal_booking', descending: false)
                    .orderBy('jam_booking', descending: false)
                    .limit(3)
                    .snapshots(),
                builder: (context, bookingSnap) {
                  if (bookingSnap.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  // Error Handler (Buat Index)
                  if (bookingSnap.hasError) {
                    return Container(
                      padding: const EdgeInsets.all(16),
                      color: Colors.red.withOpacity(0.1),
                      child: SelectableText(
                        // Pakai Selectable biar bisa copas link kalau di emulator
                        "Butuh Index Baru!\nCek Debug Console atau Logcat untuk link pembuatan index.\n\nError: ${bookingSnap.error}",
                        style: const TextStyle(color: Colors.red, fontSize: 12),
                      ),
                    );
                  }

                  if (!bookingSnap.hasData || bookingSnap.data!.docs.isEmpty) {
                    return Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: const Color(0xFF424242),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text(
                        "Tidak ada jadwal aktif saat ini.",
                        style: TextStyle(color: Colors.white54),
                        textAlign: TextAlign.center,
                      ),
                    );
                  }

                  var docs = bookingSnap.data!.docs;

                  return Column(
                    children: docs.asMap().entries.map((entry) {
                      int index = entry.key;
                      var doc = entry.value;
                      var data = doc.data() as Map<String, dynamic>;

                      String nama = data['nama'] ?? 'Tanpa Nama';
                      String status = data['status'] ?? 'Menunggu';
                      String jamManual = data['jam_booking'] ?? '00:00';

                      DateTime? tgl = data['tanggal_booking'] != null
                          ? (data['tanggal_booking'] as Timestamp).toDate()
                          : null;

                      String dateOnly = tgl != null
                          ? DateFormat('d MMM', 'id_ID').format(tgl)
                          : '-';

                      String finalDateDisplay =
                          "$dateOnly, $jamManual WIB • $status";

                      // HIGHLIGHT: Kartu paling atas = Hijau
                      bool isTopOne = (index == 0);

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: _buildQueueCard(
                          name: nama,
                          date: finalDateDisplay,
                          isHighlight: isTopOne,
                        ),
                      );
                    }).toList(),
                  );
                },
              ),

              const SizedBox(height: 30),

              // 4. Menu Grid
              const Text(
                "Menu",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),

              Row(
                children: [
                  _buildMenuCard(
                    icon: Icons.calendar_month,
                    label: "Kelola Antrian",
                    onTap: () {
                      if (widget.onGoToAntrian != null) widget.onGoToAntrian!();
                    },
                  ),
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
    required bool isHighlight,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isHighlight ? const Color(0xFF4CAF50) : const Color(0xFF424242),
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
