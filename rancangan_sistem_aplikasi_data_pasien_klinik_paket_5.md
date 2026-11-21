# Rancangan Sistem: Aplikasi Data Pasien Klinik (Paket 5)

Dokumen ini berisi perancangan arsitektur, basis data lokal (Hive), dan pemodelan UML untuk aplikasi mobile Flutter CRUD **Data Pasien Klinik** dengan arsitektur **MVC + GetX**.

---

## 1. Entity Relationship Diagram (ERD) / Skema Penyimpanan Lokal (Hive)

Karena aplikasi menggunakan **Hive** (NoSQL berbasis key-value / Box) dengan 1 model utama (`Pasien`), berikut adalah representasi struktur entitas/objek penyimpanannya:

```mermaid
erDiagram
    PASIEN_BOX {
        String noRekamMedis PK "Unik, Format: RM-0001"
        String nama "Wajib diisi"
        DateTime tanggalLahir "Tidak boleh di masa depan"
        String jenisKelamin "Radio: L / P"
        String golonganDarah "Dropdown: A / B / AB / O"
        String keluhan "Wajib diisi"
    }
```

### Detail Skema Model & Hive TypeAdapter:
* **Nama Box:** `pasienBox`
* **TypeId:** `0` (Unik)
* **Urutan Field pada `TypeAdapter` (Wajib konsisten antara `read` dan `write`):**
  * `0`: `noRekamMedis` (`String`) — *Dijadikan Key pada Box untuk memastikan keunikan*
  * `1`: `nama` (`String`)
  * `2`: `tanggalLahir` (`DateTime`)
  * `3`: `jenisKelamin` (`String`)
  * `4`: `golonganDarah` (`String`)
  * `5`: `keluhan` (`String`)

---

## 2. UML: Use Case Diagram

Diagram ini menggambarkan interaksi antara **Petugas Klinik (User)** dengan fitur-fitur utama yang wajib ada pada Paket 5.

```mermaid
flowchart LR
    User(["👤 Petugas Klinik"])

    subgraph Sistem ["Aplikasi Data Pasien Klinik"]
        UC1(["Melihat Daftar Pasien & Umur"])
        UC2(["Mencari Pasien (Nama / No. RM)"])
        UC3(["Melihat Detail Pasien (/detail)"])
        UC4(["Menambah Data Pasien"])
        UC5(["Mengubah Data Pasien"])
        UC6(["Menghapus Data Pasien"])
    end

    User --> UC1
    User --> UC2
    User --> UC3
    User --> UC4
    User --> UC5
    User --> UC6

    UC4 -.->|include| Validasi(["Validasi Form & Cek Duplikat RM"])
    UC5 -.->|include| Validasi
    UC6 -.->|include| Konfirmasi(["Dialog Konfirmasi (Get.dialog)"])
```

---

## 3. UML: Class Diagram (Arsitektur MVC + GetX)

Diagram ini memetakan relasi antar lapisan (`models`, `services`, `controllers`, `bindings`, `views`, dan `routes`) sesuai aturan bahwa **View tidak boleh mengakses Hive secara langsung**.

```mermaid
classDiagram
    class Pasien {
        +String noRekamMedis
        +String nama
        +DateTime tanggalLahir
        +String jenisKelamin
        +String golonganDarah
        +String keluhan
        +int umur
    }

    class PasienAdapter {
        +int typeId = 0
        +Pasien read(BinaryReader reader)
        +void write(BinaryWriter writer, Pasien obj)
    }

    class PasienService {
        -Box~Pasien~ _box
        +Future~void~ init()
        +List~Pasien~ getAllPasien()
        +Future~void~ addPasien(Pasien pasien)
        +Future~void~ updatePasien(Pasien pasien)
        +Future~void~ deletePasien(String noRekamMedis)
        +bool isNoRmExists(String noRm)
    }

    class PasienController {
        -PasienService _service
        +RxList~Pasien~ pasienList
        +RxList~Pasien~ filteredList
        +RxString searchQuery
        +void onInit()
        +void loadPasien()
        +void searchPasien(String query)
        +int hitungUmur(DateTime tanggalLahir)
        +Future~bool~ tambahPasien(Pasien pasien)
        +Future~bool~ ubahPasien(Pasien pasien)
        +Future~void~ hapusPasien(String noRekamMedis)
    }

    class PasienBinding {
        +void dependencies()
    }

    class HomeView {
        +Widget build(BuildContext context)
    }

    class FormPasienView {
        +Widget build(BuildContext context)
    }

    class DetailPasienView {
        +Widget build(BuildContext context)
    }

    PasienAdapter ..> Pasien : serializes
    PasienService --> Pasien : manages in Hive
    PasienController --> PasienService : calls
    PasienController --> Pasien : observes (.obs)
    PasienBinding ..> PasienController : injects
    PasienBinding ..> PasienService : injects
    HomeView --> PasienController : Obx()
    FormPasienView --> PasienController : submits to
    DetailPasienView ..> Pasien : receives via Get.arguments
```

