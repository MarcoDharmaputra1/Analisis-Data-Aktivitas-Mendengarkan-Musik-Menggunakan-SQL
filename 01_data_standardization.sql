-- ============================================================
-- 01_DATA_STANDARDIZATION.SQL
-- Tujuan: Standardisasi genre lagu dan negara pengguna
-- Database: spotify
-- Prasyarat: Tabel music_songs dan music_users sudah tersedia
-- ============================================================

USE spotify;

-- 1.1 Standardisasi teks genre: hapus spasi tepi, ubah ke lowercase,
-- dan samakan tanda hubung menjadi spasi.
UPDATE music_songs
SET genre_text = LOWER(REPLACE(TRIM(genre_text), '-', ' '))
WHERE genre_text IS NOT NULL;

-- 1.2 Kelompokkan genre ke dalam lima kategori utama.
-- Urutan kondisi menentukan kategori ketika sebuah teks cocok
-- dengan lebih dari satu pola.
UPDATE music_songs
SET genre_text = CASE
    WHEN genre_text LIKE '%pop%' THEN 'pop'
    WHEN genre_text LIKE '%rock%'
      OR genre_text LIKE '%alternatif%'
      OR genre_text LIKE '%alternative%' THEN 'rock'
    WHEN genre_text LIKE '%electronic%'
      OR genre_text LIKE '%edm%' THEN 'electronic'
    WHEN genre_text LIKE '%acoustic%'
      OR genre_text LIKE '%accoustic%' THEN 'acoustic'
    ELSE 'other'
END
WHERE genre_text IS NOT NULL;

-- 1.3 Standardisasi negara pengguna menjadi ID, MY, SG, atau other.
-- Menggunakan pencocokan nilai/penanda yang lebih spesifik agar
-- teks negara lain tidak salah diklasifikasikan hanya karena
-- mengandung rangkaian huruf tertentu.
UPDATE music_users
SET country = CASE
    WHEN LOWER(TRIM(country)) IN ('id', 'indonesia', 'indonesian')
      OR LOWER(TRIM(country)) LIKE 'indonesia %'
      OR LOWER(TRIM(country)) REGEXP '(^|[^a-z])id([^a-z]|$)'
        THEN 'ID'
    WHEN LOWER(TRIM(country)) IN ('my', 'malaysia', 'malaysian')
      OR LOWER(TRIM(country)) REGEXP '(^|[^a-z])my([^a-z]|$)'
        THEN 'MY'
    WHEN LOWER(TRIM(country)) IN ('sg', 'singapore', 'singaporean')
      OR LOWER(TRIM(country)) REGEXP '(^|[^a-z])sg([^a-z]|$)'
        THEN 'SG'
    ELSE 'other'
END
WHERE country IS NOT NULL;

-- 1.4 Pemeriksaan hasil standardisasi.
SELECT genre_text, COUNT(*) AS jumlah_lagu
FROM music_songs
GROUP BY genre_text
ORDER BY jumlah_lagu DESC;

SELECT country, COUNT(*) AS jumlah_pengguna
FROM music_users
GROUP BY country
ORDER BY jumlah_pengguna DESC;
