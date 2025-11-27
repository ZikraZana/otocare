import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Tambahan buat database

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  bool isAgreed = false;
  bool isLoading = false;

  final TextEditingController _namaLengkapController = TextEditingController();
  final TextEditingController _nomorHandphoneController =
      TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _konfirmasiPasswordController =
      TextEditingController();

  // Fungsi Register
  Future<void> _handleRegister() async {
    // 1. Validasi Input
    if (_emailController.text.isEmpty ||
        _passwordController.text.isEmpty ||
        _namaLengkapController.text.isEmpty ||
        _nomorHandphoneController.text.isEmpty) {
      // Tambah validasi No HP
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Semua data wajib diisi!")));
      return;
    }

    if (_passwordController.text != _konfirmasiPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Konfirmasi password tidak cocok!")),
      );
      return;
    }

    if (!isAgreed) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Kamu harus menyetujui syarat & ketentuan"),
        ),
      );
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      // 2. Buat User di Authentication
      UserCredential userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(
            email: _emailController.text.trim(),
            password: _passwordController.text.trim(),
          );

      // Update Display Name di Auth
      await userCredential.user?.updateDisplayName(_namaLengkapController.text);

      // 3. Simpan Biodata Lengkap ke Firestore Database
      // Kita pakai UID user sebagai nama dokumen biar gampang dicari
      await FirebaseFirestore.instance
          .collection('users') // Nama koleksi di database
          .doc(userCredential.user!.uid) // Nama dokumen = UID User
          .set({
            'uid': userCredential.user!.uid,
            'nama': _namaLengkapController.text,
            'email': _emailController.text.trim(),
            'nomor_hp': _nomorHandphoneController.text
                .trim(), // Akhirnya tersimpan!
            'role': 'user', // Bisa diatur 'user' atau 'admin' sesuai kebutuhan
            'created_at': FieldValue.serverTimestamp(),
          });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Registrasi Berhasil! Data tersimpan."),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      }
    } on FirebaseAuthException catch (e) {
      String message = e.message ?? "Terjadi kesalahan";
      if (e.code == 'weak-password') message = "Password terlalu lemah";
      if (e.code == 'email-already-in-use') message = "Email sudah terdaftar";

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message), backgroundColor: Colors.red),
        );
      }
    } catch (e) {
      // Catch error lain (misal koneksi database putus)
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error: $e"), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF2B2B2B),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Column(
                  children: [
                    const Icon(
                      Icons.two_wheeler,
                      size: 80,
                      color: Colors.white,
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      "OtoCare",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 30,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 50),
              const Text(
                "Daftarkan Dirimu!",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Text(
                "Masukkan datamu disini",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 40),
              _buildInput(_namaLengkapController, "Nama Lengkap"),

              const SizedBox(height: 10),
              _buildInput(
                _nomorHandphoneController,
                "Nomor Handphone (Whatsapp)",
              ),

              const SizedBox(height: 10),
              _buildInput(_emailController, "Email"),

              const SizedBox(height: 10),
              _buildInput(_passwordController, "Password Baru", obscure: true),

              const SizedBox(height: 10),
              _buildInput(
                _konfirmasiPasswordController,
                "Konfirmasi Password",
                obscure: true,
              ),

              const SizedBox(height: 20),
              Row(
                children: [
                  SizedBox(
                    height: 24,
                    width: 24,
                    child: Checkbox(
                      value: isAgreed,
                      activeColor: const Color(0xFFD72638),
                      checkColor: Colors.black,
                      side: const BorderSide(color: Colors.white, width: 2),
                      onChanged: (bool? value) =>
                          setState(() => isAgreed = value ?? false),
                    ),
                  ),
                  const SizedBox(width: 10),
                  const Text(
                    "Syarat dan Ketentuan",
                    style: TextStyle(color: Colors.white),
                  ),
                ],
              ),
              const SizedBox(height: 5),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: isLoading ? null : _handleRegister,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFD72638),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text(
                    "Daftar Sekarang",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    "Udah punya akun? ",
                    style: TextStyle(color: Colors.white),
                  ),
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: const Text(
                      "Masuk Disini!",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Template Input
  Widget _buildInput(
    TextEditingController controller,
    String hint, {
    bool obscure = false,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscure,
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.white,
        hintText: hint,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 10,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}
