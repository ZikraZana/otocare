import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart'; // Import intl untuk format tanggal

class DaftarAntrianScreen extends StatelessWidget {
  const DaftarAntrianScreen({super.key});

  // Style Constants
  static const Color _secondaryColor = Color(0xFFE53935);
  static const Color _neutralColor = Color(0xFF6B6B6B);

  // Helper Style
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

  // Fungsi Hapus/Batal Booking
  Future<void> _cancelBooking(BuildContext context, String docId) async {
    bool confirm =
        await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            backgroundColor: const Color(0xFF2B2B2B),
            title: const Text(
              "Batalkan Booking?",
              style: TextStyle(color: Colors.white),
            ),
            content: const Text(
              "Apakah kamu yakin ingin membatalkan antrian ini?",
              style: TextStyle(color: Colors.white70),
            ),
            actions: [
              TextButton(
                child: const Text("Tidak"),
                onPressed: () => Navigator.pop(context, false),
              ),
              TextButton(
                child: const Text(
                  "Ya, Batalkan",
                  style: TextStyle(color: Colors.red),
                ),
                onPressed: () => Navigator.pop(context, true),
              ),
            ],
          ),
        ) ??
        false;

    if (confirm) {
      await FirebaseFirestore.instance
          .collection('bookings')
          .doc(docId)
          .delete();
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Booking berhasil dibatalkan")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    User? user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return const Center(
        child: Text(
          "Silakan login terlebih dahulu",
          style: TextStyle(color: Colors.white),
        ),
      );
    }

    // STREAMBUILDER: Memantau database secara live
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('bookings')
          .where('uid', isEqualTo: user.uid) // Filter punya user ini saja
          // Kita filter status agar riwayat 'Selesai'/'Ditolak' tidak numpuk disini (Opsional)
          // Kalau mau tampil semua, hapus .where('status'...) dibawah ini
          .where('status', whereIn: ['Menunggu', 'Diterima', 'Diproses'])
          .orderBy('created_at', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        // 1. Loading State
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(color: _secondaryColor),
          );
        }

        // 2. Error State
        if (snapshot.hasError) {
          return Center(
            child: Text(
              "Terjadi kesalahan: ${snapshot.error}",
              style: const TextStyle(color: Colors.white),
            ),
          );
        }

        // 3. Empty State (Tidak ada data)
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return _buildEmptyState(context);
        }

        // 4. Data Ada -> Tampilkan List
        var documents = snapshot.data!.docs;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 24),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Text(
                'Antrian Saya',
                style: _nunitoTextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                itemCount: documents.length,
                itemBuilder: (context, index) {
                  var data = documents[index].data() as Map<String, dynamic>;
                  String docId = documents[index].id;
                  return _buildAntrianCard(context, data, docId);
                },
              ),
            ),
          ],
        );
      },
    );
  }

  // Tampilan kalau belum ada booking
  Widget _buildEmptyState(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 24),
          Text(
            'Antrian Saya',
            style: _nunitoTextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          Expanded(
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.engineering,
                    size: 200,
                    color: Colors.white.withOpacity(0.4),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Belum ada jadwal servis aktif',
                    style: _nunitoTextStyle(
                      color: Colors.white60,
                      fontSize: 20,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Tampilan Kartu Antrian Real
  Widget _buildAntrianCard(
    BuildContext context,
    Map<String, dynamic> data,
    String docId,
  ) {
    final Color cardBackground = _neutralColor.withOpacity(0.4);

    // Ambil data dari Firestore
    String status = data['status'] ?? 'Menunggu';
    String jenis = data['jenis_kendaraan'] ?? '-';
    String plat = data['plat_nomor'] ?? '-';
    String bengkel = data['kategori_servis'] ?? 'Umum';
    String jam = data['jam_booking'] ?? '-';

    // Format Tanggal
    DateTime? tglBooking;
    if (data['tanggal_booking'] != null) {
      tglBooking = (data['tanggal_booking'] as Timestamp).toDate();
    }
    String tanggalStr = tglBooking != null
        ? DateFormat('d MMMM yyyy', 'id_ID').format(
            tglBooking,
          ) // Format Indonesia
        : '-';

    // Logic warna status
    Color getStatusColor(String s) {
      if (s == 'Diterima') return Colors.blue;
      if (s == 'Diproses') return Colors.amber.shade800;
      if (s == 'Selesai') return Colors.green;
      if (s == 'Ditolak') return Colors.red;
      return Colors.grey; // Default untuk 'Menunggu'
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12.0),
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: cardBackground,
        borderRadius: BorderRadius.circular(8.0),
        border: Border.all(color: _neutralColor.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: getStatusColor(status),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              status.toUpperCase(),
              style: _nunitoTextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 12),
          // Detail Info
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  children: [
                    _buildIconText(Icons.calendar_today, "$tanggalStr - $jam"),
                    const SizedBox(height: 4),
                    _buildIconText(Icons.motorcycle, '$jenis ($plat)'),
                    const SizedBox(height: 4),
                    _buildIconText(Icons.business, "Kategori: $bengkel"),
                    const SizedBox(height: 10),
                    // KITA PAKAI DETAIL KENDALA SEBAGAI INFO TAMBAHAN
                    _buildIconText(
                      Icons.note,
                      'Keluhan: ${data['detail_kendala'] ?? '-'}',
                    ),
                  ],
                ),
              ),

              // Tombol Batal hanya muncul jika status masih 'Menunggu'
              if (status == 'Menunggu')
                SizedBox(
                  height: 30,
                  child: ElevatedButton(
                    onPressed: () => _cancelBooking(context, docId),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _secondaryColor,
                    ),
                    child: Text(
                      'Batal',
                      style: _nunitoTextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildIconText(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.white70),
        const SizedBox(width: 8),
        Expanded(child: Text(text, style: _nunitoTextStyle(fontSize: 14))),
      ],
    );
  }
}
