import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class KelolaAntrian extends StatefulWidget {
  const KelolaAntrian({super.key});

  @override
  State<KelolaAntrian> createState() => _KelolaAntrianState();
}

class _KelolaAntrianState extends State<KelolaAntrian> {
  // Variabel Pagination & Data
  final ScrollController _scrollController = ScrollController();
  List<Map<String, dynamic>> _dataBooking = [];
  bool _isLoading = false;
  bool _hasMore = true;
  int _limit = 10;
  DocumentSnapshot? _lastDocument;

  // --- VARIABEL FILTER ---
  DateTime? _selectedDate;

  @override
  void initState() {
    super.initState();
    _autoCancelExpiredBookings();
    _fetchData();

    _scrollController.addListener(() {
      // Pagination hanya jalan kalau TIDAK sedang filter tanggal
      if (_selectedDate == null &&
          _scrollController.position.pixels ==
              _scrollController.position.maxScrollExtent) {
        _fetchData();
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  // --- LOGIC SORTING STATUS (Active di Atas, Inactive di Bawah) ---
  int _getStatusPriority(String? status) {
    // 0 = Paling Atas (Active)
    // 1 = Paling Bawah (Inactive)
    const activeStatuses = ['Menunggu', 'Diterima', 'Diproses'];
    if (status != null && activeStatuses.contains(status)) {
      return 0;
    }
    return 1;
  }

  // --- 1. FUNGSI LOAD DATA (MODIFIED FOR FILTER) ---
  Future<void> _fetchData() async {
    if (_isLoading) return;
    // Jika mode pagination (tanpa filter) dan data habis, stop.
    if (_selectedDate == null && !_hasMore) return;

    setState(() => _isLoading = true);

    try {
      // A. JIKA ADA FILTER TANGGAL
      if (_selectedDate != null) {
        DateTime start = DateTime(
          _selectedDate!.year,
          _selectedDate!.month,
          _selectedDate!.day,
        );
        DateTime end = start.add(const Duration(days: 1));

        // Ambil SEMUA data di tanggal itu (tanpa limit pagination)
        QuerySnapshot snapshot = await FirebaseFirestore.instance
            .collection('bookings')
            .where(
              'tanggal_booking',
              isGreaterThanOrEqualTo: Timestamp.fromDate(start),
            )
            .where('tanggal_booking', isLessThan: Timestamp.fromDate(end))
            .get();

        List<Map<String, dynamic>> temp = [];
        for (var doc in snapshot.docs) {
          Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
          data['docId'] = doc.id;
          temp.add(data);
        }

        // SORTING CUSTOM (Client Side)
        // 1. Status Priority (Active First)
        // 2. Jam Booking (Pagi First)
        temp.sort((a, b) {
          int priorityA = _getStatusPriority(a['status']);
          int priorityB = _getStatusPriority(b['status']);

          if (priorityA != priorityB) {
            return priorityA.compareTo(priorityB);
          } else {
            // Jika priority sama, urutkan berdasarkan Jam
            String jamA = a['jam_booking'] ?? '';
            String jamB = b['jam_booking'] ?? '';
            return jamA.compareTo(jamB);
          }
        });

        setState(() {
          _dataBooking = temp;
          _hasMore = false; // Disable load more saat mode filter
        });
      }
      // B. JIKA TANPA FILTER (MODE PAGINATION LAMA)
      else {
        Query query = FirebaseFirestore.instance
            .collection('bookings')
            .orderBy('tanggal_booking', descending: false) // Terdekat
            .orderBy('jam_booking', descending: false) // Pagi
            .limit(_limit);

        if (_lastDocument != null) {
          query = query.startAfterDocument(_lastDocument!);
        }

        QuerySnapshot snapshot = await query.get();

        if (snapshot.docs.isNotEmpty) {
          _lastDocument = snapshot.docs.last;
          for (var doc in snapshot.docs) {
            Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
            data['docId'] = doc.id;
            _dataBooking.add(data);
          }
          if (snapshot.docs.length < _limit) _hasMore = false;
        } else {
          _hasMore = false;
        }
      }
    } catch (e) {
      print("Error fetching data: $e");
    }

    setState(() => _isLoading = false);
  }

  // --- FUNGSI PILIH TANGGAL ---
  Future<void> _pickDate() async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(2024),
      lastDate: DateTime(2030),
      builder: (context, child) => Theme(data: ThemeData.dark(), child: child!),
    );

    if (picked != null) {
      setState(() {
        _selectedDate = picked;
        _dataBooking.clear(); // Reset data
        _lastDocument = null;
        _hasMore = true;
      });
      _fetchData(); // Load data tanggal tsb
    }
  }

  // --- FUNGSI RESET FILTER ---
  void _clearFilter() {
    setState(() {
      _selectedDate = null;
      _dataBooking.clear();
      _lastDocument = null;
      _hasMore = true;
    });
    _fetchData();
  }

  // --- REFRESH ---
  Future<void> _onRefresh() async {
    setState(() {
      _dataBooking.clear();
      _lastDocument = null;
      _hasMore = true;
    });
    await _fetchData();
  }

  // --- AUTO CANCEL ---
  Future<void> _autoCancelExpiredBookings() async {
    try {
      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('bookings')
          .where('status', isEqualTo: 'Diterima')
          .get();

      DateTime now = DateTime.now();
      bool adaPerubahan = false;

      for (var doc in snapshot.docs) {
        var data = doc.data() as Map<String, dynamic>;
        Timestamp? tglStamp = data['tanggal_booking'];
        String? jamStr = data['jam_booking'];

        if (tglStamp != null && jamStr != null) {
          DateTime tgl = tglStamp.toDate();
          List<String> parts = jamStr.split(':');
          DateTime jadwalBooking = DateTime(
            tgl.year,
            tgl.month,
            tgl.day,
            int.parse(parts[0]),
            int.parse(parts[1]),
          );

          if (jadwalBooking.isBefore(now)) {
            await FirebaseFirestore.instance
                .collection('bookings')
                .doc(doc.id)
                .update({
                  'status': 'Dibatalkan',
                  'alasan_penolakan': 'Sistem: User tidak datang tepat waktu.',
                });
            adaPerubahan = true;
          }
        }
      }
      if (adaPerubahan) _onRefresh();
    } catch (e) {
      print("Error auto cancel: $e");
    }
  }

  Future<void> _updateStatus(
    String docId,
    String newStatus, {
    String? reason,
  }) async {
    Map<String, dynamic> updateData = {'status': newStatus};
    if (reason != null && reason.isNotEmpty) {
      updateData['alasan_penolakan'] = reason;
    }
    await FirebaseFirestore.instance
        .collection('bookings')
        .doc(docId)
        .update(updateData);

    // Update Local & Sort Ulang jika mode filter aktif
    setState(() {
      int index = _dataBooking.indexWhere(
        (element) => element['docId'] == docId,
      );
      if (index != -1) {
        _dataBooking[index]['status'] = newStatus;
        if (reason != null) _dataBooking[index]['alasan_penolakan'] = reason;

        // Jika sedang filter tanggal, sort ulang agar yang "Selesai" langsung turun ke bawah
        if (_selectedDate != null) {
          _dataBooking.sort((a, b) {
            int priorityA = _getStatusPriority(a['status']);
            int priorityB = _getStatusPriority(b['status']);
            if (priorityA != priorityB) return priorityA.compareTo(priorityB);
            return (a['jam_booking'] ?? '').compareTo(b['jam_booking'] ?? '');
          });
        }
      }
    });
  }

  // --- HELPER WARNA DLL TETAP SAMA ---
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
      case 'Dibatalkan':
        return Colors.grey;
      default:
        return Colors.grey;
    }
  }

