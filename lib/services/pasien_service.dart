import 'package:hive/hive.dart';
import '../models/pasien.dart';

/// Service untuk menangani persistensi data Pasien ke basis data lokal Hive.
/// Sesuai aturan arsitektur MVC: Lapisan View tidak boleh memanggil Hive langsung,
/// melainkan melalui Controller -> Service.
class PasienService {
  static const String boxName = 'pasienBox';
  Box<Pasien>? _box;

  Box<Pasien> get box {
    if (_box == null || !_box!.isOpen) {
      throw StateError('Box $boxName belum diinisialisasi atau tertutup.');
    }
    return _box!;
  }

  /// Inisialisasi service dan membuka Hive Box
  Future<void> init({Box<Pasien>? customBox}) async {
    if (customBox != null) {
      _box = customBox;
    } else {
      _box = await Hive.openBox<Pasien>(boxName);
    }
  }

  /// Mengambil semua data pasien dari Hive
  List<Pasien> getAllPasien() {
    return box.values.toList();
  }

  /// Mengambil data satu pasien berdasarkan nomor rekam medis
  Pasien? getPasienByNoRm(String noRekamMedis) {
    return box.get(noRekamMedis);
  }

  /// Memeriksa apakah nomor rekam medis sudah terdaftar (untuk validasi keunikan)
  bool isNoRmExists(String noRekamMedis) {
    return box.containsKey(noRekamMedis);
  }

  /// Menambah data pasien baru ke dalam Hive Box
  /// Menggunakan nomor rekam medis sebagai key unik di Box
  Future<void> addPasien(Pasien pasien) async {
    await box.put(pasien.noRekamMedis, pasien);
  }

  /// Memperbarui data pasien yang sudah ada
  Future<void> updatePasien(Pasien pasien) async {
    await box.put(pasien.noRekamMedis, pasien);
  }

  /// Menghapus data pasien berdasarkan nomor rekam medis
  Future<void> deletePasien(String noRekamMedis) async {
    await box.delete(noRekamMedis);
  }

  /// Mengosongkan seluruh data pada Box (berguna untuk testing atau reset)
  Future<void> clearAll() async {
    await box.clear();
  }
}
