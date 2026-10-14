-- ============================================================
-- 03_DATA_INTEGRATION.SQL
-- Tujuan: Menggabungkan log, pengguna, dan metadata lagu
-- Hasil: Tabel clean_logs
-- ============================================================

USE spotify;

DROP TABLE IF EXISTS clean_logs;

-- LEFT JOIN mempertahankan log walaupun username atau judul lagu
-- tidak cocok dengan tabel referensi. Kolom referensi yang tidak
-- cocok akan bernilai NULL dan dapat diperiksa terpisah.
CREATE TABLE clean_logs AS
SELECT
    l.log_id,
    u.user_id,
    l.user_name,
    u.username,
    u.country,
    s.song_id,
    l.song_title,
    s.title,
    s.artist_name,
    s.genre_text,
    l.event_type,
    l.listen_timestamp,
    l.duration_seconds
FROM music_listening_logs AS l
LEFT JOIN music_users AS u
    ON l.user_name = u.username
LEFT JOIN music_songs AS s
    ON l.song_title = s.title;

-- 3.1 Tinjau sampel hasil integrasi.
SELECT *
FROM clean_logs
LIMIT 100;

-- 3.2 Periksa log yang tidak berhasil dicocokkan dengan pengguna.
SELECT
    log_id,
    user_name
FROM clean_logs
WHERE user_id IS NULL;

-- 3.3 Periksa log yang tidak berhasil dicocokkan dengan metadata lagu.
SELECT
    log_id,
    song_title
FROM clean_logs
WHERE song_id IS NULL;

-- 3.4 Pastikan jumlah baris tabel hasil integrasi dibandingkan
-- dengan tabel sumber. Perbedaan dapat menandakan join satu-ke-banyak
-- akibat username atau judul lagu yang tidak unik.
SELECT
    (SELECT COUNT(*) FROM music_listening_logs) AS jumlah_log_sumber,
    (SELECT COUNT(*) FROM clean_logs) AS jumlah_baris_clean_logs;