---

## 4. UML: Sequence Diagram (Alur Tambah Data & Detail)

### A. Alur Tambah Pasien (Create + Validasi)
```mermaid
sequenceDiagram
    actor User as Petugas Klinik
    participant View as FormPasienView
    participant Ctrl as PasienController
    participant Svc as PasienService
    participant Hive as Hive Box

    User->>View: Isi form & tekan "Simpan"
    View->>View: Validasi format RM-0001, wajib diisi, tgl <= hari ini
    alt Form Valid
        View->>Ctrl: tambahPasien(pasienBaru)
        Ctrl->>Svc: isNoRmExists(noRekamMedis)
        Svc-->>Ctrl: false (Unik)
        Ctrl->>Svc: addPasien(pasienBaru)
        Svc->>Hive: put(noRekamMedis, pasienBaru)
        Hive-->>Svc: Sukses
        Ctrl->>Ctrl: loadPasien() (Update .obs)
        Ctrl-->>View: true
        View->>User: Get.back() & Get.snackbar("Berhasil")
    else Form Tidak Valid / RM Duplikat
        View->>User: Tampilkan pesan error validasi / Get.snackbar("Error")
    end
```

### B. Alur Navigasi ke Halaman Detail (`/detail`)
```mermaid
sequenceDiagram
    actor User as Petugas Klinik
    participant Home as HomeView
    participant Route as GetX Router
    participant Detail as DetailPasienView

    User->>Home: Tap item kartu pasien
    Home->>Route: Get.toNamed('/detail', arguments: pasien)
    Route->>Detail: Render halaman
    Detail->>Detail: Ambil data via Get.arguments as Pasien
    Detail-->>User: Tampilkan info lengkap + umur otomatis
```

---

## 5. Struktur Folder Proyek (MVC)

Susunan direktori di dalam folder `lib/` dan `test/` agar memenuhi kriteria penilaian:

```text
lib/
├── main.dart                     # Inisialisasi Hive, Register Adapter, GetMaterialApp
├── models/
│   ├── pasien.dart               # Class model Pasien + getter hitung umur
│   └── pasien_adapter.dart       # Manual / Generated Hive TypeAdapter (typeId: 0)
├── services/
│   └── pasien_service.dart       # Logika CRUD langsung ke Hive Box
├── controllers/
│   └── pasien_controller.dart    # State management (.obs), pencarian, & validasi bisnis
├── bindings/
│   └── pasien_binding.dart       # Dependency Injection (Get.lazyPut)
├── routes/
│   ├── app_pages.dart            # Daftar GetPage (/, /form, /detail)
│   └── app_routes.dart           # Konstanta nama route
└── views/
    ├── home_view.dart            # Daftar pasien (Obx), search bar, empty state, & hapus
    ├── form_pasien_view.dart     # Form tambah & edit pasien (DatePicker, Radio, Dropdown)
    └── detail_pasien_view.dart   # Halaman detail pasien menerima Get.arguments

test/
└── pasien_service_test.dart      # Minimal 3 unit test (Create/Read, Update, Delete)
```

---

## 6. Checklist Aturan Validasi & Fitur Khusus Paket 5

1. **Validasi Field:**
   * `noRekamMedis`: Regex `^RM-\d{4}$` (contoh: `RM-0001`) + cek keunikan di `PasienService` saat tambah data.
   * `nama` & `keluhan`: Tidak boleh kosong (`value == null || value.trim().isEmpty`).
   * `tanggalLahir`: Menggunakan `showDatePicker` dengan batas maksimal `lastDate: DateTime.now()`.
   * `jenisKelamin`: Menggunakan widget `Radio` / `RadioListTile` dengan opsi `'L'` dan `'P'`.
   * `golonganDarah`: Menggunakan `DropdownButtonFormField` dengan opsi `['A', 'B', 'AB', 'O']`.
2. **Perhitungan Umur Otomatis:**
   * Dihitung dari selisih tahun `DateTime.now()` dengan `tanggalLahir` (memperhatikan bulan dan hari ulang tahun di tahun berjalan) dan ditampilkan langsung pada kartu pasien di halaman daftar.
3. **Routing & Arguments:**
   * Halaman daftar: `'/'` (atau `'/home'`)
   * Halaman form (Tambah/Edit): `'/form'`
   * Halaman detail: `'/detail'` menggunakan `Get.toNamed('/detail', arguments: pasien)`
4. **Unit Testing (`flutter test`):**
   * Gunakan `Hive.init('./test_hive')` (atau `Directory.systemTemp.createTempSync()`) pada blok `setUp()` di file `pasien_service_test.dart` agar unit test bisa berjalan tanpa emulator/HP.