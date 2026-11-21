import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:cpmk03_klinik_paket5/models/pasien.dart';
import 'package:cpmk03_klinik_paket5/models/pasien_adapter.dart';
import 'package:cpmk03_klinik_paket5/services/pasien_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late Directory tempDir;
  late PasienService pasienService;

  setUpAll(() {
    // Inisialisasi temporary directory untuk Hive testing
    tempDir = Directory.systemTemp.createTempSync('hive_testing_');
    Hive.init(tempDir.path);

    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(PasienAdapter());
    }
  });

  tearDownAll(() async {
    await Hive.close();
    if (tempDir.existsSync()) {
      tempDir.deleteSync(recursive: true);
    }
  });

  setUp(() async {
    pasienService = PasienService();
    // Buka box khusus testing agar terisolasi
    final testBox = await Hive.openBox<Pasien>('pasien_test_box_${DateTime.now().millisecondsSinceEpoch}');
    await pasienService.init(customBox: testBox);
  });

  tearDown(() async {
    await pasienService.box.deleteFromDisk();
  });

  group('Unit Test PasienService (CRUD Lokal Hive)', () {
    // 1. Test Create and Read Pasien
    test('1. Test Create & Read: Berhasil menambah dan mengambil data Pasien', () async {
      final samplePasien = Pasien(
        noRekamMedis: 'RM-0001',
        nama: 'Ahmad Fauzi',
        tanggalLahir: DateTime(1995, 5, 20),
        jenisKelamin: 'L',
        golonganDarah: 'O',
        keluhan: 'Demam tinggi dan batuk sejak 3 hari',
      );

      // Pastikan awalnya box kosong
      expect(pasienService.getAllPasien().isEmpty, isTrue);

      // Tambah pasien (Create)
      await pasienService.addPasien(samplePasien);

      // Ambil seluruh data (Read All)
      final allPasien = pasienService.getAllPasien();
      expect(allPasien.length, equals(1));
      expect(allPasien.first.noRekamMedis, equals('RM-0001'));
      expect(allPasien.first.nama, equals('Ahmad Fauzi'));

      // Ambil berdasarkan nomor rekam medis (Read Single)
      final retrieved = pasienService.getPasienByNoRm('RM-0001');
      expect(retrieved, isNotNull);
      expect(retrieved!.nama, equals('Ahmad Fauzi'));
      expect(retrieved.jenisKelamin, equals('L'));
      expect(retrieved.golonganDarah, equals('O'));
      expect(retrieved.keluhan, equals('Demam tinggi dan batuk sejak 3 hari'));
    });

    // 2. Test Update Pasien
    test('2. Test Update: Berhasil memperbarui data Pasien yang ada', () async {
      final initialPasien = Pasien(
        noRekamMedis: 'RM-0002',
        nama: 'Siti Rahma',
        tanggalLahir: DateTime(2000, 1, 15),
        jenisKelamin: 'P',
        golonganDarah: 'B',
        keluhan: 'Sakit kepala sebelah (migrain)',
      );

      await pasienService.addPasien(initialPasien);

      // Lakukan pembaruan data pasien (Update nama & keluhan)
      final updatedPasien = initialPasien.copyWith(
        nama: 'Siti Rahmawati',
        golonganDarah: 'AB',
        keluhan: 'Migrain berkurang, kontrol rutin',
      );

      await pasienService.updatePasien(updatedPasien);

      final retrieved = pasienService.getPasienByNoRm('RM-0002');
      expect(retrieved, isNotNull);
      expect(retrieved!.nama, equals('Siti Rahmawati'));
      expect(retrieved.golonganDarah, equals('AB'));
      expect(retrieved.keluhan, equals('Migrain berkurang, kontrol rutin'));
      // Pastikan total data tetap 1 (tidak duplikat)
      expect(pasienService.getAllPasien().length, equals(1));
    });

    // 3. Test Delete Pasien
    test('3. Test Delete: Berhasil menghapus data Pasien berdasarkan nomor rekam medis', () async {
      final pasien1 = Pasien(
        noRekamMedis: 'RM-0003',
        nama: 'Budi Santoso',
        tanggalLahir: DateTime(1988, 12, 10),
        jenisKelamin: 'L',
        golonganDarah: 'A',
        keluhan: 'Nyeri punggung',
      );
      final pasien2 = Pasien(
        noRekamMedis: 'RM-0004',
        nama: 'Dewi Lestari',
        tanggalLahir: DateTime(1992, 8, 25),
        jenisKelamin: 'P',
        golonganDarah: 'O',
        keluhan: 'Alergi makanan',
      );

      await pasienService.addPasien(pasien1);
      await pasienService.addPasien(pasien2);
      expect(pasienService.getAllPasien().length, equals(2));

      // Hapus pasien 1 (RM-0003)
      await pasienService.deletePasien('RM-0003');

      // Verifikasi RM-0003 sudah tidak ada
      expect(pasienService.getPasienByNoRm('RM-0003'), isNull);
      expect(pasienService.isNoRmExists('RM-0003'), isFalse);

      // Verifikasi pasien 2 (RM-0004) masih ada
      expect(pasienService.getAllPasien().length, equals(1));
      expect(pasienService.getPasienByNoRm('RM-0004')!.nama, equals('Dewi Lestari'));
    });

    // 4. Test Fitur Khusus: Perhitungan Umur Otomatis
    test('4. Test Model Fitur Khusus: Perhitungan umur otomatis dari tanggalLahir', () {
      final now = DateTime.now();
      // Pasien lahir tepat 25 tahun lalu
      final pasien25 = Pasien(
        noRekamMedis: 'RM-0010',
        nama: 'Rian Pratama',
        tanggalLahir: DateTime(now.year - 25, now.month, now.day),
        jenisKelamin: 'L',
        golonganDarah: 'A',
        keluhan: 'Flu',
      );
      expect(pasien25.umur, equals(25));

      // Pasien bayi lahir bulan ini
      final bayi = Pasien(
        noRekamMedis: 'RM-0011',
        nama: 'Bayi Sehat',
        tanggalLahir: DateTime(now.year, now.month, 1),
        jenisKelamin: 'P',
        golonganDarah: 'B',
        keluhan: 'Imunisasi',
      );
      expect(bayi.umur, equals(0));
    });
  });
}
