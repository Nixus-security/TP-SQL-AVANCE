USE mediatheque;

SET SESSION cte_max_recursion_depth = 200000;

DELETE FROM emprunt    WHERE id > 13;
DELETE FROM exemplaire WHERE id > 13;
DELETE FROM adherent   WHERE id > 12;

INSERT INTO adherent (id, nom, prenom, email, telephone, date_naissance, adresse, code_postal, ville, date_inscription, actif)
WITH RECURSIVE seq (n) AS (
  SELECT 13
  UNION ALL
  SELECT n + 1 FROM seq WHERE n < 2012
)
SELECT n,
       CONCAT('Nom', n),
       CONCAT('Prenom', n),
       CONCAT('adherent', n, '@example.org'),
       CONCAT('07', LPAD(n, 8, '0')),
       DATE_ADD('1950-01-01', INTERVAL (n * 37) MOD 20000 DAY),
       CONCAT(n, ' rue du Test'),
       '69000',
       ELT(1 + n MOD 5, 'Lyon', 'Bron', 'Villeurbanne', 'Venissieux', 'Caluire'),
       DATE_ADD('2021-01-01', INTERVAL n MOD 365 DAY),
       1
FROM seq;

INSERT INTO exemplaire (id, ouvrage_id, code_barres, disponible)
WITH RECURSIVE seq (n) AS (
  SELECT 14
  UNION ALL
  SELECT n + 1 FROM seq WHERE n < 1013
)
SELECT n, 1 + n MOD 7, CONCAT('EX-', LPAD(n, 4, '0')), 1
FROM seq;

INSERT INTO emprunt (id, adherent_id, exemplaire_id, date_emprunt, date_retour_prevue, date_retour_reelle)
WITH RECURSIVE seq (n) AS (
  SELECT 14
  UNION ALL
  SELECT n + 1 FROM seq WHERE n < 200013
),
base AS (
  SELECT n,
         1 + (n * 7919) MOD 2012                           AS adherent_id,
         1 + (n * 31) MOD 1013                             AS exemplaire_id,
         DATE_ADD('2022-01-01', INTERVAL (n * 104729) MOD 1277 DAY) AS d
  FROM seq
)
SELECT n,
       adherent_id,
       exemplaire_id,
       d,
       DATE_ADD(d, INTERVAL 21 DAY),
       CASE WHEN d >= '2025-06-01' AND n MOD 3 = 0 THEN NULL
            ELSE DATE_ADD(d, INTERVAL 10 + n MOD 15 DAY)
       END
FROM base;

ANALYZE TABLE adherent, exemplaire, emprunt;

SELECT COUNT(*) AS nb_emprunts,
       SUM(date_retour_reelle IS NULL) AS nb_en_cours,
       MIN(date_emprunt) AS premier,
       MAX(date_emprunt) AS dernier
FROM emprunt;
