import 'package:flutter/material.dart';
import 'package:otocare/pages/auth/login.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:otocare/pages/user/dashboard_user.dart';
import 'package:otocare/pages/user/form_booking.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

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
