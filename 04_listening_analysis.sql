-- ============================================================
-- 04_LISTENING_ANALYSIS.SQL
-- Tujuan: Analisis aktivitas mendengarkan musik
-- Prasyarat: clean_logs sudah dibuat oleh file 03
-- ============================================================

USE spotify;

-- 4.1 Genre yang paling sering diputar.
SELECT
    genre_text,
    COUNT(*) AS total_play
FROM clean_logs
WHERE event_type = 'play'
GROUP BY genre_text
ORDER BY total_play DESC;

-- 4.2 Artis dengan jumlah pemutaran terbanyak.
SELECT
    artist_name,
    COUNT(*) AS total_play
FROM clean_logs
WHERE event_type = 'play'
GROUP BY artist_name
ORDER BY total_play DESC;

-- 4.3 Distribusi pemutaran berdasarkan jam.
-- Gunakan listen_timestamp, bukan listen_time.
SELECT
    HOUR(listen_timestamp) AS jam,
    COUNT(*) AS jumlah_play
FROM clean_logs
WHERE event_type = 'play'
  AND listen_timestamp IS NOT NULL
GROUP BY HOUR(listen_timestamp)
ORDER BY jam;

-- 4.4 Pengguna paling aktif berdasarkan seluruh jenis aktivitas.
SELECT
    username,
    COUNT(*) AS total_activity
FROM clean_logs
WHERE username IS NOT NULL
GROUP BY username
ORDER BY total_activity DESC;

-- 4.5 Log pemutaran dengan durasi tidak wajar.
-- Event like/save umumnya memiliki durasi 0, sehingga tidak
-- disertakan dalam pemeriksaan anomali durasi pemutaran.
SELECT *
FROM clean_logs
WHERE event_type = 'play'
  AND (
      duration_seconds <= 5
      OR duration_seconds > 3600
  )
ORDER BY duration_seconds;

-- 4.6 Ringkasan jenis event untuk memvalidasi distribusi aktivitas.
SELECT
    event_type,
    COUNT(*) AS jumlah_event
FROM clean_logs
GROUP BY event_type
ORDER BY jumlah_event DESC;
