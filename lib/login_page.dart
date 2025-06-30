import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'penitipDashboard.dart'; // pastikan import ini ada

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  bool isLoading = false;

  Future<void> simpanIdPembeli(int idPembeli) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('idPembeli', idPembeli);
  }

  Future<void> simpanIdPenitip(int idPenitip) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('idPenitip', idPenitip);
  }

  Future<void> simpanIdHunter(int idHunter) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('idHunter', idHunter);
  }

  Future<void> login() async {
    final email = emailController.text.trim();
    final password = passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      showMessage('Email dan password tidak boleh kosong');
      return;
    }

    setState(() => isLoading = true);

    try {
      final response = await http.post(
        Uri.parse('https://reusemartkf.barioth.web.id/api/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'password': password}),
      );

      setState(() => isLoading = false);

      if (response.statusCode == 200) {
        final result = jsonDecode(response.body);
        final role = result['role'];
        final data = result['data'];

        if (role == 'pembeli') {
          final idPembeli = int.tryParse(data['ID_PEMBELI'].toString()) ?? 0;
          if (idPembeli > 0) {
            await simpanIdPembeli(idPembeli);
            Navigator.pushReplacementNamed(context, '/pembeliDashboard');
          } else {
            showMessage('Data pembeli tidak ditemukan.');
          }

        } else if (role == 'penitip') {
          final idPenitip = int.tryParse(data['ID_PENITIP'].toString()) ?? 0;
          if (idPenitip > 0) {
            await simpanIdPenitip(idPenitip);
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => PenitipDashboardPage(idPenitip: idPenitip),
              ),
            );
          } else {
            showMessage('Data penitip tidak ditemukan.');
          }

        } else if (role == 'kurir') {
          final idKurir = int.tryParse(data['ID_PEGAWAI'].toString()) ?? 0;
          if (idKurir > 0) {
            Navigator.pushReplacementNamed(
              context,
              '/kurirDashboard',
              arguments: idKurir,
            );
          } else {
            showMessage('Data kurir tidak ditemukan.');
          }

        } else if (role == 'hunter') {
          final idHunter = int.tryParse(data['ID_HUNTER'].toString()) ?? 0;
          if (idHunter > 0) {
            await simpanIdHunter(idHunter);
            Navigator.pushReplacementNamed(
              context,
              '/hunterDashboard',
              arguments: idHunter,
            );
          } else {
            showMessage('Data hunter tidak ditemukan.');
          }

        } else {
          showMessage('Role tidak dikenali.');
        }

      } else {
        try {
          final error = jsonDecode(response.body);
          showMessage(error['error'] ?? 'Login gagal');
        } catch (_) {
          showMessage('Login gagal. Periksa kembali email dan password Anda.');
        }
      }
    } catch (e) {
      setState(() => isLoading = false);
      showMessage('Terjadi kesalahan: $e');
    }
  }

  void showMessage(String message) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Login Gagal'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                'assets/images/logo.jpg',
                height: 100,
              ),
              const SizedBox(height: 16),
              const Text(
                'Selamat Datang! Login Menggunakan Username dan Password Anda',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.normal,
                  color: Colors.green,
                ),
              ),
              const SizedBox(height: 32),
              TextField(
                controller: emailController,
                decoration: const InputDecoration(
                  labelText: 'Email Pengguna',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.email),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: passwordController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Password',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.lock),
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF006400),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: isLoading ? null : login,
                  child: isLoading
                      ? const CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        )
                      : const Text(
                          'Login',
                          style: TextStyle(fontSize: 16, color: Colors.white),
                        ),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    side: const BorderSide(color: Colors.grey),
                  ),
                  onPressed: () {
                    Navigator.pushReplacementNamed(context, '/tamuDashboard');
                  },
                  child: const Text(
                    'Masuk sebagai Tamu',
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
