import 'package:flutter/material.dart';
import 'package:otocare/pages/auth/login.dart';

void main() {
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
