import 'package:flutter/material.dart';

import 'models/barang.dart';

class DetailProdukPage extends StatelessWidget {
  final Barang barang;

  const DetailProdukPage({super.key, required this.barang});

  @override
  Widget build(BuildContext context) {
    final List<String> gambarList = [
      barang.gambar2,
      barang.gambar3,
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(barang.nama),
        backgroundColor: Colors.green[800],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Grid gambar 2x2 tapi hanya 2 gambar (gambar2 dan gambar3)
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: gambarList.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 8,
                  crossAxisSpacing: 8,
                  childAspectRatio: 1,
                ),
                itemBuilder: (context, index) {
                  final gambar = gambarList[index];
                  return ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      'http://10.0.2.2:8000/storage/$gambar',
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) =>
                          const Icon(Icons.broken_image),
                    ),
                  );
                },
              ),
            ),

            // Detail informasi produk
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Align(
                alignment: Alignment.centerLeft, // Memastikan isi rata kiri secara horizontal
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start, // Anak-anak Column juga rata kiri
                  mainAxisSize: MainAxisSize.min, // Supaya column sesuaikan tinggi isinya
                  children: [
                    Text(
                      barang.nama,
                      style: const TextStyle(
                        fontSize: 22, 
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.left, // Ini opsional, karena Column sudah atur rata kiri
                    ),
                    Text(
                      'Rp ${barang.harga}',
                      textAlign: TextAlign.left,
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Deskripsi: ${barang.deskripsi}',
                      textAlign: TextAlign.left,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Garansi sampai: ${barang.garansi == null || barang.garansi.isEmpty ? "-" : barang.garansi}',
                      textAlign: TextAlign.left,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Berat: ${barang.berat.toStringAsFixed(2)} kg',
                      textAlign: TextAlign.left,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
