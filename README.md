# CPMK 03 - Aplikasi Data Pasien Klinik (Paket 5)

Aplikasi mobile berbasis Flutter untuk pengelolaan data pasien klinik pratama (**CRUD**) dengan basis data lokal **Hive** dan state management **GetX** yang mengimplementasikan arsitektur **MVC** (Model-View-Controller).

---

## 📋 Identitas Pengembang
* **Nama Lengkap:** [Nama Mahasiswa] *(Ganti sesuai data Anda)*
* **NIM:** [NIM Mahasiswa] *(NIM berakhiran 5)*
* **Nomor Paket:** **Paket 5**
* **Studi Kasus:** Klinik pratama ingin mendata pasien dan keluhannya.

---

## 🎬 Tautan Video Presentasi & Demo Workflow (YouTube)
* **Link Video YouTube:** [Tautan Video YouTube](https://youtu.be/your_video_link) *(Pastikan visibilitas video disetel ke Unlisted atau Public)*
* **Judul Video:** `CPMK 03 - Paket 5 - [Nama Mahasiswa] - [NIM]`
* **Durasi:** Minimal 5 Menit

---

## 📸 Antarmuka & Tangkapan Layar (Screenshots)

| Halaman Daftar Pasien (Home) | Form Tambah / Ubah Pasien | Halaman Detail Pasien | Dialog Konfirmasi Hapus |
| :---: | :---: | :---: | :---: |
| *(Tangkapan layar halaman utama)* | *(Tangkapan layar form validasi)* | *(Tangkapan layar detail & umur)* | *(Tangkapan layar Get.dialog)* |

---

## ✨ Fitur-Fitur Aplikasi

### 1. Spesifikasi Model Data Pasien
| Field | Tipe Data | Aturan & Validasi |
| :--- | :--- | :--- |
| `noRekamMedis` | `String` | Unik, Format `RM-0001` (Regex: `^RM-\d{4}$`) |
| `nama` | `String` | Wajib diisi (tidak boleh kosong atau spasi saja) |
| `tanggalLahir` | `DateTime` | `DatePicker`, batas maksimal hari ini (`lastDate: DateTime.now()`) |
| `jenisKelamin` | `String` | Radio: `'L'` (Laki-laki) / `'P'` (Perempuan) |
| `golonganDarah`| `String` | Dropdown: `'A'`, `'B'`, `'AB'`, `'O'` |
| `keluhan` | `String` | Wajib diisi (Deskripsi keluhan pasien) |

### 2. Fitur Khusus Paket 5
1. **Perhitungan Umur Otomatis:**
   * Umur pasien dihitung secara otomatis berdasarkan selisih tanggal lahir (`tanggalLahir`) dengan waktu saat ini (`DateTime.now()`).
   * Ditampilkan langsung pada kartu pasien di halaman daftar dan halaman detail.
2. **Halaman Detail Pasien (`/detail`):**
   * Navigasi menggunakan *named route* GetX: `Get.toNamed('/detail', arguments: pasien)`.
   * Menampilkan profil lengkap, status demografis, golongan darah, umur otomatis, serta keluhan pasien.
3. **Pencarian Real-Time Dinamis:**
   * Pasien dapat dicari berdasarkan **Nama** maupun **Nomor Rekam Medis** (`RM-XXXX`).
   * Tersedia fitur reset filter cepat.

### 3. Arsitektur & Teknologi
* **Penyimpanan Lokal (Hive):**
  * Menggunakan 1 Model `Pasien` + `PasienAdapter` (`typeId: 0`).
  * Urutan serialisasi field konsisten antara `read` dan `write` (index 0 sampai 5).
  * Data tetap tersimpan secara permanen (*persistent*) meskipun aplikasi ditutup.
* **State Management (GetX):**
  * State reaktif menggunakan `.obs` dan widget `Obx`.
  * Dependency Injection melalui `PasienBinding` (`Get.lazyPut`).
  * Named routing terpusat pada `AppRoutes` dan `AppPages`.
  * Dialog konfirmasi hapus menggunakan `Get.dialog`.
  * Notifikasi interaktif berhasil/gagal menggunakan `Get.snackbar`.
* **Arsitektur MVC:**
  * Pemisahan tegas antara `models/`, `services/`, `controllers/`, `views/`, `bindings/`, dan `routes/`.
  * **View tidak mengakses Hive secara langsung**, melainkan melalui perantara `PasienController` -> `PasienService`.

---

## 📂 Struktur Direktori Proyek

```text
lib/
├── bindings/
│   └── pasien_binding.dart       # Dependency Injection (Get.lazyPut Service & Controller)
├── controllers/
│   └── pasien_controller.dart    # State reaktif (.obs), logika CRUD, pencarian, & konfirmasi dialog
├── models/
│   ├── pasien.dart               # Entity model Pasien & getter perhitungan umur otomatis
│   └── pasien_adapter.dart       # Hive TypeAdapter manual (typeId: 0)
├── routes/
│   ├── app_pages.dart            # Konfigurasi GetPage untuk routing
│   └── app_routes.dart           # Konstanta named routes ('/', '/form', '/detail')
├── services/
│   └── pasien_service.dart       # Akses langsung ke Hive Box (Create, Read, Update, Delete)
├── views/
│   ├── home_view.dart            # Halaman daftar (Obx), pencarian, badge umur, & empty state
│   ├── form_pasien_view.dart     # Formulir tambah & edit pasien dengan validasi lengkap
│   └── detail_pasien_view.dart   # Halaman detail pasien menerima Get.arguments
└── main.dart                     # Inisialisasi Hive, adapter, service, & GetMaterialApp

test/
└── pasien_service_test.dart      # Unit test service CRUD lokal Hive (Create, Read, Update, Delete)
```

---

## 🚀 Cara Menjalankan Aplikasi

### 1. Prasyarat
* Flutter SDK (versi >= 3.13.0)
* Android Studio / VS Code dengan ekstensi Flutter & Dart
* Emulator Android atau perangkat fisik dengan USB Debugging aktif

### 2. Langkah Instalasi & Menjalankan

1. **Clone repository ini:**
   ```bash
   git clone <URL_REPOSITORY_ANDA>
   cd CPMK-03
   ```

2. **Unduh dependensi proyek:**
   ```bash
   flutter pub get
   ```

3. **Jalankan analisis kode (memastikan tidak ada error):**
   ```bash
   dart analyze
   ```

4. **Jalankan Unit Test:**
   ```bash
   flutter test
   ```
   *Seluruh pengujian unit test pada `test/pasien_service_test.dart` harus lulus (All tests passed).*

5. **Jalankan aplikasi di emulator atau device:**
   ```bash
   flutter run
   ```

---

## 🧪 Hasil Pengujian Unit Test

Pengujian dilakukan menggunakan `flutter test` mencakup operasi CRUD lokal pada Hive Box serta logika fitur khusus:
* ✅ **Test 1:** *Create & Read* - Berhasil menambah dan mengambil data Pasien.
* ✅ **Test 2:** *Update* - Berhasil memperbarui data Pasien yang ada.
* ✅ **Test 3:** *Delete* - Berhasil menghapus data Pasien berdasarkan nomor rekam medis.
* ✅ **Test 4:** *Model Fitur Khusus* - Perhitungan umur otomatis dari `tanggalLahir`.

---

## 📝 Panduan Alur Rekaman Video YouTube (Workflow)

Saat merekam video presentasi (durasi min. 5 menit), ikuti panduan urutan berikut:
1. **Pembuka:** Perkenalan diri (Nama, NIM, Nomor Paket 5, dan studi kasus Data Pasien Klinik).
2. **Struktur MVC:** Buka VS Code/IDE, tunjukkan struktur folder `lib/` (`models`, `services`, `controllers`, `views`, `bindings`, `routes`) dan jelaskan pemisahan tanggung jawabnya (khususnya penegasan bahwa View tidak menyentuh Hive).
3. **Model & Hive:** Tunjukkan file `pasien.dart` (termasuk getter `umur`), `pasien_adapter.dart` (typeId 0 dan urutan read/write), dan `pasien_service.dart`.
4. **Controller & GetX:** Tunjukkan variabel `.obs`, method CRUD, validasi keunikan `noRekamMedis`, method `konfirmasiHapus`, serta `PasienBinding` dan `AppPages`.
5. **View:** Tunjukkan `HomeView` dengan widget `Obx` dan `FormPasienView` dengan validasi form.
6. **Demo CRUD & Validasi:**
   * Coba simpan form kosong -> perlihatkan validasi gagal.
   * Coba masukkan format RM salah (misal: `123`) -> perlihatkan pesan format harus `RM-0001`.
   * Simpan pasien baru yang valid -> perlihatkan snackbar berhasil dan data muncul di daftar.
   * Lakukan pencarian nama atau nomor rekam medis pada search bar.
   * Edit data pasien tersebut.
   * Hapus salah satu pasien -> perlihatkan dialog konfirmasi `Get.dialog`.
7. **Demo Fitur Khusus Paket 5:**
   * Tunjukkan perhitungan umur otomatis pada kartu pasien.
   * Klik kartu pasien untuk navigasi ke `/detail` via `Get.arguments`.
8. **Bukti Persistensi Data & Test:**
   * Tutup aplikasi sepenuhnya (kill process dari recent apps), lalu buka kembali -> data tetap ada.
   * Buka terminal dan jalankan `flutter test` untuk membuktikan seluruh unit test lulus 100%.

---

## 🔒 Ketentuan Pengumpulan GitHub
* Repository: **Private**
* Format penamaan repo: `cpmk03-<NIM>-paket5` (contoh: `cpmk03-2201010127-paket5`)
* Dosen Collaborator: `mohammadlrham37`
