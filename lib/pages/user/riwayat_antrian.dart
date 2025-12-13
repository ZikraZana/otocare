import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

class RiwayatAntrianPage extends StatefulWidget {
  const RiwayatAntrianPage({super.key});

  @override
  RiwayatAntrianPageState createState() => RiwayatAntrianPageState();
}

class RiwayatAntrianPageState extends State<RiwayatAntrianPage> {
  int selectedTab = 0; // 0 = Selesai, 1 = Ditolak

  final Color _backgroundColor = const Color(0xFF2B2B2B);
  final Color _cardColor = const Color(0xFF4A4A4A);
  final Color _popupColor = const Color(0xFF282828);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: _backgroundColor,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(18, 24, 18, 10),
            child: Text(
              "Riwayat Antrian",
              style: TextStyle(
                fontFamily: "Nunito",
                fontSize: 24,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ),

          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildTab("Selesai", 0),
              const SizedBox(width: 30),
              _buildTab("Ditolak", 1),
            ],
          ),

          const SizedBox(height: 10),

          Expanded(child: _buildListContent()),
        ],
      ),
    );
  }

  Widget _buildTab(String title, int index) {
    bool active = selectedTab == index;
    return GestureDetector(
      onTap: () => setState(() => selectedTab = index),
      child: Column(
        children: [
          Text(
            title,
            style: TextStyle(
              fontFamily: "Nunito",
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: active ? const Color(0xFFFFD700) : Colors.grey,
            ),
          ),
          const SizedBox(height: 4),
          Container(
            width: 50,
            height: 2,
            color: active ? const Color(0xFFFFD700) : Colors.transparent,
          ),
        ],
      ),
    );
  }

  Widget _buildListContent() {
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) return const SizedBox();

    String targetStatus = (selectedTab == 0) ? 'Selesai' : 'Ditolak';

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('bookings')
          .where('uid', isEqualTo: user.uid)
          .where('status', isEqualTo: targetStatus)
          .orderBy('created_at', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(color: Colors.white),
          );
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.history,
                  size: 80,
                  color: Colors.white.withOpacity(0.3),
                ),
                const SizedBox(height: 10),
                Text(
                  "Belum ada riwayat $targetStatus",
                  style: TextStyle(color: Colors.white.withOpacity(0.5)),
                ),
              ],
            ),
          );
        }

        var documents = snapshot.data!.docs;

        return ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 18),
          itemCount: documents.length,
          itemBuilder: (context, index) {
            var data = documents[index].data() as Map<String, dynamic>;

            String status = data['status'] ?? targetStatus;
            String motor = data['jenis_kendaraan'] ?? '-';
            String kategori = data['kategori_servis'] ?? '-';
            String jam = data['jam_booking'] ?? '-';

            DateTime? tgl = data['tanggal_booking'] != null
                ? (data['tanggal_booking'] as Timestamp).toDate()
                : null;
            String tglStr = tgl != null
                ? DateFormat('d MMMM yyyy', 'id_ID').format(tgl)
                : '-';

            Color warnaStatus = (status == 'Selesai')
                ? Colors.green
                : Colors.red;

            return _bookingCard(
              statusColor: warnaStatus,
              statusText: status,
              tanggal: "$tglStr - $jam WIB",
              motor: motor,
              kategori: kategori,
              onTap: () => _showDetailPopup(context, data),
            );
          },
        );
      },
    );
  }

  Widget _bookingCard({
    required Color statusColor,
    required String statusText,
    required String tanggal,
    required String motor,
    required String kategori,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: _cardColor,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
              decoration: BoxDecoration(
                color: statusColor,
                borderRadius: BorderRadius.circular(30),
              ),
              child: Text(
                statusText,
                style: const TextStyle(
                  color: Colors.white,
                  fontFamily: "Nunito",
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 10),

            Text(
              tanggal,
              style: const TextStyle(
                fontFamily: "Nunito",
                fontSize: 15,
                color: Colors.white,
              ),
            ),
            Text(
              motor,
              style: const TextStyle(
                fontFamily: "Nunito",
                fontSize: 15,
                color: Colors.white,
              ),
            ),
            Text(
              kategori,
              style: const TextStyle(
                fontFamily: "Nunito",
                fontSize: 15,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- REVISI: POPUP DETAIL MENAMPILKAN ALASAN ---
  void _showDetailPopup(BuildContext context, Map<String, dynamic> data) {
    String status = data['status'] ?? '-';
    String merk = data['merk_kendaraan'] ?? '-';
    String jenis = data['jenis_kendaraan'] ?? '-';
    String plat = data['plat_nomor'] ?? '-';
    String kategori = data['kategori_servis'] ?? '-';
    String kendala = data['detail_kendala'] ?? '-';
    String jam = data['jam_booking'] ?? '-';
    // Ambil Alasan Penolakan dari DB
    String alasanTolak =
        data['alasan_penolakan'] ?? 'Tidak ada alasan spesifik';

    DateTime? tgl = data['tanggal_booking'] != null
        ? (data['tanggal_booking'] as Timestamp).toDate()
        : null;
    String tglStr = tgl != null
        ? DateFormat('d MMMM yyyy', 'id_ID').format(tgl)
        : '-';

    showDialog(
      context: context,
      builder: (_) => Dialog(
        backgroundColor: _popupColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Container(
          padding: const EdgeInsets.all(18),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Detail Booking",
                style: TextStyle(
                  fontFamily: "Nunito",
                  fontSize: 18,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 15),
              _row("Tanggal", "$tglStr - $jam"),
              _row("Kendaraan", "$merk $jenis"),
              _row("No Plat", plat),
              _row("Kategori", kategori),
              const SizedBox(height: 10),

              Text(
                "Status : $status",
                style: TextStyle(
                  fontFamily: "Nunito",
                  color: (status == 'Selesai') ? Colors.green : Colors.red,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 5),

              // --- TAMBAHAN BARU: ALASAN PENOLAKAN ---
              if (status == 'Ditolak') ...[
                const SizedBox(height: 10),
                const Divider(color: Colors.white24),
                const SizedBox(height: 10),
                const Text(
                  "Alasan Penolakan:",
                  style: TextStyle(
                    fontFamily: "Nunito",
                    color: Colors.redAccent,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  alasanTolak,
                  style: const TextStyle(
                    fontFamily: "Nunito",
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 10),
                const Divider(color: Colors.white24),
              ],

              // ----------------------------------------
              const SizedBox(height: 5),
              const Text(
                "Detail Kendala:",
                style: TextStyle(
                  fontFamily: "Nunito",
                  color: Colors.white70,
                  fontSize: 12,
                ),
              ),
              Text(
                kendala,
                style: const TextStyle(
                  fontFamily: "Nunito",
                  color: Colors.white,
                ),
              ),

              const SizedBox(height: 20),
              _closeButton(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _row(String title, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              title,
              style: const TextStyle(
                fontFamily: "Nunito",
                color: Colors.white70,
              ),
            ),
          ),
          const Text(": ", style: TextStyle(color: Colors.white70)),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontFamily: "Nunito", color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Widget _closeButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: _cardColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        onPressed: () => Navigator.pop(context),
        child: const Text(
          "Tutup",
          style: TextStyle(
            fontFamily: "Nunito",
            fontSize: 16,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
