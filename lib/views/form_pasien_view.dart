import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../controllers/pasien_controller.dart';
import '../models/pasien.dart';

/// FormPasienView menangani operasi Tambah dan Ubah Data Pasien.
/// Memvalidasi seluruh aturan tabel field:
/// - noRekamMedis: Unik, format RM-0001
/// - nama: Wajib diisi
/// - tanggalLahir: DatePicker, tidak boleh di masa depan
/// - jenisKelamin: Radio L / P
/// - golonganDarah: Dropdown A / B / AB / O
/// - keluhan: Wajib diisi
class FormPasienView extends StatefulWidget {
  const FormPasienView({super.key});

  @override
  State<FormPasienView> createState() => _FormPasienViewState();
}

class _FormPasienViewState extends State<FormPasienView> {
  final _formKey = GlobalKey<FormState>();
  final PasienController _controller = Get.find<PasienController>();

  late final TextEditingController _noRmController;
  late final TextEditingController _namaController;
  late final TextEditingController _keluhanController;

  DateTime? _selectedTanggalLahir;
  String _selectedJenisKelamin = 'L'; // Default L
  String _selectedGolonganDarah = 'A'; // Default A

  bool _isEdit = false;
  Pasien? _existingPasien;

  final DateFormat _dateFormatter = DateFormat('dd MMMM yyyy');

  @override
  void initState() {
    super.initState();
    _existingPasien = Get.arguments as Pasien?;
    _isEdit = _existingPasien != null;

    _noRmController = TextEditingController(
      text: _existingPasien?.noRekamMedis ?? '',
    );
    _namaController = TextEditingController(
      text: _existingPasien?.nama ?? '',
    );
    _keluhanController = TextEditingController(
      text: _existingPasien?.keluhan ?? '',
    );

    if (_isEdit) {
      _selectedTanggalLahir = _existingPasien!.tanggalLahir;
      _selectedJenisKelamin = _existingPasien!.jenisKelamin;
      _selectedGolonganDarah = _existingPasien!.golonganDarah;
    }
  }

  @override
  void dispose() {
    _noRmController.dispose;
    _namaController.dispose();
    _keluhanController.dispose();
    super.dispose();
  }

  /// Membuka DatePicker dengan batasan tanggal tidak boleh di masa depan
  Future<void> _pickDate() async {
    final now = DateTime.now();
    final initialDate = _selectedTanggalLahir ??
        DateTime(now.year - 20, now.month, now.day);

    final picked = await showDatePicker(
      context: context,
      initialDate: initialDate.isAfter(now) ? now : initialDate,
      firstDate: DateTime(1900),
      lastDate: now, // Aturan: tidak boleh di masa depan
      helpText: 'Pilih Tanggal Lahir Pasien',
      cancelText: 'Batal',
      confirmText: 'Pilih',
    );

    if (picked != null) {
      setState(() {
        _selectedTanggalLahir = picked;
      });
    }
  }

