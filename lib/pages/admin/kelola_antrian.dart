import 'package:flutter/material.dart';

class KelolaAntrian extends StatefulWidget {
  const KelolaAntrian({super.key});

  @override
  State<KelolaAntrian> createState() => _KelolaAntrianState();
}

class _KelolaAntrianState extends State<KelolaAntrian> {
  // Data Dummy dipindah ke sini (state) agar tidak dibuat ulang terus menerus
  final List<Map<String, dynamic>> dataAntrian = [
    {
      "name": "Damara Rafiandriza P",
      "status": "Diterima",
      "color": Colors.blue,
      "date": "12 Desember 2026 - 16:00 WIB",
      "jenis": "KSG",
    },
    {
      "name": "Nathania Ardelia",
      "status": "Diterima",
      "color": Colors.blue,
      "date": "12 Desember 2026 - 18:00 WIB",
      "jenis": "KSG",
    },
    {
      "name": "Endah Retno Kinanti",
      "status": "Menunggu",
      "color": Colors.amber,
      "textColor": Colors.black,
      "date": "13 Desember 2026 - 08:00 WIB",
      "jenis": "KSG",
    },
    {
      "name": "Budi Santoso",
      "status": "Ditolak",
      "color": Colors.red,
      "date": "14 Desember 2026 - 09:00 WIB",
      "jenis": "KSG",
    },
    {
      "name": "Siti Aminah",
      "status": "Selesai",
      "color": Colors.green,
      "date": "14 Desember 2026 - 10:00 WIB",
      "jenis": "KSG",
    },
  ];

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
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            itemCount: dataAntrian.length,
            itemBuilder: (context, index) {
              final item = dataAntrian[index];
              return Card(
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
                      // Badge Status
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: item['color'],
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          item['status'],
                          style: TextStyle(
                            color: item['textColor'] ?? Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        item['name'],
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        item['date'],
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        item['jenis'],
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
