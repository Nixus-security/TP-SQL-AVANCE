USE mediatheque;

CREATE OR REPLACE VIEW v_adherent_lyon AS
SELECT id, nom, prenom, email, telephone, date_naissance,
       adresse, code_postal, ville, date_inscription, actif
FROM adherent
WHERE ville = 'Lyon'
WITH CHECK OPTION;

DELETE FROM adherent WHERE email IN ('test.lyon@example.org', 'test.bron@example.org');

INSERT INTO v_adherent_lyon
  (nom, prenom, email, telephone, date_naissance, adresse, code_postal, ville, date_inscription, actif)
VALUES
  ('Test', 'Lyon', 'test.lyon@example.org', '0400000001', '1990-01-01',
   '1 rue de la Republique', '69002', 'Lyon', CURDATE(), 1);

SELECT id, nom, prenom, ville FROM adherent WHERE email = 'test.lyon@example.org';

INSERT INTO v_adherent_lyon
  (nom, prenom, email, telephone, date_naissance, adresse, code_postal, ville, date_inscription, actif)
VALUES
  ('Test', 'Bron', 'test.bron@example.org', '0400000002', '1990-01-01',
   '2 avenue Franklin Roosevelt', '69500', 'Bron', CURDATE(), 1);

UPDATE v_catalogue SET titre = 'Titre modifie' WHERE ouvrage_id = 1;

SELECT table_name, is_updatable
FROM information_schema.views
WHERE table_schema = 'mediatheque'
  AND table_name IN ('v_catalogue', 'v_adherent_public', 'v_emprunt_en_cours', 'v_retard', 'v_adherent_lyon')
ORDER BY table_name;
