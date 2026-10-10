USE mediatheque;

DROP PROCEDURE IF EXISTS creer_index_si_absent;
DELIMITER //
CREATE PROCEDURE creer_index_si_absent(IN p_index VARCHAR(64), IN p_colonnes VARCHAR(200))
BEGIN
  IF NOT EXISTS (SELECT 1 FROM information_schema.statistics
                 WHERE table_schema = 'mediatheque' AND table_name = 'emprunt' AND index_name = p_index) THEN
    SET @ddl = CONCAT('CREATE INDEX ', p_index, ' ON emprunt (', p_colonnes, ')');
    PREPARE st FROM @ddl;
    EXECUTE st;
    DEALLOCATE PREPARE st;
  END IF;
END//
DELIMITER ;

SELECT index_name, seq_in_index, column_name
FROM information_schema.statistics
WHERE table_schema = 'mediatheque' AND table_name = 'emprunt'
ORDER BY index_name, seq_in_index;

ANALYZE TABLE emprunt;

SELECT ROUND(data_length / 1024 / 1024, 2)  AS donnees_mo,
       ROUND(index_length / 1024 / 1024, 2) AS index_mo
FROM information_schema.tables
WHERE table_schema = 'mediatheque' AND table_name = 'emprunt';

EXPLAIN SELECT * FROM emprunt WHERE date_emprunt = '2024-03-12';
SELECT COUNT(*) AS lignes_r1 FROM emprunt WHERE date_emprunt = '2024-03-12';

EXPLAIN SELECT * FROM emprunt WHERE date_retour_reelle IS NULL;
SELECT COUNT(*) AS lignes_r2 FROM emprunt WHERE date_retour_reelle IS NULL;

EXPLAIN SELECT id, date_emprunt FROM emprunt
 WHERE adherent_id = 12 AND date_emprunt >= '2025-01-01';
SELECT COUNT(*) AS lignes_r3 FROM emprunt
 WHERE adherent_id = 12 AND date_emprunt >= '2025-01-01';

CALL creer_index_si_absent('idx_emprunt_date', 'date_emprunt');
ANALYZE TABLE emprunt;
EXPLAIN SELECT * FROM emprunt WHERE date_emprunt = '2024-03-12';

CALL creer_index_si_absent('idx_emprunt_retour_reel', 'date_retour_reelle');
ANALYZE TABLE emprunt;
EXPLAIN SELECT * FROM emprunt WHERE date_retour_reelle IS NULL;

CALL creer_index_si_absent('idx_emprunt_adherent_date', 'adherent_id, date_emprunt');
ANALYZE TABLE emprunt;
EXPLAIN SELECT id, date_emprunt FROM emprunt
 WHERE adherent_id = 12 AND date_emprunt >= '2025-01-01';

EXPLAIN SELECT id FROM emprunt WHERE adherent_id = 12;
EXPLAIN SELECT id FROM emprunt WHERE date_emprunt >= '2025-01-01';

EXPLAIN SELECT adherent_id, date_emprunt FROM emprunt WHERE adherent_id = 12;
EXPLAIN SELECT adherent_id, date_emprunt, exemplaire_id FROM emprunt WHERE adherent_id = 12;

EXPLAIN SELECT COUNT(*) FROM emprunt WHERE YEAR(date_emprunt) = 2024;
SELECT COUNT(*) AS total_origine FROM emprunt WHERE YEAR(date_emprunt) = 2024;
EXPLAIN SELECT COUNT(*) FROM emprunt
 WHERE date_emprunt >= '2024-01-01' AND date_emprunt < '2025-01-01';
SELECT COUNT(*) AS total_reecrit FROM emprunt
 WHERE date_emprunt >= '2024-01-01' AND date_emprunt < '2025-01-01';

SELECT ROUND(data_length / 1024 / 1024, 2)  AS donnees_mo,
       ROUND(index_length / 1024 / 1024, 2) AS index_mo
FROM information_schema.tables
WHERE table_schema = 'mediatheque' AND table_name = 'emprunt';

DROP INDEX idx_emprunt_adherent_date ON emprunt;

EXPLAIN SELECT * FROM v_retard;
