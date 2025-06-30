import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'pembeliDasboard.dart';
import 'pembeliProfil.dart';

class Pembeli {
  final int id;
  final String nama;
  final String email;
  final String telepon;
  final int poin;

  Pembeli({
    required this.id,
    required this.nama,
    required this.email,
    required this.telepon,
    required this.poin,
  });

  factory Pembeli.fromJson(Map<String, dynamic> json) {
    return Pembeli(
      id: json['id'],
      nama: json['nama'] ?? '',
      email: json['email'] ?? '',
      telepon: json['telepon'] ?? '',
      poin: int.tryParse(json['poin'].toString()) ?? 0,
    );
  }
}

class TukarMerchandisePage extends StatefulWidget {
  final int idPembeli;

  const TukarMerchandisePage({super.key, required this.idPembeli});

  @override
  State<TukarMerchandisePage> createState() => _TukarMerchandisePageState();
}

class _TukarMerchandisePageState extends State<TukarMerchandisePage> {
  List<dynamic> merchList = [];
  int poinPembeli = 0;
  bool isLoading = true;
  bool isLoadingPoin = true;
  int _selectedIndex = 1;

  @override
  void initState() {
    super.initState();
    fetchPoinPembeli();
    fetchMerchandise();
  }

  Future<void> fetchPoinPembeli() async {
    final url = Uri.parse('https://reusemartkf.barioth.web.id/api/pembeli/${widget.idPembeli}');
    try {
      final response = await http.get(url);
      print("Response Pembeli: ${response.body}");

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final pembeli = Pembeli.fromJson(data['data']);
        setState(() {
          poinPembeli = pembeli.poin;
          isLoadingPoin = false;
        });
      } else {
        throw Exception('Gagal memuat poin pembeli');
      }
    } catch (e) {
      print("Error fetch poin: $e");
      setState(() {
        poinPembeli = 0;
        isLoadingPoin = false;
      });
    }
  }

  Future<void> fetchMerchandise() async {
    final url = Uri.parse('https://reusemartkf.barioth.web.id/api/merchandise');
    try {
      final response = await http.get(url);
      print("Response Merchandise: ${response.body}");

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          merchList = data['data'] ?? [];
          isLoading = false;
        });
      } else {
        throw Exception('Gagal memuat merchandise');
      }
    } catch (e) {
      print("Error fetch merchandise: $e");
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> tukarMerchandise(int idMerch, int poinDiperlukan, int stok) async {
    if (stok <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Stok merchandise habis.")),
      );
      return;
    }

    if (poinPembeli < poinDiperlukan) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Poin tidak cukup untuk menukar merchandise ini.")),
      );
      return;
    }

    final konfirmasi = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Konfirmasi Penukaran"),
        content: Text("Tukar merchandise ini dengan $poinDiperlukan poin?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text("Batal")),
          ElevatedButton(onPressed: () => Navigator.pop(context, true), child: const Text("Tukar")),
        ],
      ),
    );

    if (konfirmasi != true) return;

    final url = Uri.parse('https://reusemartkf.barioth.web.id/api/penukaranpoin');
    final now = DateTime.now().toIso8601String();

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          "id_merchandise": idMerch,
          "id_pembeli": widget.idPembeli,
          "tanggal_klaim": now,
        }),
      );

      if (response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Penukaran berhasil!")),
        );
        await fetchPoinPembeli();
        await fetchMerchandise();
      } else {
        final resBody = jsonDecode(response.body);
        String msg = resBody['message'] ?? 'Gagal menukar merchandise';
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
      }
    } catch (e) {
      print("Error tukar: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Terjadi kesalahan jaringan.")),
      );
    }
  }

  void _onNavItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    if (index == 0) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => PembeliDashboardPage()),
      );
    } else if (index == 2) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => PembeliProfilPage(idPembeli: widget.idPembeli)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Tukar Merchandise", style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.green[700],
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            onPressed: () {
              Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
            },
          ),
        ],
      ),
      body: (isLoading || isLoadingPoin)
          ? const Center(child: CircularProgressIndicator())
          : merchList.isEmpty
              ? const Center(child: Text("Belum ada merchandise tersedia."))
              : Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Text(
                        'Poin Anda: $poinPembeli',
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ),
                    Expanded(
                      child: ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: merchList.length,
                        itemBuilder: (context, index) {
                          final merch = merchList[index];
                          final String? gambar = merch['GAMBAR_MERCHANDISE'];
                          final String? nama = merch['NAMA_MERCHANDISE'];
                          final int stok = int.tryParse(merch['STOK_MERCHANDISE'].toString()) ?? 0;
                          final int poin = int.tryParse(merch['POIN_DIPERLUKAN'].toString()) ?? 0;
                          final int? idMerch = merch['ID_MERCHANDISE'];

                          return Card(
                            margin: const EdgeInsets.only(bottom: 16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                gambar != null
                                    ? Image.network(
                                        'https://reusemartkf.barioth.web.id/storage/$gambar',
                                        height: 180,
                                        width: double.infinity,
                                        fit: BoxFit.cover,
                                        errorBuilder: (context, error, stackTrace) =>
                                            const Icon(Icons.broken_image),
                                      )
                                    : Container(
                                        height: 180,
                                        color: Colors.grey[300],
                                        child: const Center(child: Icon(Icons.image_not_supported)),
                                      ),
                                Padding(
                                  padding: const EdgeInsets.all(12),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        nama ?? "Tanpa Nama",
                                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                      ),
                                      const SizedBox(height: 4),
                                      Text("Stok: $stok"),
                                      Text("Poin Diperlukan: $poin"),
                                      const SizedBox(height: 8),
                                      ElevatedButton(
                                        onPressed: () {
                                          if (idMerch != null) {
                                            tukarMerchandise(idMerch, poin, stok);
                                          }
                                        },
                                        child: const Text("Tukar"),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.green[700],
                                          foregroundColor: Colors.white,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
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
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Beranda'),
          BottomNavigationBarItem(icon: Icon(Icons.card_giftcard), label: 'Tukar Merchandise'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profil Akun'),
        ],
      ),
    );
  }
}
