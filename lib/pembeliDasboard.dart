import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'detailProdukPage.dart';
import 'models/barang.dart';
import 'pembeliProfil.dart';
import 'tukarMerchandisePage.dart';

class PembeliDashboardPage extends StatefulWidget {
  const PembeliDashboardPage({super.key});

  @override
  State<PembeliDashboardPage> createState() => _PembeliDashboardPageState();
}

class _PembeliDashboardPageState extends State<PembeliDashboardPage> {
  List<Barang> barangList = [];
  bool isLoading = true;
  int? idPembeli;

  @override
  void initState() {
    super.initState();
    _loadIdPembeli();
    fetchBarang();
  }

  Future<void> _loadIdPembeli() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      idPembeli = prefs.getInt('idPembeli');
    });
  }

  Future<void> fetchBarang() async {
    final url = Uri.parse('https://reusemartkf.barioth.web.id/api/barang');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List barangData = data['data'];
        setState(() {
          barangList = barangData.map((item) => Barang.fromJson(item)).toList();
          isLoading = false;
        });
      } else {
        throw Exception('Gagal memuat data barang');
      }
    } catch (e) {
      print('Error: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  int _selectedIndex = 0;

  void _onNavItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    if (index == 1 && idPembeli != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => TukarMerchandisePage(idPembeli: idPembeli!),
        ),
      );
    } else if (index == 2 && idPembeli != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => PembeliProfilPage(idPembeli: idPembeli!),
        ),
      );
    } else if (index == 2) {
      // Tampilkan pesan jika idPembeli belum tersedia
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('ID Pembeli tidak ditemukan')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.green[800],
        automaticallyImplyLeading: false,
        title: const Row(
          children: [
            Icon(Icons.shopping_cart, color: Colors.white),
            SizedBox(width: 8),
            Text(
              "Dashboard Pembeli",
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: GridView.builder(
                itemCount: barangList.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 0.70,
                ),
                itemBuilder: (context, index) {
                  final barang = barangList[index];
                  return InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              DetailProdukPage(barang: barang),
                        ),
                      );
                    },
                    child: Card(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      elevation: 4,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ClipRRect(
                            borderRadius: const BorderRadius.vertical(
                                top: Radius.circular(12)),
                            child: Image.network(
                              'https://reusemartkf.barioth.web.id/storage/${barang.gambar}',
                              height: 170,
                              width: double.infinity,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) =>
                                  const Icon(Icons.broken_image),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              barang.nama,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 8.0),
                            child: Text(
                              'Rp ${barang.harga}',
                              style: const TextStyle(
                                fontSize: 13,
                                color: Colors.grey,
                              ),
                            ),
                          ),
                          Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 8.0),
                            child: Text(
                              'Status: ${barang.status}',
                              style: TextStyle(
                                fontSize: 12,
                                color: barang.status.toLowerCase() == 'tersedia'
                                    ? Colors.green
                                    : barang.status.toLowerCase() == 'terjual'
                                        ? Colors.red
                                        : Colors.grey,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
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
            icon: Icon(Icons.card_giftcard),
            label: 'Tukar Merchandise',
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
