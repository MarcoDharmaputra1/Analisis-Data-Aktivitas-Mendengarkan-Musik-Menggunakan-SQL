-- ============================================================
-- 02_EVENT_TIMESTAMP_CLEANING.SQL
-- Tujuan: Normalisasi event dan format timestamp
-- Prasyarat: listen_timestamp dapat menyimpan teks dengan format
-- campuran. Jika kolom sudah bertipe DATETIME, konversi mungkin
-- sudah dilakukan pada tahap impor data.
-- ============================================================

USE spotify;

SET SQL_SAFE_UPDATES = 0;

-- 2.1 Normalisasi kategori event.
-- Kategori yang dikenali: play, like, save.
-- Event lain ditandai 'other' agar kategori analisis konsisten.
UPDATE music_listening_logs
SET event_type = CASE
    WHEN LOWER(REPLACE(REPLACE(TRIM(event_type), '_', ' '), '-', ' '))
         IN ('play', 'play song', 'listen', 'start')
        THEN 'play'
    WHEN LOWER(REPLACE(REPLACE(TRIM(event_type), '_', ' '), '-', ' '))
         IN ('like', 'liked')
        THEN 'like'
    WHEN LOWER(REPLACE(REPLACE(TRIM(event_type), '_', ' '), '-', ' '))
         IN ('save', 'save song', 'saved')
        THEN 'save'
    ELSE 'other'
END;

-- 2.2 Periksa distribusi kategori event setelah normalisasi.
SELECT event_type, COUNT(*) AS jumlah_event
FROM music_listening_logs
GROUP BY event_type
ORDER BY jumlah_event DESC;

-- 2.3 Konversi timestamp dari beberapa format teks ke DATETIME.
-- Format yang didukung:
--   YYYY/MM/DD HH:MM:SS
--   YYYY-MM-DD HH:MM:SS
--   DD/MM/YYYY HH:MM
-- Baris yang tidak cocok dengan format tersebut menjadi NULL.
-- Pastikan kolom listen_timestamp bertipe VARCHAR/TEXT saat
-- sumber masih berisi format campuran.
UPDATE music_listening_logs
SET listen_timestamp = CASE
    WHEN listen_timestamp LIKE '____/__/__ %'
        THEN STR_TO_DATE(listen_timestamp, '%Y/%m/%d %H:%i:%s')
    WHEN listen_timestamp LIKE '____-__-__ %'
        THEN STR_TO_DATE(listen_timestamp, '%Y-%m-%d %H:%i:%s')
    WHEN listen_timestamp LIKE '__/__/____ %'
        THEN STR_TO_DATE(listen_timestamp, '%d/%m/%Y %H:%i')
    ELSE NULL
END;

-- 2.4 Periksa timestamp yang gagal dikonversi atau kosong.
SELECT log_id, listen_timestamp
FROM music_listening_logs
WHERE listen_timestamp IS NULL;

-- 2.5 Periksa rentang timestamp setelah pembersihan.
SELECT
    MIN(listen_timestamp) AS timestamp_terawal,
    MAX(listen_timestamp) AS timestamp_terakhir,
    COUNT(*) AS total_log,
    SUM(listen_timestamp IS NULL) AS timestamp_kosong
FROM music_listening_logs;
