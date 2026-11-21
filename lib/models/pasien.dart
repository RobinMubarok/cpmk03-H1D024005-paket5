class Pasien {
  final String noRekamMedis;
  final String nama;
  final DateTime tanggalLahir;
  final String jenisKelamin; // 'L' atau 'P'
  final String golonganDarah; // 'A', 'B', 'AB', 'O'
  final String keluhan;

  Pasien({
    required this.noRekamMedis,
    required this.nama,
    required this.tanggalLahir,
    required this.jenisKelamin,
    required this.golonganDarah,
    required this.keluhan,
  });

  /// Fitur Khusus Paket 5: Umur dihitung otomatis dari tanggal lahir
  int get umur {
    final now = DateTime.now();
    int age = now.year - tanggalLahir.year;
    if (now.month < tanggalLahir.month ||
        (now.month == tanggalLahir.month && now.day < tanggalLahir.day)) {
      age--;
    }
    return age < 0 ? 0 : age;
  }

  /// Keterangan label jenis kelamin
  String get deskripsiJenisKelamin =>
      jenisKelamin == 'L' ? 'Laki-laki' : 'Perempuan';

  Pasien copyWith({
    String? noRekamMedis,
    String? nama,
    DateTime? tanggalLahir,
    String? jenisKelamin,
    String? golonganDarah,
    String? keluhan,
  }) {
    return Pasien(
      noRekamMedis: noRekamMedis ?? this.noRekamMedis,
      nama: nama ?? this.nama,
      tanggalLahir: tanggalLahir ?? this.tanggalLahir,
      jenisKelamin: jenisKelamin ?? this.jenisKelamin,
      golonganDarah: golonganDarah ?? this.golonganDarah,
      keluhan: keluhan ?? this.keluhan,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'noRekamMedis': noRekamMedis,
      'nama': nama,
      'tanggalLahir': tanggalLahir.toIso8601String(),
      'jenisKelamin': jenisKelamin,
      'golonganDarah': golonganDarah,
      'keluhan': keluhan,
    };
  }

  factory Pasien.fromMap(Map<String, dynamic> map) {
    return Pasien(
      noRekamMedis: map['noRekamMedis'] as String,
      nama: map['nama'] as String,
      tanggalLahir: DateTime.parse(map['tanggalLahir'] as String),
      jenisKelamin: map['jenisKelamin'] as String,
      golonganDarah: map['golonganDarah'] as String,
      keluhan: map['keluhan'] as String,
    );
  }
}
