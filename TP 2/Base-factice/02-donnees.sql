USE mediatheque;

INSERT INTO categorie (id, libelle) VALUES
  (1, 'Roman'), (2, 'Science-fiction'), (3, 'Policier'), (4, 'Histoire'), (5, 'Jeunesse');

INSERT INTO ouvrage (id, titre, auteur, annee, categorie_id) VALUES
  (1, 'Les Miserables',            'Victor Hugo',        1862, 1),
  (2, 'Dune',                      'Frank Herbert',      1965, 2),
  (3, 'Fondation',                 'Isaac Asimov',       1951, 2),
  (4, 'Le Crime de l''Orient-Express', 'Agatha Christie', 1934, 3),
  (5, 'Millenium 1',               'Stieg Larsson',      2005, 3),
  (6, 'Histoire de France',        'Jacques Bainville',  1924, 4),
  (7, 'Le Petit Prince',           'Antoine de Saint-Exupery', 1943, 5),
  (8, 'Ouvrage sans exemplaire',   'Auteur Inconnu',     2020, 1);

INSERT INTO exemplaire (id, ouvrage_id, code_barres, disponible) VALUES
  (1, 1, 'EX-0001', 1), (2, 1, 'EX-0002', 0),
  (3, 2, 'EX-0003', 0), (4, 2, 'EX-0004', 1), (5, 2, 'EX-0005', 1),
  (6, 3, 'EX-0006', 1),
  (7, 4, 'EX-0007', 0), (8, 4, 'EX-0008', 1),
  (9, 5, 'EX-0009', 1),
  (10, 6, 'EX-0010', 0),
  (11, 7, 'EX-0011', 1), (12, 7, 'EX-0012', 0), (13, 7, 'EX-0013', 1);

INSERT INTO adherent (id, nom, prenom, email, telephone, date_naissance, adresse, code_postal, ville, date_inscription, actif) VALUES
  (1,  'Martin',   'Alice',   'alice.martin@example.org',   '0600000001', '1985-03-12', '10 rue Victor Hugo',     '69001', 'Lyon',        '2022-01-10', 1),
  (2,  'Bernard',  'Hugo',    'hugo.bernard@example.org',   '0600000002', '1990-07-01', '5 avenue Jean Jaures',   '69007', 'Lyon',        '2022-02-15', 1),
  (3,  'Petit',    'Lea',     'lea.petit@example.org',      '0600000003', '2001-11-23', '8 rue de la Paix',       '69500', 'Bron',        '2022-03-20', 1),
  (4,  'Durand',   'Paul',    'paul.durand@example.org',    '0600000004', '1978-05-30', '2 place Bellecour',      '69002', 'Lyon',        '2022-04-05', 1),
  (5,  'Leroy',    'Emma',    'emma.leroy@example.org',     '0600000005', '1995-09-14', '14 rue Pasteur',         '69100', 'Villeurbanne','2022-05-12', 1),
  (6,  'Moreau',   'Lucas',   'lucas.moreau@example.org',   '0600000006', '1988-12-02', '3 impasse des Lilas',    '69200', 'Venissieux',  '2022-06-18', 1),
  (7,  'Simon',    'Chloe',   'chloe.simon@example.org',    '0600000007', '2003-02-27', '21 rue Garibaldi',       '69003', 'Lyon',        '2022-07-22', 1),
  (8,  'Laurent',  'Nathan',  'nathan.laurent@example.org', '0600000008', '1992-06-08', '6 rue de la Republique', '69500', 'Bron',       '2023-01-09', 1),
  (9,  'Michel',   'Jade',    'jade.michel@example.org',    '0600000009', '1999-10-19', '17 cours Lafayette',     '69003', 'Lyon',        '2023-02-14', 1),
  (10, 'Garcia',   'Tom',     'tom.garcia@example.org',     '0600000010', '1983-04-04', '9 rue Mercière',         '69002', 'Lyon',        '2023-03-03', 0),
  (11, 'Roux',     'Manon',   'manon.roux@example.org',     '0600000011', '1997-08-21', '12 boulevard des Etats-Unis', '69008', 'Lyon',   '2023-04-11', 1),
  (12, 'Fournier', 'Louis',   'louis.fournier@example.org', '0600000012', '1980-01-17', '4 rue Servient',         '69003', 'Lyon',        '2023-05-16', 1);

INSERT INTO emprunt (id, adherent_id, exemplaire_id, date_emprunt, date_retour_prevue, date_retour_reelle) VALUES
  (1,  1,  1,  '2024-01-10', '2024-01-31', '2024-01-28'),
  (2,  2,  4,  '2024-02-05', '2024-02-26', '2024-02-26'),
  (3,  12, 6,  '2024-03-12', '2024-04-02', '2024-04-01'),
  (4,  12, 8,  '2025-01-15', '2025-02-05', '2025-02-03'),
  (5,  3,  9,  '2024-03-12', '2024-04-02', '2024-04-10'),
  (6,  4,  11, '2024-06-01', '2024-06-22', '2024-06-20'),
  (7,  5,  13, '2024-09-14', '2024-10-05', '2024-10-05'),
  (8,  12, 5,  '2025-03-02', '2025-03-23', '2025-03-20'),
  (9,  6,  2,  '2025-02-10', '2025-03-03', NULL),
  (10, 7,  3,  '2025-04-01', '2025-04-22', NULL),
  (11, 8,  7,  '2025-05-05', '2025-05-26', NULL),
  (12, 9,  10, '2025-06-01', '2025-06-22', NULL),
  (13, 11, 12, CURDATE() - INTERVAL 5 DAY, CURDATE() + INTERVAL 16 DAY, NULL);

INSERT INTO reservation (adherent_id, ouvrage_id, date_reservation) VALUES
  (1, 2, '2025-05-01'), (5, 4, '2025-05-10');

INSERT INTO penalite (adherent_id, montant, date_penalite) VALUES
  (3, 3.50, '2024-04-10'), (6, 12.00, '2025-03-04');
