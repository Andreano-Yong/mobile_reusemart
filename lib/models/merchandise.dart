class Merchandise {
  final int id;
  final String nama;
  final String gambar;
  final int stok;
  final int poinDiperlukan;

  Merchandise({
    required this.id,
    required this.nama,
    required this.gambar,
    required this.stok,
    required this.poinDiperlukan,
  });

  factory Merchandise.fromJson(Map<String, dynamic> json) {
    return Merchandise(
      id: json['ID_MERCHANDISE'],
      nama: json['NAMA_MERCHANDISE'],
      gambar: json['GAMBAR_MERCHANDISE'],
      stok: json['STOK_MERCHANDISE'],
      poinDiperlukan: json['POIN_DIPERLUKAN'],
    );
  }
}
