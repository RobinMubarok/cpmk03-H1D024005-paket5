import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../models/pasien.dart';
import '../services/pasien_service.dart';

/// Controller GetX untuk mengatur logika bisnis dan reaktifitas data Pasien
class PasienController extends GetxController {
  final PasienService _service;

  PasienController({PasienService? service})
      : _service = service ?? Get.find<PasienService>();

  /// State reaktif daftar seluruh pasien
  final RxList<Pasien> pasienList = <Pasien>[].obs;

  /// State reaktif daftar pasien terfilter (untuk pencarian)
  final RxList<Pasien> filteredList = <Pasien>[].obs;

  /// State reaktif kata kunci pencarian
  final RxString searchQuery = ''.obs;

  /// State loading untuk indikator pemuatan
  final RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadPasien();
  }

  /// Memuat semua data pasien dari Hive melalui PasienService
  void loadPasien() {
    isLoading.value = true;
    try {
      final list = _service.getAllPasien();
      pasienList.assignAll(list);
      _applySearch();
    } finally {
      isLoading.value = false;
    }
  }

  /// Fitur Khusus Paket 5: Pencarian berdasarkan nama atau nomor rekam medis
  void searchPasien(String query) {
    searchQuery.value = query;
    _applySearch();
  }

  void _applySearch() {
    final query = searchQuery.value.trim().toLowerCase();
    if (query.isEmpty) {
      filteredList.assignAll(pasienList);
    } else {
      final results = pasienList.where((p) {
        final matchesNama = p.nama.toLowerCase().contains(query);
        final matchesNoRm = p.noRekamMedis.toLowerCase().contains(query);
        return matchesNama || matchesNoRm;
      }).toList();
      filteredList.assignAll(results);
    }
  }

  /// Fitur Khusus Paket 5: Menghitung umur otomatis dari tanggal lahir
  int hitungUmur(DateTime tanggalLahir) {
    final now = DateTime.now();
    int age = now.year - tanggalLahir.year;
    if (now.month < tanggalLahir.month ||
        (now.month == tanggalLahir.month && now.day < tanggalLahir.day)) {
      age--;
    }
    return age < 0 ? 0 : age;
  }

  /// Memeriksa apakah nomor rekam medis sudah ada
  bool isNoRmExists(String noRekamMedis) {
    return _service.isNoRmExists(noRekamMedis);
  }

  /// Menambah data pasien baru dengan validasi keunikan nomor rekam medis
  Future<bool> tambahPasien(Pasien pasien) async {
    if (_service.isNoRmExists(pasien.noRekamMedis)) {
      Get.snackbar(
        'Gagal Menyimpan',
        'Nomor Rekam Medis ${pasien.noRekamMedis} sudah terdaftar!',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade700,
        colorText: Colors.white,
        icon: const Icon(Icons.error_outline, color: Colors.white),
        margin: const EdgeInsets.all(12),
        duration: const Duration(seconds: 3),
      );
      return false;
    }

    try {
      await _service.addPasien(pasien);
      loadPasien();
      Get.snackbar(
        'Berhasil',
        'Data pasien "${pasien.nama}" berhasil ditambahkan.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.teal.shade700,
        colorText: Colors.white,
        icon: const Icon(Icons.check_circle_outline, color: Colors.white),
        margin: const EdgeInsets.all(12),
        duration: const Duration(seconds: 3),
      );
      return true;
    } catch (e) {
      Get.snackbar(
        'Error',
        'Terjadi kesalahan saat menyimpan data: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade700,
        colorText: Colors.white,
        margin: const EdgeInsets.all(12),
      );
      return false;
    }
  }

  /// Mengubah data pasien yang ada
  Future<bool> ubahPasien(Pasien pasien) async {
    try {
      await _service.updatePasien(pasien);
      loadPasien();
      Get.snackbar(
        'Berhasil Diperbarui',
        'Data pasien "${pasien.nama}" berhasil diperbarui.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.teal.shade700,
        colorText: Colors.white,
        icon: const Icon(Icons.check_circle_outline, color: Colors.white),
        margin: const EdgeInsets.all(12),
        duration: const Duration(seconds: 3),
      );
      return true;
    } catch (e) {
      Get.snackbar(
        'Error',
        'Gagal memperbarui data: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade700,
        colorText: Colors.white,
        margin: const EdgeInsets.all(12),
      );
      return false;
    }
  }

  /// Menghapus data pasien berdasarkan noRekamMedis
  Future<void> hapusPasien(String noRekamMedis, {String? nama}) async {
    try {
      await _service.deletePasien(noRekamMedis);
      loadPasien();
      Get.snackbar(
        'Berhasil Dihapus',
        nama != null
            ? 'Data pasien "$nama" telah dihapus.'
            : 'Data pasien telah dihapus.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.blueGrey.shade800,
        colorText: Colors.white,
        icon: const Icon(Icons.delete_outline, color: Colors.white),
        margin: const EdgeInsets.all(12),
        duration: const Duration(seconds: 3),
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Gagal menghapus data: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade700,
        colorText: Colors.white,
        margin: const EdgeInsets.all(12),
      );
    }
  }

  /// Menampilkan dialog konfirmasi hapus data pasien dengan Get.dialog
  void konfirmasiHapus(Pasien pasien, {VoidCallback? onSuccess}) {
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: const [
            Icon(Icons.warning_amber_rounded, color: Colors.red, size: 28),
            SizedBox(width: 8),
            Text('Konfirmasi Hapus'),
          ],
        ),
        content: Text(
          'Apakah Anda yakin ingin menghapus data pasien:\n\n'
          'Nama: ${pasien.nama}\n'
          'No. RM: ${pasien.noRekamMedis}?',
          style: const TextStyle(fontSize: 15),
        ),
        actionsPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        actions: [
          OutlinedButton(
            onPressed: () => Get.back(),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade600,
              foregroundColor: Colors.white,
            ),
            onPressed: () async {
              Get.back(); // Tutup dialog
              await hapusPasien(pasien.noRekamMedis, nama: pasien.nama);
              if (onSuccess != null) {
                onSuccess();
              }
            },
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
  }
}
