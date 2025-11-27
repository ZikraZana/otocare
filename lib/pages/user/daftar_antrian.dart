import 'package:flutter/material.dart';

// Definisi Model & Enum tetap sama
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
  const DaftarAntrianScreen({super.key}); // const constructor

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

  // Data Dummy
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
  ];

  @override
  Widget build(BuildContext context) {
    bool hasActiveBookings = activeBookings.isNotEmpty;

    // KITA TIDAK PAKAI SCAFFOLD LAGI DISINI
    // Langsung return Column / Content
    return hasActiveBookings
        ? _buildActiveState(context, activeBookings)
        : _buildEmptyState(context);
  }

  Widget _buildActiveState(BuildContext context, List<BookingItem> bookings) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 24),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Text(
            'Antrian Saya',
            style: _nunitoTextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
        ),
        const SizedBox(height: 16),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            itemCount: bookings.length,
            itemBuilder: (context, index) {
              return _buildAntrianCard(context, bookings[index]);
            },
          ),
        ),
      ],
    );
  }

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
                    'Belum ada jadwal servis',
                    style: _nunitoTextStyle(
                      color: Colors.white60,
                      fontSize: 20,
                    ),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _secondaryColor,
                      padding: const EdgeInsets.symmetric(
                        vertical: 10,
                        horizontal: 30,
                      ),
                    ),
                    child: Text(
                      'Tambah Servis',
                      style: _nunitoTextStyle(fontWeight: FontWeight.bold),
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

  Widget _buildAntrianCard(BuildContext context, BookingItem item) {
    final Color cardBackground = _neutralColor.withOpacity(0.4);

    // Logic warna status
    Color getStatusColor(BookingStatus s) {
      if (s == BookingStatus.diterima) return Colors.blue;
      if (s == BookingStatus.diproses) return Colors.amber.shade800;
      return Colors.grey;
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
              color: getStatusColor(item.status),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              item.status.name.toUpperCase(),
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
                    _buildIconText(Icons.calendar_today, item.tanggalWaktu),
                    const SizedBox(height: 4),
                    _buildIconText(
                      Icons.motorcycle,
                      '${item.jenisKendaraan} (${item.platNomor})',
                    ),
                    const SizedBox(height: 4),
                    _buildIconText(Icons.business, item.bengkel),
                    const SizedBox(height: 10),
                    _buildIconText(
                      Icons.numbers,
                      'No. Antrian: ${item.noAntrian}',
                    ),
                  ],
                ),
              ),
              if (item.status == BookingStatus.diterima)
                SizedBox(
                  height: 30,
                  child: ElevatedButton(
                    onPressed: () {},
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
