import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'penitipProfil.dart';



class PenitipDashboard extends StatefulWidget {
  final int idPenitip;
  const PenitipDashboard({Key? key, required this.idPenitip}) : super(key: key);

  @override
  State<PenitipDashboard> createState() => _PenitipDashboardState();
}

class _PenitipDashboardState extends State<PenitipDashboard> {
  List<Barang> barangList = [];
  bool isLoading = true;
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    fetchBarangHistory();
  }

  Future<void> fetchBarangHistory() async {
    final url = Uri.parse('http://10.0.2.2:8000/api/penitip-mobile/${widget.idPenitip}/history-barang');

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);
        setState(() {
          barangList = data.map((item) => Barang.fromJson(item)).toList();
          isLoading = false;
        });
      } else {
        throw Exception('Failed to load data');
      }
    } catch (e) {
      print(e);
      setState(() {
        isLoading = false;
      });
    }
  }

  String formatDate(String dateStr) {
    if (dateStr.length >= 10) {
      return dateStr.substring(0, 10); // yyyy-MM-dd
    }
    return dateStr;
  }

  void _onNavItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    if (index == 1) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => PenitipProfilPage(idPenitip: widget.idPenitip),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green[700],
        title: const Row(
          children: [
            Icon(Icons.inventory, color: Colors.white),
            SizedBox(width: 8),
            Text('Dashboard Penitip', style: TextStyle(color: Colors.white)),
          ],
        ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : barangList.isEmpty
              ? const Center(child: Text("Tidak ada data barang."))
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      child: Text(
                        'History Transaksi Penitipan',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.green[800],
                        ),
                      ),
                    ),
                    Expanded(
                      child: ListView.builder(
                        itemCount: barangList.length,
                        itemBuilder: (context, index) {
                          final barang = barangList[index];
                          return Card(
                            margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            elevation: 3,
                            child: ListTile(
                              leading: Image.network(
                                'http://10.0.2.2:8000/storage/${barang.gambar}',
                                width: 60,
                                height: 60,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) =>
                                    const Icon(Icons.broken_image),
                              ),
                              title: Text(barang.nama),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const SizedBox(height: 4),
                                  Text("Tanggal Titip: ${formatDate(barang.penitipan.tanggalPenitipan)}"),
                                  Text("Berakhir: ${formatDate(barang.penitipan.tanggalBerakhir)}"),
                                  Text("Status: ${barang.status}"),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
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


// Model Barang sesuai yang kamu punya, tapi tambahan properti Penitipan
class Barang {
  final String nama;
  final int harga;
  final String gambar;
  final String gambar2;
  final String gambar3;
  final String status;
  final String deskripsi;
  final String garansi;
  final double berat;
  final Penitipan penitipan;

  Barang({
    required this.nama,
    required this.harga,
    required this.gambar,
    required this.gambar2,
    required this.gambar3,
    required this.status,
    required this.deskripsi,
    required this.garansi,
    required this.berat,
    required this.penitipan,
  });

  factory Barang.fromJson(Map<String, dynamic> json) {
    return Barang(
      nama: json['NAMA_BARANG'] ?? '',
      harga: json['HARGA_BARANG'] ?? 0,
      gambar: json['GAMBAR_1'] ?? '',
      gambar2: json['GAMBAR_2'] ?? '',
      gambar3: json['GAMBAR_3'] ?? '',
      status: json['STATUS_BARANG'] ?? '',
      deskripsi: json['DESKRIPSI_BARANG'] ?? '',
      garansi: json['GARANSI'] ?? '',
      berat: (json['BERAT'] != null)
          ? double.tryParse(json['BERAT'].toString()) ?? 0.0
          : 0.0,
      penitipan: Penitipan.fromJson(json), // Ambil data penitipan langsung dari JSON flat
    );
  }
}

// Model Penitipan sesuai yang kamu punya
class Penitipan {
  final String tanggalPenitipan;
  final String tanggalBerakhir;

  Penitipan({
    required this.tanggalPenitipan,
    required this.tanggalBerakhir,
  });

  factory Penitipan.fromJson(Map<String, dynamic> json) {
    return Penitipan(
      tanggalPenitipan: json['TANGGAL_PENITIPAN'] ?? '',
      tanggalBerakhir: json['TANGGAL_BERAKHIR'] ?? '',
    );
  }
}
