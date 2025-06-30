import 'package:flutter/material.dart';

import 'models/barang.dart';

class DetailProdukPage extends StatelessWidget {
  final Barang barang;

  const DetailProdukPage({super.key, required this.barang});

  // Fungsi untuk mengecek status garansi
  String _cekGaransi(String? garansi) {
    if (garansi == null || garansi.isEmpty) {
      return 'Barang tidak punya garansi';
    }

    try {
      final garansiDate = DateTime.parse(garansi);
      final today = DateTime.now();

      if (garansiDate.isBefore(today)) {
        return 'Barang sudah tidak bergaransi';
      } else {
        return 'Garansi sampai: $garansi';
      }
    } catch (e) {
      return 'Barang tidak punya garansi';
    }
  }

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
                      'https://reusemartkf.barioth.web.id/storage/$gambar',
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
                alignment: Alignment.centerLeft,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      barang.nama,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Rp ${barang.harga}',
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Deskripsi: ${barang.deskripsi}',
                      style: const TextStyle(fontSize: 14),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _cekGaransi(barang.garansi),
                      style: TextStyle(
                        fontSize: 14,
                        color: _cekGaransi(barang.garansi) ==
                                'Barang sudah tidak bergaransi'
                            ? Colors.red
                            : Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Berat: ${barang.berat.toStringAsFixed(2)} kg',
                      style: const TextStyle(fontSize: 14),
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
