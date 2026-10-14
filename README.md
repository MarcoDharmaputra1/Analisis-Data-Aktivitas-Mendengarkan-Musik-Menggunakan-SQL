# Analisis Data Aktivitas Mendengarkan Musik Menggunakan SQL

## 1. Deskripsi Proyek

Proyek ini merupakan tugas akademik yang berfokus pada pembersihan, standardisasi, integrasi, dan analisis data aktivitas mendengarkan musik menggunakan SQL pada MySQL. Dataset terdiri atas data pengguna, metadata lagu, dan log aktivitas pengguna.

Proses analisis dilakukan untuk menyiapkan data yang konsisten, menggabungkan informasi dari beberapa tabel, serta mengeksplorasi pola pemutaran lagu dan aktivitas pengguna. Proyek ini juga mencakup modifikasi dataset menggunakan data sintetis untuk memperluas analisis jenis aktivitas, khususnya `like` dan `save`.

## 2. Tujuan Proyek

- Menstandarkan kategori genre lagu dan negara pengguna.
- Menormalkan variasi penulisan jenis aktivitas pengguna.
- Mengonversi timestamp dengan format berbeda ke format waktu yang konsisten.
- Menggabungkan log aktivitas dengan data pengguna dan metadata lagu.
- Menganalisis genre dan artis yang paling sering diputar, waktu pemutaran, aktivitas pengguna, serta anomali durasi.
- Mengevaluasi data setelah penambahan aktivitas sintetis `like` dan `save`.

## 3. Struktur Dataset

| Tabel | Deskripsi |
|---|---|
| `music_songs` | Metadata lagu, termasuk judul, artis, dan genre. |
| `music_users` | Data pengguna, termasuk username dan negara. |
| `music_listening_logs` | Catatan aktivitas pengguna, waktu aktivitas, dan durasi. |
| `clean_logs` | Hasil integrasi data awal. |
| `clean_logs_modified` | Hasil integrasi setelah penambahan data sintetis. |

## 4. Alur Pengolahan Data

### 4.1 Standardisasi Data

Genre lagu diseragamkan menjadi lima kategori utama: `pop`, `rock`, `electronic`, `acoustic`, dan `other`. Informasi negara pengguna disederhanakan menjadi kode `ID`, `MY`, `SG`, atau `other`.

### 4.2 Pembersihan Event dan Timestamp

Variasi penulisan event seperti `PLAY SONG`, `Liked`, `SAVE_SONG`, dan `saved` dinormalisasi menjadi kategori `play`, `like`, dan `save`. Event yang tidak dikenali dikelompokkan sebagai `other`.

Timestamp dengan format tanggal yang berbeda dikonversi menggunakan `STR_TO_DATE` agar dapat digunakan dalam analisis waktu.

### 4.3 Integrasi Data

Data log digabungkan dengan tabel pengguna dan lagu menggunakan `LEFT JOIN`. Pendekatan ini mempertahankan log sumber yang tidak memiliki pasangan pada tabel referensi sehingga ketidakcocokan dapat diperiksa.

### 4.4 Analisis Aktivitas

Analisis meliputi:
- Genre dengan jumlah pemutaran tertinggi.
- Artis dengan jumlah pemutaran terbanyak.
- Distribusi pemutaran berdasarkan jam.
- Pengguna dengan jumlah aktivitas tertinggi.
- Identifikasi durasi pemutaran yang tidak wajar.

### 4.5 Modifikasi Dataset

Sebanyak 28 baris aktivitas sintetis ditambahkan untuk memperluas kategori aktivitas `like` dan `save`. Setelah itu, event dan timestamp dinormalisasi kembali, tabel `clean_logs_modified` dibuat, dan distribusi aktivitas setelah modifikasi diperiksa.

## 5. Struktur Repository

```text
spotify-listening-data-analysis/
├── README.md
└── sql/
    ├── 01_data_standardization.sql
    ├── 02_event_timestamp_cleaning.sql
    ├── 03_data_integration.sql
    ├── 04_listening_analysis.sql
    └── 05_data_modification_analysis.sql
```

## 6. Teknologi

- MySQL
- SQL
- MySQL Workbench (jika digunakan)

## 7. Cara Menjalankan

1. Siapkan database bernama `spotify` dengan tabel sumber `music_songs`, `music_users`, dan `music_listening_logs`.
2. Pastikan nama kolom dan tipe data sesuai dengan query dalam folder `sql/`.
3. Jalankan file `01_data_standardization.sql`.
4. Jalankan file `02_event_timestamp_cleaning.sql`.
5. Jalankan file `03_data_integration.sql`.
6. Jalankan file `04_listening_analysis.sql`.
7. Jalankan file `05_data_modification_analysis.sql` hanya jika ingin menambahkan data sintetis dan melakukan analisis lanjutan.

**Penting:** file kelima memodifikasi tabel sumber. Jalankan pada salinan dataset atau setelah membuat cadangan. Data sintetis menggunakan `log_id` 73–100; pastikan tidak ada benturan ID sebelum menjalankannya.

## 8. Catatan dan Batasan

- Query mengasumsikan nama tabel dan kolom sesuai dengan struktur yang dijelaskan. Sesuaikan jika skema asli berbeda.
- Konversi timestamp mengasumsikan kolom `listen_timestamp` dapat menyimpan teks berformat campuran. Jika kolom sudah bertipe `DATETIME`, penanganan impor perlu disesuaikan.
- Penggabungan menggunakan username dan judul lagu. Jika nilai tersebut tidak unik, hasil `JOIN` dapat menghasilkan lebih banyak baris daripada tabel log sumber.
- Kategori genre berbasis pencocokan teks, sehingga hasil klasifikasi bergantung pada aturan dan urutan kondisi.
- Data sintetis digunakan untuk menguji alur pemrosesan aktivitas tambahan dan tidak merepresentasikan perilaku pengguna nyata.
- Hasil numerik dan kesimpulan akhir perlu diisi setelah query dijalankan dan hasilnya divalidasi.

## 9. Hasil Pembelajaran

Proyek ini melatih penggunaan SQL untuk standardisasi data, transformasi teks, konversi tanggal dan waktu, integrasi beberapa tabel, analisis agregat, pemeriksaan kualitas hasil penggabungan, serta evaluasi perubahan dataset setelah penambahan data sintetis.
