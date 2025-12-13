import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class KelolaAntrian extends StatefulWidget {
  const KelolaAntrian({super.key});

  @override
  State<KelolaAntrian> createState() => _KelolaAntrianState();
}

class _KelolaAntrianState extends State<KelolaAntrian> {
  // Helper Warna Status
  Color _getStatusColor(String status) {
    switch (status) {
      case 'Diterima':
        return Colors.blue;
      case 'Diproses':
        return Colors.amber;
      case 'Selesai':
        return Colors.green;
      case 'Ditolak':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  Color _getStatusTextColor(String status) {
    if (status == 'Diproses') return Colors.black;
    return Colors.white;
  }

  // Fungsi Update Status (Ditambah parameter opsional: reason)
  Future<void> _updateStatus(
    String docId,
    String newStatus, {
    String? reason,
  }) async {
    Map<String, dynamic> data = {'status': newStatus};

    // Jika ada alasan (untuk penolakan), masukkan ke data update
    if (reason != null && reason.isNotEmpty) {
      data['alasan_penolakan'] = reason;
    }

    await FirebaseFirestore.instance
        .collection('bookings')
        .doc(docId)
        .update(data);
  }

  // --- LOGIC BARU: POPUP ALASAN TOLAK ---
  void _showRejectDialog(BuildContext context, String docId) {
    final TextEditingController reasonController = TextEditingController();

    showDialog(
      context: context,
      barrierDismissible: false, // User harus isi atau cancel
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF2B2B2B),
          title: const Text(
            "Alasan Penolakan",
            style: TextStyle(color: Colors.white),
          ),
          content: TextField(
            controller: reasonController,
            style: const TextStyle(color: Colors.white),
            decoration: const InputDecoration(
              hintText: "Misal: Bengkel penuh, Jadwal tutup",
              hintStyle: TextStyle(color: Colors.white54),
              enabledBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Colors.white54),
              ),
              focusedBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Colors.red),
              ),
            ),
          ),
          actions: [
            TextButton(
              child: const Text("Batal"),
              onPressed: () => Navigator.pop(context),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              onPressed: () {
                if (reasonController.text.trim().isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Alasan harus diisi!")),
                  );
                  return;
                }
                // Update ke Firestore dengan alasan
                _updateStatus(
                  docId,
                  "Ditolak",
                  reason: reasonController.text.trim(),
                );
                Navigator.pop(context); // Tutup Dialog Input
                Navigator.pop(context); // Tutup Dialog Detail Utama

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Booking ditolak.")),
                );
              },
              child: const Text(
                "Tolak Booking",
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        );
      },
    );
  }

  // POPUP DETAIL UTAMA
  void _showDetailPopup(
    BuildContext context,
    String docId,
    Map<String, dynamic> data,
  ) {
    String nama = data['nama'] ?? '-';
    String jenis = data['jenis_kendaraan'] ?? '-';
    String merk = data['merk_kendaraan'] ?? '-';
    String plat = data['plat_nomor'] ?? '-';
    String kendala = data['detail_kendala'] ?? '-';
    String hp = data['no_hp'] ?? '-';

    DateTime? tgl = data['tanggal_booking'] != null
        ? (data['tanggal_booking'] as Timestamp).toDate()
        : null;
    String tglStr = tgl != null
        ? DateFormat('d MMMM yyyy', 'id_ID').format(tgl)
        : '-';
    String jam = data['jam_booking'] ?? '-';

    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          backgroundColor: const Color(0xFF282828),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
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

                  _buildDetailRow("Nama Customer", nama),
                  _buildDetailRow("Nomor HP", hp),
                  _buildDetailRow("Jadwal", "$tglStr - $jam WIB"),
                  _buildDetailRow("Kendaraan", "$merk $jenis"),
                  _buildDetailRow("Plat Nomor", plat),
                  _buildDetailRow("Kategori", data['kategori_servis'] ?? '-'),
                  const SizedBox(height: 10),
                  const Text(
                    "Keluhan:",
                    style: TextStyle(color: Colors.white70, fontSize: 12),
                  ),
                  Text(
                    kendala,
                    style: const TextStyle(color: Colors.white, fontSize: 14),
                  ),

                  const SizedBox(height: 20),
                  const Divider(color: Colors.grey),
                  const SizedBox(height: 10),

                  const Text(
                    "Update Status:",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),

                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _buildActionButton(
                        context,
                        "Terima",
                        Colors.blue,
                        docId,
                        "Diterima",
                      ),
                      _buildActionButton(
                        context,
                        "Proses",
                        Colors.amber,
                        docId,
                        "Diproses",
                      ),
                      _buildActionButton(
                        context,
                        "Selesai",
                        Colors.green,
                        docId,
                        "Selesai",
                      ),
                      // Tombol TOLAK (Spesial)
                      _buildRejectButton(context, docId),
                    ],
                  ),

                  const SizedBox(height: 15),
                  SizedBox(
                    width: double.infinity,
                    child: TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text(
                        "Tutup",
                        style: TextStyle(color: Colors.white54),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: const TextStyle(color: Colors.white70, fontSize: 13),
            ),
          ),
          const Text(": ", style: TextStyle(color: Colors.white70)),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Tombol Biasa (Terima, Proses, Selesai)
  Widget _buildActionButton(
    BuildContext context,
    String label,
    Color color,
    String docId,
    String newStatus,
  ) {
    return ElevatedButton(
      onPressed: () {
        _updateStatus(docId, newStatus);
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Status diubah menjadi $newStatus"),
            duration: const Duration(seconds: 1),
          ),
        );
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: (label == "Proses") ? Colors.black : Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        minimumSize: const Size(80, 36),
      ),
      child: Text(label),
    );
  }

  // Tombol Tolak (Memanggil Dialog Input)
  Widget _buildRejectButton(BuildContext context, String docId) {
    return ElevatedButton(
      onPressed: () {
        // Panggil Dialog Input Alasan
        _showRejectDialog(context, docId);
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.red,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        minimumSize: const Size(80, 36),
      ),
      child: const Text("Tolak"),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.fromLTRB(20, 20, 20, 10),
          child: Text(
            "Antrian Keseluruhan",
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),

        Expanded(
          child: StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('bookings')
                .orderBy('created_at', descending: true)
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return const Center(
                  child: Text(
                    "Belum ada data",
                    style: TextStyle(color: Colors.white54),
                  ),
                );
              }

              var documents = snapshot.data!.docs;

              return ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                itemCount: documents.length,
                itemBuilder: (context, index) {
                  var data = documents[index].data() as Map<String, dynamic>;
                  String docId = documents[index].id;

                  String nama = data['nama'] ?? 'Tanpa Nama';
                  String status = data['status'] ?? 'Menunggu';
                  String jenis = data['jenis_kendaraan'] ?? '';
                  String kategori = data['kategori_servis'] ?? 'Servis';

                  DateTime? tgl = data['tanggal_booking'] != null
                      ? (data['tanggal_booking'] as Timestamp).toDate()
                      : null;
                  String tglStr = tgl != null
                      ? DateFormat('d MMMM yyyy', 'id_ID').format(tgl)
                      : '-';
                  String jam = data['jam_booking'] ?? '';

                  return GestureDetector(
                    onTap: () => _showDetailPopup(context, docId, data),
                    child: Card(
                      color: const Color(0xFF424242),
                      margin: const EdgeInsets.only(bottom: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: _getStatusColor(status),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                status,
                                style: TextStyle(
                                  color: _getStatusTextColor(status),
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              nama,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              "$tglStr - $jam WIB",
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              "$jenis ($kategori)",
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}