  Color _getStatusTextColor(String status) {
    if (status == 'Diproses') return Colors.black;
    return Colors.white;
  }

  void _showRejectDialog(BuildContext context, String docId) {
    final TextEditingController reasonController = TextEditingController();
    showDialog(
      context: context,
      barrierDismissible: false,
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
              hintText: "Misal: Bengkel penuh",
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
                _updateStatus(
                  docId,
                  "Ditolak",
                  reason: reasonController.text.trim(),
                );
                Navigator.pop(context);
                Navigator.pop(context);
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

  void _showDetailPopup(BuildContext context, Map<String, dynamic> data) {
    String docId = data['docId'];
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
                  _buildDetailRow("Nama", nama),
                  _buildDetailRow("HP", hp),
                  _buildDetailRow("Jadwal", "$tglStr - $jam"),
                  _buildDetailRow("Motor", "$merk $jenis ($plat)"),
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
            width: 80,
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
            content: Text("Status: $newStatus"),
            duration: const Duration(milliseconds: 800),
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

  Widget _buildRejectButton(BuildContext context, String docId) {
    return ElevatedButton(
      onPressed: () => _showRejectDialog(context, docId),
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
    String headerTitle = "Antrian Keseluruhan";
    if (_selectedDate != null) {
      headerTitle = DateFormat('d MMMM yyyy', 'id_ID').format(_selectedDate!);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // HEADER MODIFIED: Title + Icon Filter
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                headerTitle,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Row(
                children: [
                  // Jika sedang filter, munculkan tombol X
                  if (_selectedDate != null)
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.red),
                      onPressed: _clearFilter,
                      tooltip: "Hapus Filter",
                    ),
                  IconButton(
                    icon: Icon(
                      Icons.calendar_month,
                      color: _selectedDate != null ? Colors.blue : Colors.white,
                    ),
                    onPressed: _pickDate,
                    tooltip: "Filter Tanggal",
                  ),
                ],
              ),
            ],
          ),
        ),

        Expanded(
          child: RefreshIndicator(
            onRefresh: _onRefresh,
            color: Colors.red,
            backgroundColor: Colors.white,
            child: _dataBooking.isEmpty && !_isLoading
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.event_busy,
                          size: 60,
                          color: Colors.white.withOpacity(0.3),
                        ),
                        const SizedBox(height: 10),
                        const Text(
                          "Tidak ada antrian",
                          style: TextStyle(color: Colors.white54),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    itemCount:
                        _dataBooking.length +
                        (_hasMore && _selectedDate == null ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (index == _dataBooking.length) {
                        return const Padding(
                          padding: EdgeInsets.all(20.0),
                          child: Center(
                            child: CircularProgressIndicator(
                              color: Colors.white,
                            ),
                          ),
                        );
                      }

                      var data = _dataBooking[index];

                      String docId = data['docId'];
                      String nama = data['nama'] ?? 'Tanpa Nama';
                      String status = data['status'] ?? 'Menunggu';
                      String jenis = data['jenis_kendaraan'] ?? '';
                      String kategori = data['kategori_servis'] ?? 'Servis';
                      DateTime? tgl = data['tanggal_booking'] != null
                          ? (data['tanggal_booking'] as Timestamp).toDate()
                          : null;
                      String tglStr = tgl != null
                          ? DateFormat('d MMM', 'id_ID').format(tgl)
                          : '-';
                      String jam = data['jam_booking'] ?? '';

                      // Logic Warna Card: Jika Selesai/Batal/Tolak => Gelap, Jika Aktif => Terang dikit
                      // Tapi user minta Selesai di bawah, secara visual biar gampang kita bedakan opacity-nya
                      bool isInactive = [
                        'Selesai',
                        'Ditolak',
                        'Dibatalkan',
                      ].contains(status);

                      return GestureDetector(
                        onTap: () => _showDetailPopup(context, data),
                        child: Opacity(
                          opacity: isInactive
                              ? 0.6
                              : 1.0, // Biar yang selesai terlihat "redup"
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
                                    "$tglStr, $jam WIB",
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
                        ),
                      );
                    },
                  ),
          ),
        ),
      ],
    );
  }
}
