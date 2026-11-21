import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../controllers/pasien_controller.dart';
import '../models/pasien.dart';
import '../routes/app_routes.dart';

/// Halaman Detail Pasien (Fitur Khusus Paket 5)
/// Route: /detail
/// Menerima data melalui arguments (Get.arguments as Pasien)
class DetailPasienView extends StatelessWidget {
  const DetailPasienView({super.key});

  @override
  Widget build(BuildContext context) {
    // Ambil data pasien dari Get.arguments sesuai instruksi Paket 5
    final Pasien? initialPasien = Get.arguments as Pasien?;
    final PasienController controller = Get.find<PasienController>();
    final DateFormat dateFormatter = DateFormat('dd MMMM yyyy');

    if (initialPasien == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Detail Pasien')),
        body: const Center(child: Text('Data pasien tidak ditemukan.')),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text(
          'Detail Pasien',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.teal.shade700,
        foregroundColor: Colors.white,
        actions: [
          // Aksi Edit
          IconButton(
            tooltip: 'Ubah Data Pasien',
            icon: const Icon(Icons.edit_outlined),
            onPressed: () {
              // Ambil versi terbaru pasien dari controller
              final latest = controller.pasienList.firstWhereOrNull(
                    (p) => p.noRekamMedis == initialPasien.noRekamMedis,
                  ) ??
                  initialPasien;
              Get.toNamed(AppRoutes.form, arguments: latest);
            },
          ),
          // Aksi Hapus
          IconButton(
            tooltip: 'Hapus Pasien',
            icon: const Icon(Icons.delete_outline),
            onPressed: () {
              final latest = controller.pasienList.firstWhereOrNull(
                    (p) => p.noRekamMedis == initialPasien.noRekamMedis,
                  ) ??
                  initialPasien;
              controller.konfirmasiHapus(
                latest,
                onSuccess: () => Get.back(), // Kembali ke home setelah hapus
              );
            },
          ),
        ],
      ),
      body: Obx(() {
        // Ambil versi teranyar dari controller agar halaman reaktif jika baru diedit
        final pasien = controller.pasienList.firstWhereOrNull(
              (p) => p.noRekamMedis == initialPasien.noRekamMedis,
            ) ??
            initialPasien;

        final isLaki = pasien.jenisKelamin == 'L';

        return SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Profil Pasien
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 36,
                        backgroundColor: isLaki
                            ? Colors.blue.shade100
                            : Colors.pink.shade100,
                        child: Icon(
                          isLaki ? Icons.face : Icons.face_3,
                          color: isLaki
                              ? Colors.blue.shade800
                              : Colors.pink.shade800,
                          size: 42,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              pasien.nama,
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF0F172A),
                              ),
                            ),
                            const SizedBox(height: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.teal.shade50,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: Colors.teal.shade300),
                              ),
                              child: Text(
                                pasien.noRekamMedis,
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.teal.shade800,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 18),

              // Kartu Rincian Identitas & Medis
              Card(
                elevation: 1.5,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Informasi Demografis & Medis',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1E293B),
                        ),
                      ),
                      const Divider(height: 24),

                      // Fitur Khusus Paket 5: Umur dihitung otomatis dari tanggal lahir
                      _buildInfoRow(
                        icon: Icons.cake_outlined,
                        title: 'Umur Pasien (Otomatis)',
                        value: '${pasien.umur} Tahun',
                        highlight: true,
                      ),
                      const SizedBox(height: 14),

                      _buildInfoRow(
                        icon: Icons.calendar_today_outlined,
                        title: 'Tanggal Lahir',
                        value: dateFormatter.format(pasien.tanggalLahir),
                      ),
                      const SizedBox(height: 14),

                      _buildInfoRow(
                        icon: isLaki ? Icons.male : Icons.female,
                        title: 'Jenis Kelamin',
                        value: pasien.deskripsiJenisKelamin,
                      ),
                      const SizedBox(height: 14),

                      _buildInfoRow(
                        icon: Icons.bloodtype_outlined,
                        title: 'Golongan Darah',
                        value: pasien.golonganDarah,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 18),

              // Kartu Keluhan Medis
              Card(
                elevation: 1.5,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: const [
                          Icon(Icons.medical_services_outlined,
                              color: Colors.teal, size: 22),
                          SizedBox(width: 8),
                          Text(
                            'Keluhan Utama Pasien',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1E293B),
                            ),
                          ),
                        ],
                      ),
                      const Divider(height: 24),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF1F5F9),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          pasien.keluhan,
                          style: const TextStyle(
                            fontSize: 14.5,
                            height: 1.5,
                            color: Color(0xFF334155),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String title,
    required String value,
    bool highlight = false,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Icon(icon, size: 22, color: highlight ? Colors.teal : Colors.grey.shade600),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            title,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade700,
            ),
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 14.5,
            fontWeight: highlight ? FontWeight.bold : FontWeight.w600,
            color: highlight ? Colors.teal.shade800 : const Color(0xFF0F172A),
          ),
        ),
      ],
    );
  }
}
