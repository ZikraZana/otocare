import 'package:flutter/material.dart';

class RiwayatAntrianPage extends StatefulWidget {
  const RiwayatAntrianPage({super.key});
  @override
  RiwayatAntrianPageState createState() => RiwayatAntrianPageState();
}

class RiwayatAntrianPageState extends State<RiwayatAntrianPage> {
  int selectedTab = 0; 

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF2B2B2B),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start, 
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "OtoCare",
                    style: TextStyle(
                      fontFamily: "Nunito",
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 10),
                  Container( 
                      height: 1,
                      color: Colors.white24, 
                    ),
                  SizedBox(height: 10),
                  Text(
                    "Riwayat Antrian",
                    style: TextStyle(
                      fontFamily: "Nunito",
                      fontSize: 24,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),

            /// TAB
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildTab("Selesai", 0),
                SizedBox(width: 30),
                _buildTab("Ditolak", 1),
              ],
            ),

            SizedBox(height: 10),

            /// LIST DATA
            Expanded(
              child: ListView(
                padding: EdgeInsets.symmetric(horizontal: 18),
                children: [
                  if (selectedTab == 0) ..._buildSelesaiList(),
                  if (selectedTab == 1) ..._buildDitolakList(),
                ],
              ),
            ),
            Container(
              height: 1, 
              color: Colors.white24, 
            ),
          ],
        ),
      ),

      /// NAV BOTTOM
      bottomNavigationBar: _bottomNav(),
    );
  }

  /// TAB ITEM
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
              color: active ? Color(0xFFFFD700) : Colors.grey,
            ),
          ),
          SizedBox(height: 4),
          Container(
            width: 50,
            height: 2,
            color: active ? Color(0xFFFFD700) : Colors.transparent,
          )
        ],
      ),
    );
  }

  /// LIST SELESAI
  List<Widget> _buildSelesaiList() {
    return [
      _bookingCard(
        statusColor: Colors.green,
        statusText: "Selesai",
        tanggal: "12 Desember 2026 - 16:00 WIB",
        motor: "Yamaha Mio",
        kategori: "KSG",
        onTap: () => _detailPopupSelesai(),
      ),
      _bookingCard(
        statusColor: Colors.green,
        statusText: "Selesai",
        tanggal: "10 Desember 2026 - 16:00 WIB",
        motor: "Honda Beat",
        kategori: "KSG",
        onTap: () => _detailPopupSelesai(),
      ),
      _bookingCard(
        statusColor: Colors.green,
        statusText: "Selesai",
        tanggal: "05 Desember 2026 - 16:00 WIB",
        motor: "Yamaha Nmax",
        kategori: "KSG",
        onTap: () => _detailPopupSelesai(),
      ),
    ];
  }

  /// LIST DITOLAK
  List<Widget> _buildDitolakList() {
    return [
      _bookingCard(
        statusColor: Colors.red,
        statusText: "Ditolak",
        tanggal: "12 Desember 2026 - 16:00 WIB",
        motor: "Yamaha Mio",
        kategori: "KSG",
        onTap: () => _detailPopupDitolak(),
      ),
      _bookingCard(
        statusColor: Colors.red,
        statusText: "Ditolak",
        tanggal: "10 Desember 2026 - 16:00 WIB",
        motor: "Honda Beat",
        kategori: "KSG",
        onTap: () => _detailPopupDitolak(),
      ),
    ];
  }

  /// CARD
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
        margin: EdgeInsets.only(bottom: 14),
        padding: EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: Color(0xFF4A4A4A),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 5),
              decoration: BoxDecoration(
                color: statusColor,
                borderRadius: BorderRadius.circular(30),
              ),
              child: Text(
                statusText,
                style: TextStyle(
                    color: Colors.white,
                    fontFamily: "Nunito",
                    fontWeight: FontWeight.bold),
              ),
            ),
            SizedBox(height: 10),

            Text(tanggal,
                style: TextStyle(fontFamily: "Nunito", fontSize: 15, color: Colors.white)),
            Text(motor,
                style: TextStyle(fontFamily: "Nunito", fontSize: 15, color: Colors.white)),
            Text(kategori,
                style: TextStyle(fontFamily: "Nunito", fontSize: 15, color: Colors.white)),
          ],
        ),
      ),
    );
  }

  /// POPUP SELESAI
  void _detailPopupSelesai() {
    showDialog(
      context: context,
      builder: (_) => Dialog(
        backgroundColor: Color(0xFF282828),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Container(
          padding: EdgeInsets.all(18),
          height: 360,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Detail Booking",
                  style: TextStyle(fontFamily: "Nunito", fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold)),
              SizedBox(height: 15),
              _row("Tanggal Booking", "12 Desember 2026 - 16:00 WIB"),
              _row("Tanggal Selesai", "12 Desember 2026 - 17:30 WIB"),
              _row("Jenis Kendaraan", "Mio"),
              _row("Merek Kendaraan", "Yamaha"),
              _row("No Plat", "BM 9218 BU"),
              _row("Kategori Servis", "KSG"),
              SizedBox(height: 10),
              Text("Status : Selesai", style: TextStyle(fontFamily: "Nunito", color: Colors.white)),
              Text("Detail Kendala : Motor saya pecah ban dan knalpot", style: TextStyle(fontFamily: "Nunito", color: Colors.white)),
              Spacer(),
              _closeButton(),
            ],
          ),
        ),
      ),
    );
  }

  /// POPUP DITOLAK
  void _detailPopupDitolak() {
    showDialog(
      context: context,
      builder: (_) => Dialog(
        backgroundColor: Color(0xFF282828),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Container(
          padding: EdgeInsets.all(18),
          height: 360,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Detail Booking",
                  style: TextStyle(fontFamily: "Nunito", fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold)),
              SizedBox(height: 12),
              _row("Tanggal Booking", "12 Desember 2026 - 16:00 WIB"),
              _row("Jenis Kendaraan", "Mio"),
              _row("Merek Kendaraan", "Yamaha"),
              _row("No Plat", "BM 9218 BU"),
              _row("Kategori Servis", "KSG"),
              SizedBox(height: 10),
              Text("Status : Ditolak", style: TextStyle(fontFamily: "Nunito", color: Colors.white)),
              Text("Alasan Penolakan: Bengkel penuh, mohon booking ulang besok",
                  style: TextStyle(fontFamily: "Nunito", color: Colors.white)),
              Spacer(),
              _closeButton(),
            ],
          ),
        ),
      ),
    );
  }

  /// ROW DETAIL
  Widget _row(String title, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          Expanded(
              flex: 3,
              child: Text(title,
                  style: TextStyle(fontFamily: "Nunito", color: Colors.white70))),
          Expanded(
              flex: 4,
              child: Text(value,
                  style: TextStyle(fontFamily: "Nunito", color: Colors.white))),
        ],
      ),
    );
  }

  /// BUTTON TUTUP
  Widget _closeButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Color(0xFF4A4A4A),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
        onPressed: () => Navigator.pop(context),
        child: Text(
          "Tutup",
          style: TextStyle(fontFamily: "Nunito", fontSize: 16, color: Colors.white),
        ),
      ),
    );
  }

  /// NAV BAR
  Widget _bottomNav() {
    return Container(
      height: 65,
      decoration: BoxDecoration(
        color: Color(0xFF2B2B2B),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _navIcon(Icons.home, "Beranda"),
          _navIcon(Icons.book, "Booking"),
          _navIcon(Icons.list_alt, "Antrian"),
          _navIcon(Icons.history, "Riwayat", active: true),
        ],
      ),
    );
  }

  Widget _navIcon(IconData icon, String label, {bool active = false}) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, color: active ? Colors.red : Colors.white),
        SizedBox(height: 3),
        Text(label,
            style: TextStyle(
                fontFamily: "Nunito",
                color: active ? Colors.red : Colors.white))
      ],
    );
  }
}
