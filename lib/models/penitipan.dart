class Penitipan {
  final int idPenitipan;
  final int idPenitip;
  final int? idPegawai;
  final int? idHunter;
  final String tanggalPenitipan;
  final String tanggalBerakhir;
  final String? statusPerpanjangan;
  final String? batasAmbil;
  final int? isAmbil;
  final String? statusAmbilKembali;

  Penitipan({
    required this.idPenitipan,
    required this.idPenitip,
    this.idPegawai,
    this.idHunter,
    required this.tanggalPenitipan,
    required this.tanggalBerakhir,
    this.statusPerpanjangan,
    this.batasAmbil,
    this.isAmbil,
    this.statusAmbilKembali,
  });

  factory Penitipan.fromJson(Map<String, dynamic> json) {
    return Penitipan(
      idPenitipan: json['ID_PENITIPAN'],
      idPenitip: json['ID_PENITIP'],
      idPegawai: json['ID_PEGAWAI'],
      idHunter: json['ID_HUNTER'],
      tanggalPenitipan: json['TANGGAL_PENITIPAN'],
      tanggalBerakhir: json['TANGGAL_BERAKHIR'],
      statusPerpanjangan: json['STATUS_PERPANJANGAN'],
      batasAmbil: json['BATAS_AMBIL'],
      isAmbil: json['IS_AMBIL'],
      statusAmbilKembali: json['STATUS_AMBIL_KEMBALI'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'ID_PENITIPAN': idPenitipan,
      'ID_PENITIP': idPenitip,
      'ID_PEGAWAI': idPegawai,
      'ID_HUNTER': idHunter,
      'TANGGAL_PENITIPAN': tanggalPenitipan,
      'TANGGAL_BERAKHIR': tanggalBerakhir,
      'STATUS_PERPANJANGAN': statusPerpanjangan,
      'BATAS_AMBIL': batasAmbil,
      'IS_AMBIL': isAmbil,
      'STATUS_AMBIL_KEMBALI': statusAmbilKembali,
    };
  }
}
