import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'kurirDashboard.dart';

class KurirProfilPage extends StatefulWidget {
  final int idKurir;

  const KurirProfilPage({Key? key, required this.idKurir}) : super(key: key);

  @override
  State<KurirProfilPage> createState() => _KurirProfilPageState();
}

class _KurirProfilPageState extends State<KurirProfilPage> {
  Map<String, dynamic>? profil;
  bool isLoading = true;
  int _selectedIndex = 1;

  @override
  void initState() {
    super.initState();
    fetchProfil();
  }

  Future<void> fetchProfil() async {
    final response = await http.get(
      Uri.parse('https://reusemartkf.barioth.web.id/api/kurir/${widget.idKurir}/profil'),
    );

    if (response.statusCode == 200) {
      setState(() {
        profil = json.decode(response.body);
        isLoading = false;
      });
    } else {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Gagal memuat data profil kurir')),
      );
    }
  }

  Widget buildProfileTile(String label, String value, IconData icon) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ListTile(
        leading: Icon(icon, color: Colors.green[700]),
        title: Text(label,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
        subtitle: Text(value, style: const TextStyle(fontSize: 16)),
      ),
    );
  }

    void _onNavItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    if (index == 0) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => KurirDashboardPage(idKurir: widget.idKurir),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profil Kurir'),
        backgroundColor: Colors.green[700],
        foregroundColor: Colors.white,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : profil == null
              ? const Center(child: Text('Data tidak tersedia'))
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      CircleAvatar(
                        radius: 50,
                        backgroundColor: Colors.green[100],
                        child: Icon(Icons.person, size: 50, color: Colors.green[700]),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        profil!['NAMA_PEGAWAI'],
                        style: theme.textTheme.titleLarge!.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.green[900],
                        ),
                      ),
                      const SizedBox(height: 24),
                      buildProfileTile(
                        'ID Pegawai',
                        'ReuseMart-Kurir${profil!['ID_PEGAWAI']}',
                        Icons.badge,
                      ),
                      buildProfileTile('Email', profil!['EMAIL_PEGAWAI'], Icons.email),
                      buildProfileTile('No Telepon', profil!['NOTELP_PEGAWAI'], Icons.phone),
                      buildProfileTile('Tanggal Lahir', profil!['TGL_LAHIR'], Icons.cake),
                      const SizedBox(height: 24),
                      ElevatedButton.icon(
                        onPressed: () {
                          Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
                        },
                        icon: const Icon(Icons.logout),
                        label: const Text('Logout'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.grey[600],
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
        bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.white,
        selectedItemColor: Colors.green[800],
        unselectedItemColor: Colors.grey,
        currentIndex: _selectedIndex,
        onTap: _onNavItemTapped,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Beranda',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profil Akun',
          ),
        ],
      ),
    );
  }
}
