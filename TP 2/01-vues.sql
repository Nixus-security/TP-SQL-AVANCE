USE mediatheque;

CREATE OR REPLACE SQL SECURITY DEFINER VIEW v_catalogue AS
SELECT o.id                               AS ouvrage_id,
       o.titre                            AS titre,
       o.auteur                           AS auteur,
       o.annee                            AS annee,
       c.libelle                          AS categorie,
       COUNT(e.id)                        AS nb_exemplaires,
       COALESCE(SUM(e.disponible = 1), 0) AS nb_disponibles
FROM ouvrage o
JOIN categorie c       ON c.id = o.categorie_id
LEFT JOIN exemplaire e ON e.ouvrage_id = o.id
GROUP BY o.id, o.titre, o.auteur, o.annee, c.libelle;

CREATE OR REPLACE SQL SECURITY DEFINER VIEW v_adherent_public AS
SELECT id, nom, prenom, adresse, code_postal, ville, date_inscription, actif
FROM adherent;

CREATE OR REPLACE SQL SECURITY DEFINER VIEW v_emprunt_en_cours AS
SELECT em.id                                           AS emprunt_id,
       em.date_emprunt                                 AS date_emprunt,
       em.date_retour_prevue                           AS date_retour_prevue,
       DATEDIFF(CURDATE(), em.date_retour_prevue)      AS jours_retard,
       CONCAT(a.prenom, ' ', a.nom)                    AS adherent,
       o.titre                                         AS titre,
       ex.code_barres                                  AS code_barres
FROM emprunt em
JOIN adherent a    ON a.id  = em.adherent_id
JOIN exemplaire ex ON ex.id = em.exemplaire_id
JOIN ouvrage o     ON o.id  = ex.ouvrage_id
WHERE em.date_retour_reelle IS NULL;

CREATE OR REPLACE SQL SECURITY DEFINER VIEW v_retard AS
SELECT *
FROM v_emprunt_en_cours
WHERE jours_retard > 0;

REVOKE SELECT (id, nom, prenom, adresse, code_postal, ville, date_inscription, actif)
  ON mediatheque.adherent FROM 'stagiaire'@'localhost';
REVOKE 'role_catalogue' FROM 'stagiaire'@'localhost';

GRANT SELECT ON mediatheque.v_adherent_public  TO 'stagiaire'@'localhost';
GRANT SELECT ON mediatheque.v_catalogue        TO 'stagiaire'@'localhost';
GRANT SELECT ON mediatheque.v_emprunt_en_cours TO 'stagiaire'@'localhost';

SHOW GRANTS FOR 'stagiaire'@'localhost';
