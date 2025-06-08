class Pembeli {
  final int id;
  final String nama;
  final String email;
  final String nomorTelepon;
  final int poin;

  Pembeli({
    required this.id,
    required this.nama,
    required this.email,
    required this.nomorTelepon,
    required this.poin,
  });

  factory Pembeli.fromJson(Map<String, dynamic> json) {
    return Pembeli(
      id: json['ID_PEMBELI'],
      nama: json['NAMA_PEMBELI'] ?? '',
      email: json['EMAIL_PEMBELI'] ?? '',
      nomorTelepon: json['NOMOR_TELEPON'] ?? '',
      poin: json['POIN_PEMBELI'] ?? 0,
    );
  }
}
