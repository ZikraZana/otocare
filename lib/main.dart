import 'package:flutter/material.dart';
import 'package:otocare/pages/auth/login.dart';
import 'package:firebase_core/firebase_core.dart';
// import 'package:otocare/pages/user/dashboard_user.dart'; // (Tidak wajib di main jika tidak dipakai langsung)
// import 'package:otocare/pages/user/form_booking.dart';   // (Tidak wajib di main jika tidak dipakai langsung)
import 'firebase_options.dart';

// --- TAMBAHAN PENTING ---
import 'package:intl/date_symbol_data_local.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // --- INISIALISASI FORMAT TANGGAL INDONESIA DISINI ---
  await initializeDateFormatting('id_ID', null);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'OtoCare',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFFD72638)),
        fontFamily: 'Nunito',
        useMaterial3: true,
      ),
      home: const LoginPage(),
    );
  }
}
