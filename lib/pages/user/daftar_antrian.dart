import 'package:flutter/material.dart';

TextStyle _nunitoTextStyle({
  Color color = Colors.white, // Default Teks Putih
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

enum BookingStatus { diterima, diproses, selesai, dibatalkan }

class BookingItem {
  final String tanggalWaktu;
  final String jenisKendaraan;
  final String platNomor;
  final String bengkel;
  final String noAntrian;
  final BookingStatus status;

  const BookingItem({
    required this.tanggalWaktu,
    required this.jenisKendaraan,
    required this.platNomor,
    required this.bengkel,
    required this.noAntrian,
    required this.status,
  });
}

class DaftarAntrianScreen extends StatelessWidget {
  DaftarAntrianScreen({super.key});

  static const Color _backgroundColor = Color(0xFF333333);
  static const Color _secondaryColor = Color(0xFFE53935);
  static const Color _neutralColor = Color(0xFF6B6B6B);

  final List<BookingItem> activeBookings = const [
    BookingItem(
      tanggalWaktu: '12 Desember 2025 - 16:00 WIB',
      jenisKendaraan: 'Yamaha NMax',
      platNomor: 'BH 2112 AS',
      bengkel: 'KSG (Servis Berkala)',
      noAntrian: '03',
      status: BookingStatus.diterima,
    ),
    BookingItem(
      tanggalWaktu: '15 Desember 2025 - 09:30 WIB',
      jenisKendaraan: 'Honda Beat',
      platNomor: 'BH 3000 DMR',
      bengkel: 'KSG (Servis Berkala)',
      noAntrian: '10',
      status: BookingStatus.diterima,
    ),
    BookingItem(
      tanggalWaktu: '20 Desember 2025 - 14:00 WIB',
      jenisKendaraan: 'Honda Scoppy',
      platNomor: 'BH 4444 SA',
      bengkel: 'KSG (Servis Berkala)',
      noAntrian: '12',
      status: BookingStatus.diterima,
    ),
  ];

  @override
  bool get hasActiveBookings => activeBookings.isNotEmpty;
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _backgroundColor, // Menggunakan Abu Gelap
      appBar: AppBar(
        backgroundColor: _backgroundColor,
        elevation: 0,
        title: Text(
          'OtoCare',
          style: _nunitoTextStyle(
            color: Colors.white,
            fontSize: 32,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),

      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. DIVIDER diletakkan di sini, memisahkan App Bar dan Body content
          Divider(
            color: _neutralColor.withOpacity(0.5),
            thickness: 1,
            height: 1,
          ),
          
          // 2. KONTEN UTAMA dipanggil
          Expanded(
            // Logika Kondisional:
            child: hasActiveBookings
                ? _AntrianActiveState(bookings: activeBookings) // Tampilkan daftar aktif
                : const _AntrianEmptyState(), // Tampilkan empty state
          ),
        ],
      ),

      bottomNavigationBar: const _BottomNavBar(activeIndex: 2),
    );
  }
}

class _AntrianActiveState extends StatelessWidget {
  final List<BookingItem> bookings;
  
  const _AntrianActiveState({required this.bookings});

