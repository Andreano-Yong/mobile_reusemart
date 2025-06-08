class Alamat {
  final int id;
  final int idPembeli;
  final String label;
  final String namaJalan;
  final String kecamatan;
  final String kelurahan;
  final String kota;
  final String kodePos;
  final bool isDefault;

  Alamat({
    required this.id,
    required this.idPembeli,
    required this.label,
    required this.namaJalan,
    required this.kecamatan,
    required this.kelurahan,
    required this.kota,
    required this.kodePos,
    required this.isDefault,
  });

  factory Alamat.fromJson(Map<String, dynamic> json) {
    return Alamat(
      id: json['ID_ALAMAT'],
      idPembeli: json['ID_PEMBELI'],
      label: json['LABEL_ALAMAT'] ?? '',
      namaJalan: json['NAMA_JALAN'] ?? '',
      kecamatan: json['KECAMATAN'] ?? '',
      kelurahan: json['KELURAHAN'] ?? '',
      kota: json['KOTA'] ?? '',
      kodePos: json['KODE_POS'] ?? '',
      isDefault: json['IS_DEFAULT'] == 1, // dari int ke bool
    );
  }
}
