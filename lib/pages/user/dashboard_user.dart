import 'package:flutter/material.dart';

// ================== SIMULASI DATA ==================
Future<String> getUserName() async {
  await Future.delayed(const Duration(milliseconds: 800));
  return "Nathania";
}

Future<Map<String, dynamic>> getAntrianUser() async {
  await Future.delayed(const Duration(milliseconds: 900));
  return {"tanggal": "16 Desember 2025", "jam": "16:00"};
}

Future<int> getRiwayatCount() async {
  await Future.delayed(const Duration(milliseconds: 600));
  return 5;
}

// ================== DASHBOARD ==================
class DashboardPage extends StatefulWidget {
  // Callback untuk ganti tab di MainLayoutUser
  final Function(int) onTabChange;

  const DashboardPage({super.key, required this.onTabChange});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  String namaUser = "";
  String tanggalAntrian = "-";
  String jamAntrian = "-";
  int riwayatJumlah = 0;

  @override
  void initState() {
    super.initState();
    loadDashboardData();
  }

  void loadDashboardData() async {
    String user = await getUserName();
    Map antrian = await getAntrianUser();
    int jumlahRiwayat = await getRiwayatCount();

    if (mounted) {
      setState(() {
        namaUser = user;
        tanggalAntrian = antrian["tanggal"];
        jamAntrian = antrian["jam"];
        riwayatJumlah = jumlahRiwayat;
      });
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
              // Judul OtoCare dihapus (karena sudah ada di AppBar MainLayout)

              // ========== GREETING DINAMIS ==========
              Text(
                "Halo $namaUser! 👋",
                style: const TextStyle(
                  fontFamily: "Nunito",
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
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
                // Aksi: Pindah ke Tab 1 (Booking)
                onTap: () => widget.onTabChange(1),
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

              // ========== TWO CARDS ROW ==========
              Row(
                children: [
                  // ========== CARD ANTRIAN ==========
                  Expanded(
                    child: GestureDetector(
                      // Aksi: Pindah ke Tab 2 (Antrian)
                      onTap: () => widget.onTabChange(2),
                      child: Container(
                        padding: const EdgeInsets.all(18),
                        decoration: BoxDecoration(
                          color: const Color(0xFFD52C2C),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(
                              Icons.access_time_filled_rounded,
                              color: Colors.white,
                              size: 32,
                            ),
                            const SizedBox(height: 10),
                            const Text(
                              "Antrian Kamu",
                              style: TextStyle(
                                fontFamily: "Nunito",
                                fontSize: 17,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              "Datang pada tanggal\n$tanggalAntrian, $jamAntrian",
                              style: const TextStyle(
                                fontFamily: "Nunito",
                                fontSize: 13,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(width: 15),

                  // ========== CARD RIWAYAT ==========
                  Expanded(
                    child: GestureDetector(
                      // Aksi: Pindah ke Tab 3 (Riwayat)
                      onTap: () => widget.onTabChange(3),
                      child: Container(
                        padding: const EdgeInsets.all(18),
                        decoration: BoxDecoration(
                          color: const Color(0xFFD52C2C),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(
                              Icons.history_rounded,
                              color: Colors.white,
                              size: 32,
                            ),
                            const SizedBox(height: 10),
                            const Text(
                              "Riwayat Kamu",
                              style: TextStyle(
                                fontFamily: "Nunito",
                                fontSize: 17,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              "Kamu memiliki $riwayatJumlah riwayat servis",
                              style: const TextStyle(
                                fontFamily: "Nunito",
                                fontSize: 13,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              // Padding tambahan bawah
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }
}