  /// Menyimpan data pasien baru atau menyimpan perubahan data pasien
  Future<void> _saveForm() async {
    // 1. Validasi tanggal lahir
    if (_selectedTanggalLahir == null) {
      Get.snackbar(
        'Validasi Gagal',
        'Tanggal lahir wajib dipilih!',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade700,
        colorText: Colors.white,
      );
      return;
    }

    // 2. Validasi form fields
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final noRm = _noRmController.text.trim();
    final nama = _namaController.text.trim();
    final keluhan = _keluhanController.text.trim();

    final pasien = Pasien(
      noRekamMedis: noRm,
      nama: nama,
      tanggalLahir: _selectedTanggalLahir!,
      jenisKelamin: _selectedJenisKelamin,
      golonganDarah: _selectedGolonganDarah,
      keluhan: keluhan,
    );

    bool success;
    if (_isEdit) {
      success = await _controller.ubahPasien(pasien);
    } else {
      success = await _controller.tambahPasien(pasien);
    }

    if (success) {
      Get.back();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: Text(
          _isEdit ? 'Ubah Data Pasien' : 'Tambah Pasien Baru',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.teal.shade700,
        foregroundColor: Colors.white,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Info Box Aturan Form
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.teal.shade50,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.teal.shade200),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.info_outline, color: Colors.teal.shade800),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          _isEdit
                              ? 'Perbarui formulir di bawah ini. No. Rekam Medis bersifat tetap sebagai identitas unik.'
                              : 'Lengkapi seluruh data pasien klinik. Semua kolom bertanda (*) wajib diisi.',
                          style: TextStyle(
                            fontSize: 12.5,
                            color: Colors.teal.shade900,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // 1. Nomor Rekam Medis (Unik, format RM-0001)
                _buildLabel('Nomor Rekam Medis *',
                    sublabel: 'Format RM-0001 (contoh: RM-0001, RM-0123)'),
                TextFormField(
                  controller: _noRmController,
                  enabled: !_isEdit, // Kunci No. RM saat edit
                  textCapitalization: TextCapitalization.characters,
                  decoration: InputDecoration(
                    hintText: 'RM-0001',
                    prefixIcon:
                        const Icon(Icons.badge_outlined, color: Colors.teal),
                    filled: true,
                    fillColor: _isEdit ? Colors.grey.shade200 : Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Nomor Rekam Medis wajib diisi';
                    }
                    final regex = RegExp(r'^RM-\d{4}$');
                    if (!regex.hasMatch(value.trim())) {
                      return 'Format harus RM-0001 (diawali RM- dan 4 digit angka)';
                    }
                    if (!_isEdit && _controller.isNoRmExists(value.trim())) {
                      return 'Nomor Rekam Medis sudah terdaftar!';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // 2. Nama (Wajib diisi)
                _buildLabel('Nama Pasien *'),
                TextFormField(
                  controller: _namaController,
                  textCapitalization: TextCapitalization.words,
                  decoration: InputDecoration(
                    hintText: 'Masukkan nama lengkap pasien',
                    prefixIcon:
                        const Icon(Icons.person_outline, color: Colors.teal),
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Nama pasien wajib diisi';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // 3. Tanggal Lahir (DatePicker, tidak boleh di masa depan)
                _buildLabel('Tanggal Lahir *',
                    sublabel: 'Tidak boleh di masa depan'),
                InkWell(
                  onTap: _pickDate,
                  borderRadius: BorderRadius.circular(10),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 14),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.grey.shade400),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.calendar_today_outlined,
                            color: Colors.teal),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            _selectedTanggalLahir == null
                                ? 'Pilih Tanggal Lahir'
                                : _dateFormatter.format(_selectedTanggalLahir!),
                            style: TextStyle(
                              fontSize: 15,
                              color: _selectedTanggalLahir == null
                                  ? Colors.grey.shade600
                                  : Colors.black87,
                            ),
                          ),
                        ),
                        if (_selectedTanggalLahir != null)
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.amber.shade100,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              'Umur: ${_controller.hitungUmur(_selectedTanggalLahir!)} th',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: Colors.amber.shade900,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // 4. Jenis Kelamin (Radio: L / P)
                _buildLabel('Jenis Kelamin *'),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: RadioGroup<String>(
                    groupValue: _selectedJenisKelamin,
                    onChanged: (val) {
                      if (val != null) {
                        setState(() => _selectedJenisKelamin = val);
                      }
                    },
                    child: const Row(
                      children: [
                        Expanded(
                          child: RadioListTile<String>(
                            title: Text('Laki-laki (L)'),
                            value: 'L',
                          ),
                        ),
                        Expanded(
                          child: RadioListTile<String>(
                            title: Text('Perempuan (P)'),
                            value: 'P',
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // 5. Golongan Darah (Dropdown: A / B / AB / O)
                _buildLabel('Golongan Darah *'),
                DropdownButtonFormField<String>(
                  initialValue: _selectedGolonganDarah,
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.bloodtype_outlined,
                        color: Colors.teal),
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  items: const [
                    DropdownMenuItem(value: 'A', child: Text('A')),
                    DropdownMenuItem(value: 'B', child: Text('B')),
                    DropdownMenuItem(value: 'AB', child: Text('AB')),
                    DropdownMenuItem(value: 'O', child: Text('O')),
                  ],
                  onChanged: (val) {
                    if (val != null) {
                      setState(() => _selectedGolonganDarah = val);
                    }
                  },
                ),
                const SizedBox(height: 16),

                // 6. Keluhan (Wajib diisi)
                _buildLabel('Keluhan Pasien *'),
                TextFormField(
                  controller: _keluhanController,
                  maxLines: 4,
                  decoration: InputDecoration(
                    hintText: 'Tuliskan keluhan atau gejala sakit pasien...',
                    prefixIcon: const Padding(
                      padding: EdgeInsets.only(bottom: 50),
                      child: Icon(Icons.note_alt_outlined, color: Colors.teal),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Keluhan pasien wajib diisi';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 28),

                // Tombol Simpan
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.teal.shade700,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 2,
                    ),
                    onPressed: _saveForm,
                    icon: const Icon(Icons.save),
                    label: Text(
                      _isEdit ? 'Perbarui Data Pasien' : 'Simpan Data Pasien',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text, {String? sublabel}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            text,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1E293B),
            ),
          ),
          if (sublabel != null)
            Text(
              sublabel,
              style: TextStyle(
                fontSize: 11.5,
                color: Colors.grey.shade600,
              ),
            ),
        ],
      ),
    );
  }
}
