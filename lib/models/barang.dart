class Barang {
  final String nama;
  final int harga;
  final String gambar;
  final String gambar2;
  final String gambar3;
  final String status;
  final String deskripsi;
  final String garansi; // atau DateTime jika ingin parsing tanggal
  final double berat;

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
      garansi: json['GARANSI'] ?? '', // atau convert ke DateTime jika perlu
      berat: (json['BERAT'] != null)
          ? double.tryParse(json['BERAT'].toString()) ?? 0.0
          : 0.0,
    );
  }
}
