import 'barang.dart';

class Pembelian {
  final int idPembelian;
  final String tanggalPembelian;
  final String? tanggalDiterima;
  final int totalBayar;
  final List<Barang> barangs;

  Pembelian({
    required this.idPembelian,
    required this.tanggalPembelian,
    required this.totalBayar,
    this.tanggalDiterima,
    required this.barangs,
  });

  factory Pembelian.fromJson(Map<String, dynamic> json) {
    return Pembelian(
      idPembelian: json['ID_PEMBELIAN'],
      tanggalPembelian: json['TANGGAL_PEMBELIAN'],
      tanggalDiterima: json['TANGGAL_DITERIMA'],
      totalBayar: json['TOTAL_BAYAR'],
      barangs: (json['barangs'] as List)
          .map((item) => Barang.fromJson(item))
          .toList(),
    );
  }
}
