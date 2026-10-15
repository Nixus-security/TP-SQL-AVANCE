DROP USER IF EXISTS 'app_media'@'localhost';
DROP USER IF EXISTS 'biblio_marie'@'localhost';
DROP USER IF EXISTS 'stagiaire'@'localhost';
DROP USER IF EXISTS 'analyste'@'localhost';
DROP USER IF EXISTS 'analyste'@'192.168.1.%';

DROP ROLE IF EXISTS 'role_catalogue';
DROP ROLE IF EXISTS 'role_prets';
DROP ROLE IF EXISTS 'role_adherents';

CREATE ROLE 'role_catalogue', 'role_prets', 'role_adherents';

GRANT SELECT ON mediatheque.ouvrage    TO 'role_catalogue';
GRANT SELECT ON mediatheque.exemplaire TO 'role_catalogue';
GRANT SELECT ON mediatheque.categorie  TO 'role_catalogue';

GRANT SELECT, INSERT, UPDATE ON mediatheque.emprunt     TO 'role_prets';
GRANT SELECT, INSERT, UPDATE ON mediatheque.reservation TO 'role_prets';
GRANT SELECT, INSERT, UPDATE ON mediatheque.penalite    TO 'role_prets';
GRANT UPDATE (disponible)    ON mediatheque.exemplaire  TO 'role_prets';

GRANT SELECT, INSERT, UPDATE ON mediatheque.adherent TO 'role_adherents';

CREATE USER 'app_media'@'localhost'    IDENTIFIED BY 'App_Media#2026';
CREATE USER 'biblio_marie'@'localhost' IDENTIFIED BY 'Marie_Biblio#2026';
CREATE USER 'stagiaire'@'localhost'    IDENTIFIED BY 'Stagiaire#2026';
CREATE USER 'analyste'@'localhost'     IDENTIFIED BY 'Analyste#2026';

GRANT 'role_catalogue', 'role_prets'                    TO 'app_media'@'localhost';
GRANT 'role_catalogue', 'role_prets', 'role_adherents'  TO 'biblio_marie'@'localhost';
GRANT 'role_catalogue'                                  TO 'stagiaire'@'localhost';
GRANT 'role_catalogue'                                  TO 'analyste'@'localhost';

GRANT SELECT ON mediatheque.emprunt TO 'analyste'@'localhost';

GRANT SELECT (id, nom, prenom, actif)
  ON mediatheque.adherent TO 'app_media'@'localhost';
GRANT SELECT (id, nom, prenom, ville, date_inscription, actif)
  ON mediatheque.adherent TO 'stagiaire'@'localhost';

SET DEFAULT ROLE ALL TO
  'app_media'@'localhost',
  'biblio_marie'@'localhost',
  'stagiaire'@'localhost',
  'analyste'@'localhost';

SHOW GRANTS FOR 'app_media'@'localhost'    USING 'role_catalogue', 'role_prets';
SHOW GRANTS FOR 'biblio_marie'@'localhost' USING 'role_catalogue', 'role_prets', 'role_adherents';
SHOW GRANTS FOR 'stagiaire'@'localhost'    USING 'role_catalogue';
SHOW GRANTS FOR 'analyste'@'localhost'     USING 'role_catalogue';

SELECT grantee, table_name, column_name, privilege_type
FROM information_schema.column_privileges
WHERE table_schema = 'mediatheque'
ORDER BY grantee, table_name, column_name, privilege_type;

GRANT SELECT ON mediatheque.reservation TO 'analyste'@'localhost';
SHOW GRANTS FOR 'analyste'@'localhost';
REVOKE SELECT ON mediatheque.reservation FROM 'analyste'@'localhost';
SHOW GRANTS FOR 'analyste'@'localhost';

CREATE USER 'analyste'@'192.168.1.%' IDENTIFIED BY 'Analyste#2026';
GRANT 'role_catalogue' TO 'analyste'@'192.168.1.%';
GRANT SELECT ON mediatheque.emprunt TO 'analyste'@'192.168.1.%';
SET DEFAULT ROLE ALL TO 'analyste'@'192.168.1.%';

-- Si 'analyste'@'%' existait aussi : MySQL choisit pour chaque connexion UN SEUL compte,
-- le plus spécifique (hôte sans joker avant hôte avec joker, motif le plus précis d'abord).
-- 'analyste'@'192.168.1.%' passe donc avant 'analyste'@'%' pour une IP en 192.168.1.x,
-- et les droits des deux comptes ne s'additionnent JAMAIS. Piège : un mot de passe
-- différent sur '%' est refusé depuis 192.168.1.x (le compte retenu est celui du
-- sous-réseau), et si '%' avait plus de droits, ils ne s'appliqueraient qu'aux autres IP.

-- Fin de stage : deux options.
--   ALTER USER 'stagiaire'@'localhost' ACCOUNT LOCK;   -- verrouille, garde le compte et ses droits
--   DROP USER 'stagiaire'@'localhost';                 -- supprime compte et privilèges
-- Choix : ACCOUNT LOCK d'abord (réversible, trace conservée, réactivable si le stage est
-- prolongé ou pour un prochain stagiaire), puis DROP USER une fois la période d'audit passée.
