import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class PembeliProfilPage extends StatefulWidget {
  final int idPembeli;
  const PembeliProfilPage({required this.idPembeli, Key? key}) : super(key: key);

  @override
  State<PembeliProfilPage> createState() => _PembeliProfilPageState();
}

class _PembeliProfilPageState extends State<PembeliProfilPage> {
  Map<String, dynamic>? profilData;
  List<dynamic> riwayatPembelian = [];
  Map<String, dynamic>? alamatDefault;
  String? errorMessage;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<void> fetchData() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final profilResponse = await http.get(
        Uri.parse('http://10.0.2.2:8000/api/pembeli/${widget.idPembeli}'),
      );

      final pembelianResponse = await http.get(
        Uri.parse('http://10.0.2.2:8000/api/pembelian/pembeli/${widget.idPembeli}'),
      );

      final alamatResponse = await http.get(
        Uri.parse('http://10.0.2.2:8000/api/alamat/pembeli/${widget.idPembeli}'),
      );

      if (profilResponse.statusCode == 200 &&
          pembelianResponse.statusCode == 200 &&
          alamatResponse.statusCode == 200) {
        final profilJson = jsonDecode(profilResponse.body);
        final pembelianJson = jsonDecode(pembelianResponse.body);
        final alamatJson = jsonDecode(alamatResponse.body);

        if (profilJson['success'] == true) {
          final alamatList = alamatJson['data'] as List<dynamic>;
          final defaultAlamat = alamatList.firstWhere(
            (alamat) => alamat['IS_DEFAULT'] == 1,
            orElse: () => null,
          );

          setState(() {
            profilData = profilJson['data'];
            riwayatPembelian = pembelianJson['data'];
            alamatDefault = defaultAlamat;
            isLoading = false;
          });
        } else {
          setState(() {
            errorMessage = profilJson['message'] ?? 'Data profil tidak ditemukan';
            isLoading = false;
          });
        }
      } else {
        setState(() {
          errorMessage = 'Gagal memuat data. Status: ${profilResponse.statusCode}/${pembelianResponse.statusCode}/${alamatResponse.statusCode}';
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = 'Terjadi kesalahan saat mengambil data: $e';
        isLoading = false;
      });
    }
  }

  Widget buildProfileItem(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(icon, color: Colors.green[700], size: 28),
          const SizedBox(width: 16),
          Text(
            '$label:',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
              color: Colors.green[900],
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 18),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget buildRiwayatPembelian() {
    if (riwayatPembelian.isEmpty) {
      return const Text('Belum ada riwayat transaksi.');
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: riwayatPembelian.length,
      itemBuilder: (context, index) {
        final transaksi = riwayatPembelian[index];
        final barangList = transaksi['barangs'] as List<dynamic>;
        return Card(
          margin: const EdgeInsets.symmetric(vertical: 8),
          elevation: 3,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Tanggal: ${transaksi['TANGGAL_PEMBELIAN'] ?? 'N/A'}',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text('Diterima: ${transaksi['TANGGAL_DITERIMA'] ?? '-'}'),
                const SizedBox(height: 4),
                Text('Total Bayar: Rp ${transaksi['TOTAL_BAYAR']}'),
                const SizedBox(height: 8),
                const Text('Barang:', style: TextStyle(fontWeight: FontWeight.bold)),
                ...barangList.map((barang) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 2.0),
                    child: Text('- ${barang['NAMA_BARANG']}'),
                  );
                }).toList(),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget buildAlamatDefault() {
    if (alamatDefault == null) {
      return const Text('Belum ada alamat default.');
    }

    return Card(
      margin: const EdgeInsets.only(top: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(Icons.home, color: Colors.green[800]),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Alamat Utama:', style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text(
                    '${alamatDefault!['NAMA_JALAN']}, ${alamatDefault!['KELURAHAN']}, ${alamatDefault!['KECAMATAN']}, ${alamatDefault!['KOTA']}, ${alamatDefault!['KODE_POS']}',
                    style: const TextStyle(fontSize: 16),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profil Pembeli'),
        backgroundColor: Colors.green[700],
      ),
      body: Center(
        child: isLoading
            ? const CircularProgressIndicator()
            : errorMessage != null
                ? Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(
                      errorMessage!,
                      style: const TextStyle(color: Colors.red, fontSize: 16),
                      textAlign: TextAlign.center,
                    ),
                  )
                : profilData != null
                    ? SingleChildScrollView(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          children: [
                            Card(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              elevation: 6,
                              shadowColor: Colors.green.withOpacity(0.5),
                              child: Padding(
                                padding: const EdgeInsets.all(24.0),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Center(
                                      child: CircleAvatar(
                                        radius: 50,
                                        backgroundColor: Colors.green[100],
                                        child: Icon(
                                          Icons.person,
                                          size: 60,
                                          color: Colors.green[700],
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 24),
                                    buildProfileItem(Icons.person, 'Nama', profilData!['nama']),
                                    buildProfileItem(Icons.email, 'Email', profilData!['email']),
                                    buildProfileItem(Icons.phone, 'Telepon', profilData!['telepon']),
                                    buildProfileItem(Icons.star, 'Poin', profilData!['poin'].toString()),
                                    buildAlamatDefault(),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(height: 24),
                            const Text(
                              'Riwayat Transaksi',
                              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 8),
                            buildRiwayatPembelian(),
                          ],
                        ),
                      )
                    : const Text('Data profil tidak tersedia'),
      ),
    );
  }
}
