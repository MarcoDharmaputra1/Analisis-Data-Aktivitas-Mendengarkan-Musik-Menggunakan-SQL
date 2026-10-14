-- ============================================================
-- 05_DATA_MODIFICATION_ANALYSIS.SQL
-- Tujuan: Menambahkan data sintetis like/save dan menganalisis
-- hasil modifikasi.
--
-- PERHATIAN:
-- 1. Jalankan hanya sekali pada dataset yang belum memiliki log_id
--    73 sampai 100.
-- 2. INSERT IGNORE mengandalkan log_id sebagai PRIMARY KEY atau
--    UNIQUE KEY untuk mencegah duplikasi ID.
-- 3. Pastikan pengguna dan judul lagu pada data sintetis tersedia
--    di music_users dan music_songs.
-- ============================================================

USE spotify;

SET SQL_SAFE_UPDATES = 0;

-- 5.1 Menambahkan 28 baris data sintetis.
-- INSERT IGNORE membantu melewati benturan unique key, jika ada.
INSERT IGNORE INTO music_listening_logs
    (log_id, user_name, song_title, event_type, listen_timestamp, duration_seconds)
VALUES
(73, 'andi_music', 'City Lights', 'like', '2025-09-04 08:15:00', 0),
(74, 'kiki_song', 'Langit Senja', 'SAVE', '2025/09/04 08:20:00', 0),
(75, 'hana_l', 'Pulse', 'Liked', '04/09/2025 08:30', 0),
(76, 'indra99', 'Broken Roads', 'save_song', '2025-09-04 09:10:00', 0),
(77, 'dewii', 'Silent Echo', 'Like', '2025-09-04 09:15:00', 0),
(78, 'eko_stream', 'Rindu Malam', 'saved', '2025-09-04 09:25:00', 0),
(79, 'budi88', 'City Lights', 'LIKE', '2025-09-04 10:05:00', 0),
(80, 'citra.id', 'Pulse', 'save', '04/09/2025 10:15', 0),
(81, 'linaaudio', 'Langit Senja', 'like', '2025/09/04 10:45:00', 0),
(82, 'andi_music', 'Midnight Drive', 'SAVE_SONG', '2025-09-04 11:00:00', 0),
(83, 'kiki_song', 'Broken Roads', 'Liked', '2025-09-04 11:30:00', 0),
(84, 'hana_l', 'City Lights', 'save', '2025-09-04 12:15:00', 0),
(85, 'indra99', 'Silent Echo', 'like', '04/09/2025 13:00', 0),
(86, 'dewii', 'Langit Senja', 'Saved', '2025-09-04 13:20:00', 0),
(87, 'eko_stream', 'Pulse', 'Like', '2025/09/04 14:10:00', 0),
(88, 'budi88', 'Broken Roads', 'save', '2025-09-04 15:05:00', 0),
(89, 'citra.id', 'Silent Echo', 'like', '2025-09-04 15:30:00', 0),
(90, 'linaaudio', 'City Lights', 'save_song', '04/09/2025 16:00', 0),
(91, 'andi_music', 'Rindu Malam', 'Like', '2025-09-04 16:45:00', 0),
(92, 'kiki_song', 'Pulse', 'saved', '2025-09-04 17:15:00', 0),
(93, 'hana_l', 'Broken Roads', 'LIKE', '2025/09/04 18:00:00', 0),
(94, 'indra99', 'City Lights', 'save', '2025-09-04 19:10:00', 0),
(95, 'dewii', 'Midnight Drive', 'like', '2025-09-04 19:40:00', 0),
(96, 'eko_stream', 'Langit Senja', 'SAVE', '04/09/2025 20:05', 0),
(97, 'budi88', 'Pulse', 'Liked', '2025-09-04 21:00:00', 0),
(98, 'citra.id', 'Broken Roads', 'save', '2025-09-04 21:30:00', 0),
(99, 'linaaudio', 'Silent Echo', 'like', '2025/09/04 22:15:00', 0),
(100, 'andi_music', 'Langit Senja', 'Saved', '2025-09-04 23:00:00', 0);

-- 5.2 Normalisasi event pada seluruh data, termasuk data sintetis.
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

-- 5.3 Normalisasi timestamp setelah data sintetis ditambahkan.
-- Diasumsikan kolom listen_timestamp bertipe VARCHAR/TEXT.
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

-- 5.4 Buat ulang tabel hasil integrasi yang sudah dimodifikasi.
DROP TABLE IF EXISTS clean_logs_modified;

CREATE TABLE clean_logs_modified AS
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

-- 5.5 Ringkasan jumlah setiap jenis event setelah modifikasi.
SELECT
    event_type,
    COUNT(*) AS jumlah_event
FROM clean_logs_modified
GROUP BY event_type
ORDER BY jumlah_event DESC;

-- 5.6 Ringkasan aktivitas like dan save per lagu.
SELECT
    title,
    SUM(event_type = 'like') AS jumlah_like,
    SUM(event_type = 'save') AS jumlah_save
FROM clean_logs_modified
GROUP BY title
ORDER BY jumlah_like DESC, jumlah_save DESC;

-- 5.7 Bandingkan jumlah baris sebelum dan sesudah modifikasi.
-- clean_logs harus sudah dibuat sebelum file ini dijalankan.
SELECT
    (SELECT COUNT(*) FROM clean_logs) AS jumlah_baris_sebelum,
    (SELECT COUNT(*) FROM clean_logs_modified) AS jumlah_baris_sesudah;
