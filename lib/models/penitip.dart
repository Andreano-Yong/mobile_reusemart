class Penitip {
  final int idPenitip;
  final String nama;
  final String email;
  final String alamat;
  final String notelp;
  final String nik;
  final String scanKtp;
  final int saldo;
  final int poin;

  Penitip({
    required this.idPenitip,
    required this.nama,
    required this.email,
    required this.alamat,
    required this.notelp,
    required this.nik,
    required this.scanKtp,
    required this.saldo,
    required this.poin,
  });

  factory Penitip.fromJson(Map<String, dynamic> json) {
    return Penitip(
      idPenitip: json['ID_PENITIP'],
      nama: json['NAMA_PENITIP'],
      email: json['EMAIL_PENITIP'],
      alamat: json['ALAMAT_PENITIP'],
      notelp: json['NOTELP_PENITIP'],
      nik: json['NIK'],
      scanKtp: json['SCAN_KTP'],
      saldo: json['SALDO_PENITIP'],
      poin: json['POIN_PENITIP'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'ID_PENITIP': idPenitip,
      'NAMA_PENITIP': nama,
      'EMAIL_PENITIP': email,
      'ALAMAT_PENITIP': alamat,
      'NOTELP_PENITIP': notelp,
      'NIK': nik,
      'SCAN_KTP': scanKtp,
      'SALDO_PENITIP': saldo,
      'POIN_PENITIP': poin,
    };
  }
}