  // Helper untuk mendapatkan warna chip status
  Color _getStatusColor(BookingStatus status) {
    switch (status) {
      case BookingStatus.diterima:
        return Colors.blue;
      case BookingStatus.diproses:
        return Colors.amber.shade800;
      case BookingStatus.selesai:
        return Colors.green;
      case BookingStatus.dibatalkan:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final Color textColor = Colors.white;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 24),

        // Judul "Antrian Saya"
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Text(
            'Antrian Saya',
            style: _nunitoTextStyle(
              color: textColor,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        
        const SizedBox(height: 16),

        // LIST VIEW untuk menampilkan daftar card
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            itemCount: bookings.length,
            itemBuilder: (context, index) {
              final item = bookings[index];
              return _buildAntrianCard(context, item);
            },
          ),
        ),
      ],
    );
  }
  
  Widget _buildAntrianCard(BuildContext context, BookingItem item) {
    // Meniru layout card dari desain yang Anda berikan
    final Color textColor = Colors.white;
    final Color cardBackground = const Color(0xFF6B6B6B).withOpacity(0.4);
    final Color statusColor = _getStatusColor(item.status);
    final bool canCancel = item.status == BookingStatus.diterima; // Hanya bisa dibatalkan jika 'Diterima'

    return Container(
      margin: const EdgeInsets.only(bottom: 12.0),
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: cardBackground,
        borderRadius: BorderRadius.circular(8.0),
        border: Border.all(color: DaftarAntrianScreen._neutralColor.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Baris 1: Status Chip
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: statusColor,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              item.status.name.toUpperCase(),
              style: _nunitoTextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          
          const SizedBox(height: 12),

          // Baris 2: Detail Informasi Booking
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Tanggal & Waktu
                    _buildIconText(Icons.calendar_today, item.tanggalWaktu, textColor, isBold: true),
                    const SizedBox(height: 4),
                    // Jenis Kendaraan & Plat
                    _buildIconText(Icons.motorcycle, '${item.jenisKendaraan} (${item.platNomor})', textColor),
                    const SizedBox(height: 4),
                    // Bengkel
                    _buildIconText(Icons.business, item.bengkel, textColor),
                    const SizedBox(height: 10),
                    // Nomor Antrian
                    _buildIconText(Icons.numbers, 'No. Antrian: ${item.noAntrian}', textColor, isBold: true),
                  ],
                ),
              ),
              
              // Tombol Batalkan Servis (Hanya muncul jika bisa dibatalkan)
              if (canCancel)
                SizedBox(
                  height: 30, // Disesuaikan agar sejajar
                  child: ElevatedButton(
                    onPressed: () {
                      // *COMMENTS: INTEGRASI NAVIGASI*
                      // Harus memunculkan dialog konfirmasi pembatalan.
                      print('Memicu pembatalan servis untuk ${item.platNomor}');
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: DaftarAntrianScreen._secondaryColor, // Merah
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4),
                      ),
                      elevation: 0,
                    ),
                    child: Text(
                      'Batalkan Servis',
                      style: _nunitoTextStyle(
                        color: Colors.white,
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
  
  // Helper Widget untuk Icon dan Text
  Widget _buildIconText(IconData icon, String text, Color color, {bool isBold = false}) {
    return Row(
      children: [
        Icon(icon, size: 16, color: color.withOpacity(0.8)),
        const SizedBox(width: 8),
        Flexible(
          child: Text(
            text,
            style: _nunitoTextStyle(
              color: color,
              fontSize: 14,
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}

class _AntrianEmptyState extends StatelessWidget {
  const _AntrianEmptyState();

  @override
  Widget build(BuildContext context) {
    // Mengambil warna background dari parent
    final Color textColor = Colors.white;
    final Color accentColor = DaftarAntrianScreen._secondaryColor;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0), 
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const SizedBox(height: 24), // Memberi ruang antara Divider dan Judul
          
          // 1. Judul "Antrian Saya" (Sudah di Top Left)
          Text(
            'Antrian Saya',
            style: _nunitoTextStyle(
              color: textColor,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          
          // 2. Konten Utama (Ikon + Teks + Tombol) - DIJAGA AGAR TETAP DI TENGAH
          Expanded(
            child: Center( // Center memastikan konten di tengah vertikal dan horizontal
              child: Column(
                mainAxisSize: MainAxisSize.min, 
                children: [
                  // Ikon Mekanik
                  Icon(
                    Icons.engineering, 
                    size: 200,
                    color: textColor.withOpacity(0.4),
                  ),
                  
                  const SizedBox(height: 10),

                  // Teks Status
                  Text(
                    'Belum ada jadwal servis',
                    style: _nunitoTextStyle(
                      color: textColor.withOpacity(0.6),
                      fontSize: 20,
                      fontWeight: FontWeight.w400,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  
                  const SizedBox(height: 20),

                  // Tombol "Tambah Servis"
                  ConstrainedBox(
                    constraints: const BoxConstraints(
                      minWidth: 200, // Lebar minimum (opsional)
                      maxWidth: 280, // Lebar maksimum yang lebih proporsional
                    ),
                    child: ElevatedButton(
                      onPressed: () {
                        print('Navigasi ke halaman Tambah Servis');
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: accentColor, // Merah
                        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 30), // Tambah padding horizontal
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      child: Text(
                        'Tambah Servis',
                        style: _nunitoTextStyle(
                          color: textColor, // Teks Putih
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
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
}

class _BottomNavBar extends StatelessWidget {
  final int activeIndex;

  const _BottomNavBar({required this.activeIndex});

  @override
  Widget build(BuildContext context) {
    // Mengambil warna dari kelas induk
    final Color backgroundColor = DaftarAntrianScreen._backgroundColor;
    final Color secondaryColor = DaftarAntrianScreen._secondaryColor;
    final Color inactiveColor = Colors.white.withOpacity(
      0.6,
    ); // Ikon tidak aktif

    // Definisi Item Navigasi
    final List<Map<String, dynamic>> items = [
      {'icon': Icons.home, 'label': 'Beranda', 'index': 0},
      {'icon': Icons.calendar_today, 'label': 'Booking', 'index': 1},
      {'icon': Icons.calendar_month, 'label': 'Antrian', 'index': 2},
      {'icon': Icons.list, 'label': 'Riwayat', 'index': 3},
    ];

    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      backgroundColor: backgroundColor,
      selectedItemColor: secondaryColor, // Merah untuk item aktif
      unselectedItemColor: inactiveColor, // Ikon tidak aktif
      currentIndex: activeIndex,
      selectedLabelStyle: _nunitoTextStyle(fontSize: 12, color: secondaryColor),
      unselectedLabelStyle: _nunitoTextStyle(
        fontSize: 12,
        color: inactiveColor,
      ),

      onTap: (index) {
        print('Navigasi ke ${items[index]['label']}');
      },

      items: items.map((item) {
        return BottomNavigationBarItem(
          icon: Icon(item['icon']),
          label: item['label'],
        );
      }).toList(),
    );
  }
}
