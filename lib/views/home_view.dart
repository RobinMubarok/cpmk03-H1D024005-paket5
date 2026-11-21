import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/pasien_controller.dart';
import '../models/pasien.dart';
import '../routes/app_routes.dart';

/// Halaman utama (HomeView) menampilkan daftar data pasien klinik.
/// Memenuhi aturan MVC: View hanya berinteraksi dengan PasienController dan Obx.
class HomeView extends GetView<PasienController> {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F8FA),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.teal.shade700,
        foregroundColor: Colors.white,
        title: Row(
          children: const [
            Icon(Icons.local_hospital_rounded, size: 26),
            SizedBox(width: 10),
            Text(
              'Data Pasien Klinik',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          // Header Search Bar
          Container(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
            color: Colors.white,
            child: TextField(
              onChanged: controller.searchPasien,
              decoration: InputDecoration(
                hintText: 'Cari nama atau No. Rekam Medis (RM-...)',
                hintStyle: TextStyle(color: Colors.grey.shade500, fontSize: 14),
                prefixIcon: const Icon(Icons.search, color: Colors.teal),
                suffixIcon: Obx(() {
                  if (controller.searchQuery.value.isNotEmpty) {
                    return IconButton(
                      icon: const Icon(Icons.clear, color: Colors.grey),
                      onPressed: () {
                        controller.searchPasien('');
                      },
                    );
                  }
                  return const SizedBox.shrink();
                }),
                filled: true,
                fillColor: const Color(0xFFF1F5F9),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),

          // Total Pasien Summary Bar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            color: Colors.white,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Obx(() => Text(
                      'Menampilkan ${controller.filteredList.length} dari ${controller.pasienList.length} pasien',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: Colors.grey.shade700,
                      ),
                    )),
                Obx(() {
                  if (controller.searchQuery.value.isNotEmpty) {
                    return TextButton(
                      style: TextButton.styleFrom(
                        visualDensity: VisualDensity.compact,
                        padding: EdgeInsets.zero,
                      ),
                      onPressed: () => controller.searchPasien(''),
                      child: const Text('Reset Filter',
                          style: TextStyle(fontSize: 12)),
                    );
                  }
                  return const SizedBox.shrink();
                }),
              ],
            ),
          ),
          const Divider(height: 1, thickness: 1),

          // Daftar Pasien (Reactive dengan Obx)
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) {
                return const Center(child: CircularProgressIndicator());
              }

              // Kondisi 1: Database kosong belum ada pasien sama sekali
              if (controller.pasienList.isEmpty) {
                return _buildEmptyInitialState();
              }

              // Kondisi 2: Hasil pencarian tidak ditemukan
              if (controller.filteredList.isEmpty) {
                return _buildEmptySearchResult();
              }

              return RefreshIndicator(
                onRefresh: () async {
                  controller.loadPasien();
                },
                child: ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: controller.filteredList.length,
                  separatorBuilder: (context, index) =>
                      const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final pasien = controller.filteredList[index];
                    return _buildPasienCard(context, pasien);
                  },
                ),
              );
            }),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: Colors.teal.shade700,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.person_add_rounded),
        label: const Text(
          'Tambah Pasien',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        onPressed: () {
          Get.toNamed(AppRoutes.form);
        },
      ),
    );
  }

  /// Kartu Pasien dengan info umur otomatis & navigasi ke /detail
  Widget _buildPasienCard(BuildContext context, Pasien pasien) {
    final isLaki = pasien.jenisKelamin == 'L';

    return Card(
      elevation: 1.5,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        // Fitur khusus paket 5: Halaman detail pasien (route /detail, data dikirim lewat arguments)
        onTap: () {
          Get.toNamed(AppRoutes.detail, arguments: pasien);
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Avatar Pasien sesuai Jenis Kelamin
                  CircleAvatar(
                    radius: 26,
                    backgroundColor: isLaki
                        ? Colors.blue.shade100
                        : Colors.pink.shade100,
                    child: Icon(
                      isLaki ? Icons.face : Icons.face_3,
                      color: isLaki ? Colors.blue.shade800 : Colors.pink.shade800,
                      size: 30,
                    ),
                  ),
                  const SizedBox(width: 14),

                  // Info Utama Pasien
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          pasien.nama,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1E293B),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            // Badge Nomor Rekam Medis
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.teal.shade50,
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(
                                  color: Colors.teal.shade300,
                                ),
                              ),
                              child: Text(
                                pasien.noRekamMedis,
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.teal.shade800,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),

                            // Fitur Khusus Paket 5: Umur dihitung otomatis dari tanggal lahir
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.amber.shade50,
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(
                                  color: Colors.amber.shade400,
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.cake_outlined,
                                      size: 13, color: Colors.amber.shade900),
                                  const SizedBox(width: 4),
                                  Text(
                                    '${pasien.umur} tahun',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.amber.shade900,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // Menu Aksi Cepat (Edit & Delete)
                  PopupMenuButton<String>(
                    icon: const Icon(Icons.more_vert, color: Colors.grey),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    onSelected: (value) {
                      if (value == 'edit') {
                        Get.toNamed(AppRoutes.form, arguments: pasien);
                      } else if (value == 'delete') {
                        controller.konfirmasiHapus(pasien);
                      }
                    },
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: 'edit',
                        child: Row(
                          children: [
                            Icon(Icons.edit_outlined,
                                size: 20, color: Colors.blue),
                            SizedBox(width: 8),
                            Text('Ubah Data'),
                          ],
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'delete',
                        child: Row(
                          children: [
                            Icon(Icons.delete_outline,
                                size: 20, color: Colors.red),
                            SizedBox(width: 8),
                            Text('Hapus Pasien',
                                style: TextStyle(color: Colors.red)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Baris Info Jenis Kelamin, Gol Darah, dan Keluhan
              Row(
                children: [
                  _buildTag(
                    icon: isLaki ? Icons.male : Icons.female,
                    label: pasien.deskripsiJenisKelamin,
                    color: isLaki ? Colors.blue.shade700 : Colors.pink.shade700,
                    bgColor:
                        isLaki ? Colors.blue.shade50 : Colors.pink.shade50,
                  ),
                  const SizedBox(width: 8),
                  _buildTag(
                    icon: Icons.bloodtype_outlined,
                    label: 'Gol. Darah: ${pasien.golonganDarah}',
                    color: Colors.red.shade700,
                    bgColor: Colors.red.shade50,
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // Keluhan Singkat
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.medical_services_outlined,
                        size: 15, color: Colors.grey.shade600),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        pasien.keluhan,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey.shade800,
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
    );
  }

  Widget _buildTag({
    required IconData icon,
    required String label,
    required Color color,
    required Color bgColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 11.5,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  /// Empty State saat belum ada data pasien sama sekali
  Widget _buildEmptyInitialState() {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.teal.shade50,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.people_alt_outlined,
                size: 72,
                color: Colors.teal.shade600,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Belum Ada Data Pasien',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1E293B),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Penyimpanan lokal Hive masih kosong.\nKlik tombol di bawah untuk mendaftarkan pasien pertama.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.teal.shade700,
                foregroundColor: Colors.white,
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onPressed: () {
                Get.toNamed(AppRoutes.form);
              },
              icon: const Icon(Icons.add),
              label: const Text('Daftarkan Pasien Sekarang'),
            ),
          ],
        ),
      ),
    );
  }

  /// Empty State saat pencarian tidak menemukan hasil
  Widget _buildEmptySearchResult() {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_off_rounded, size: 68, color: Colors.grey.shade400),
            const SizedBox(height: 16),
            const Text(
              'Pasien Tidak Ditemukan',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1E293B),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Tidak ada data yang cocok dengan kata kunci "${controller.searchQuery.value}".',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
            ),
            const SizedBox(height: 16),
            OutlinedButton.icon(
              onPressed: () => controller.searchPasien(''),
              icon: const Icon(Icons.refresh),
              label: const Text('Bersihkan Pencarian'),
            ),
          ],
        ),
      ),
    );
  }
}
