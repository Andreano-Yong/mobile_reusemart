import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'KurirProfil.dart';

class KurirDashboardPage extends StatefulWidget {
  final int idKurir;

  const KurirDashboardPage({Key? key, required this.idKurir}) : super(key: key);

  @override
  _KurirDashboardPageState createState() => _KurirDashboardPageState();
}

class _KurirDashboardPageState extends State<KurirDashboardPage> {
  List<dynamic> daftarPengiriman = [];
  bool isLoading = false;
  int _selectedIndex = 0;
  String filterStatus = 'Semua';

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<void> fetchData() async {
    setState(() {
      isLoading = true;
    });

    try {
      final response = await http.get(
        Uri.parse('https://reusemartkf.barioth.web.id/api/pengiriman/kurir'),
      );

      if (response.statusCode == 200) {
        setState(() {
          daftarPengiriman = json.decode(response.body)['data'];
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal memuat data pengiriman')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Terjadi kesalahan: $e')),
      );
    }

    setState(() {
      isLoading = false;
    });
  }

  Future<void> updatePengiriman(int idPembelian, int index) async {
    try {
      final response = await http.post(
        Uri.parse('https://reusemartkf.barioth.web.id/api/pengiriman/selesai/$idPembelian'),
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Pengiriman berhasil diselesaikan')),
        );

        setState(() {
          daftarPengiriman[index]['STATUS_PENGIRIMAN'] = 'Selesai';
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal menyelesaikan pengiriman')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Terjadi kesalahan saat update: $e')),
      );
    }
  }

  void _onNavItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    if (index == 1) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => KurirProfilPage(idKurir: widget.idKurir),
        ),
      );
    }
  }

  List<dynamic> getFilteredPengiriman() {
    if (filterStatus == 'Semua') return daftarPengiriman;
    return daftarPengiriman.where((item) => item['STATUS_PENGIRIMAN'] == filterStatus).toList();
  }

  @override
  Widget build(BuildContext context) {
    final filteredList = getFilteredPengiriman();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green[700],
        title: const Row(
          children: [
            Icon(Icons.local_shipping, color: Colors.white),
            SizedBox(width: 8),
            Text('Dashboard Kurir', style: TextStyle(color: Colors.white)),
          ],
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: DropdownButtonFormField<String>(
              value: filterStatus,
              decoration: InputDecoration(
                labelText: 'Filter Status',
                border: OutlineInputBorder(),
              ),
              items: ['Semua', 'Dikirim', 'Selesai']
                  .map((status) => DropdownMenuItem<String>(
                        value: status,
                        child: Text(status),
                      ))
                  .toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    filterStatus = value;
                  });
                }
              },
            ),
          ),
          Expanded(
            child: isLoading
                ? Center(child: CircularProgressIndicator())
                : filteredList.isEmpty
                    ? Center(child: Text('Tidak ada pengiriman dengan status "$filterStatus"'))
                    : ListView.builder(
                        itemCount: filteredList.length,
                        itemBuilder: (context, index) {
                          final pembelian = filteredList[index];
                          final alamat = pembelian['alamat'];
                          final barangList = pembelian['detail_pembelian']
                                  ?.map((item) => item['barang']?['NAMA_BARANG'])
                                  ?.toList()
                                  ?.join(', ') ??
                              'Barang tidak tersedia';

                          final status = pembelian['STATUS_PENGIRIMAN'];

                          return Card(
                            margin: EdgeInsets.all(8),
                            child: Padding(
                              padding: EdgeInsets.all(12),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Tanggal Pengiriman: ${pembelian['TANGGAL_PENGIRIMAN'] ?? '-'}",
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                  SizedBox(height: 4),
                                  Text("Pembeli: ${pembelian['pembeli']?['NAMA_PEMBELI'] ?? '-'}"),
                                  Text("Alamat: ${alamat?['NAMA_JALAN'] ?? '-'}, ${alamat?['KELURAHAN'] ?? ''}, ${alamat?['KECAMATAN'] ?? ''}"),
                                  Text("Barang: $barangList"),
                                  Text("Total Bayar: Rp ${pembelian['TOTAL_BAYAR']}"),
                                  SizedBox(height: 8),
                                  Text(
                                    "Status: ${status == 'Selesai' ? 'Selesai ✅' : 'Dikirim 📦'}",
                                    style: TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                  if (status == 'Dikirim')
                                    ElevatedButton(
                                      onPressed: () {
                                        updatePengiriman(pembelian['ID_PEMBELIAN'], index);
                                      },
                                      child: Text('Tandai Selesai'),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.green,
                                      ),
                                    ),
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