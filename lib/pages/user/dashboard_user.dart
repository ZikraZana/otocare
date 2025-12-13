import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:otocare/pages/auth/login.dart'; // Import halaman Login

class DashboardPage extends StatefulWidget {
  // Callback untuk ganti tab di MainLayoutUser
  final Function(int) onTabChange;

  const DashboardPage({super.key, required this.onTabChange});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  User? user = FirebaseAuth.instance.currentUser;

  // --- FUNGSI LOGOUT ---
  Future<void> _handleLogout() async {
    // Tampilkan konfirmasi dialog dulu biar ga kepencet
    bool confirm =
        await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            backgroundColor: const Color(0xFF2B2B2B),
            title: const Text("Keluar?", style: TextStyle(color: Colors.white)),
            content: const Text(
              "Apakah kamu yakin ingin keluar dari akun?",
              style: TextStyle(color: Colors.white70),
            ),
            actions: [
              TextButton(
                child: const Text("Batal"),
                onPressed: () => Navigator.pop(context, false),
              ),
              TextButton(
                child: const Text(
                  "Ya, Keluar",
                  style: TextStyle(color: Colors.red),
                ),
                onPressed: () => Navigator.pop(context, true),
              ),
            ],
          ),
        ) ??
        false;

    if (confirm) {
      await FirebaseAuth.instance.signOut();
      if (mounted) {
        // Kembali ke halaman Login & Hapus semua rute sebelumnya
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const LoginPage()),
          (route) => false,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Background sesuai tema MainLayout
    return Container(
      color: const Color(0xFF1A1A1A),
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 15),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ========== 1. HEADER (GREETING + LOGOUT) ==========
              StreamBuilder<DocumentSnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('users')
                    .doc(user?.uid)
                    .snapshots(),
                builder: (context, snapshot) {
                  String greetingName = "User";
                  if (snapshot.hasData && snapshot.data!.exists) {
                    var data = snapshot.data!.data() as Map<String, dynamic>;
                    String fullName = data['nama'] ?? "User";
                    greetingName = fullName.split(" ")[0]; // Ambil nama depan
                  }

                  return Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Halo $greetingName! 👋",
                        style: const TextStyle(
                          fontFamily: "Nunito",
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      // TOMBOL LOGOUT
                      IconButton(
                        onPressed: _handleLogout,
                        icon: const Icon(
                          Icons.logout_rounded,
                          color: Colors.redAccent,
                        ),
                        tooltip: "Keluar",
                      ),
                    ],
                  );
                },
              ),

              const SizedBox(height: 25),

              // ========== FORM BOOKING TITLE ==========
              const Text(
                "Form Booking",
                style: TextStyle(
                  fontFamily: "Nunito",
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),

              const SizedBox(height: 12),

              // ========== CARD FORM BOOKING ==========
              GestureDetector(
                onTap: () => widget.onTabChange(1), // Pindah ke Tab Booking
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: const Color(0xFFD52C2C),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.25),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Icon(
                          Icons.calendar_month_rounded,
                          color: Colors.white,
                          size: 35,
                        ),
                      ),
                      const SizedBox(width: 15),
                      const Expanded(
                        child: Text(
                          "Tentukan Tanggal Servismu!\nAda yang salah dengan kendaraanmu? Tentukan tanggal perbaikannya sekarang!",
                          style: TextStyle(
                            fontFamily: "Nunito",
                            fontSize: 15,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 25),

              // ========== MENU LAINNYA ==========
              const Text(
                "Menu Lainnya",
                style: TextStyle(
                  fontFamily: "Nunito",
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),

              const SizedBox(height: 12),

              // ========== TWO CARDS ROW (REALTIME DATA) ==========
              Row(
                children: [
                  // ========== 2. CARD ANTRIAN (STREAM) ==========
                  Expanded(
                    child: StreamBuilder<QuerySnapshot>(
                      stream: FirebaseFirestore.instance
                          .collection('bookings')
                          .where('uid', isEqualTo: user?.uid)
                          .where(
                            'status',
                            whereIn: ['Menunggu', 'Diproses', 'Diterima'],
                          )
                          .orderBy('created_at', descending: true)
                          .limit(1)
                          .snapshots(),
                      builder: (context, snapshot) {
                        String infoText = "Belum ada antrian aktif";

                        if (snapshot.hasData &&
                            snapshot.data!.docs.isNotEmpty) {
                          var data =
                              snapshot.data!.docs.first.data()
                                  as Map<String, dynamic>;

                          DateTime? tgl = data['tanggal_booking'] != null
                              ? (data['tanggal_booking'] as Timestamp).toDate()
                              : null;
                          String jam = data['jam_booking'] ?? '-';

                          String dateStr = tgl != null
                              ? DateFormat('d MMM', 'id_ID').format(tgl)
                              : '-';

                          infoText = "Datang pada tanggal\n$dateStr, $jam WIB";
                        }

                        return GestureDetector(
                          onTap: () => widget.onTabChange(2),
                          child: Container(
                            height: 140,
                            padding: const EdgeInsets.all(18),
                            decoration: BoxDecoration(
                              color: const Color(0xFFD52C2C),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Icon(
                                  Icons.access_time_filled_rounded,
                                  color: Colors.white,
                                  size: 32,
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      "Antrian Kamu",
                                      style: TextStyle(
                                        fontFamily: "Nunito",
                                        fontSize: 17,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      infoText,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        fontFamily: "Nunito",
                                        fontSize: 13,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),

                  const SizedBox(width: 15),

                  // ========== 3. CARD RIWAYAT (Manual Count) ==========
                  Expanded(
                    child: StreamBuilder<QuerySnapshot>(
                      stream: FirebaseFirestore.instance
                          .collection('bookings')
                          .where('uid', isEqualTo: user?.uid)
                          .where('status', isEqualTo: 'Selesai')
                          .snapshots(),
                      builder: (context, snapshot) {
                        int count = 0;
                        if (snapshot.hasData) {
                          count = snapshot.data!.docs.length;
                        }

                        return GestureDetector(
                          onTap: () => widget.onTabChange(3),
                          child: Container(
                            height: 140,
                            padding: const EdgeInsets.all(18),
                            decoration: BoxDecoration(
                              color: const Color(0xFFD52C2C),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Icon(
                                  Icons.history_rounded,
                                  color: Colors.white,
                                  size: 32,
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      "Riwayat Kamu",
                                      style: TextStyle(
                                        fontFamily: "Nunito",
                                        fontSize: 17,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      "Kamu memiliki $count riwayat servis",
                                      style: const TextStyle(
                                        fontFamily: "Nunito",
                                        fontSize: 13,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }
}
