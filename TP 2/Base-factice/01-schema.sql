CREATE DATABASE IF NOT EXISTS mediatheque CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci;
USE mediatheque;

SET FOREIGN_KEY_CHECKS = 0;
DROP TABLE IF EXISTS penalite;
DROP TABLE IF EXISTS reservation;
DROP TABLE IF EXISTS emprunt;
DROP TABLE IF EXISTS exemplaire;
DROP TABLE IF EXISTS ouvrage;
DROP TABLE IF EXISTS categorie;
DROP TABLE IF EXISTS adherent;
SET FOREIGN_KEY_CHECKS = 1;

CREATE TABLE categorie (
  id      INT UNSIGNED NOT NULL AUTO_INCREMENT,
  libelle VARCHAR(60)  NOT NULL,
  PRIMARY KEY (id)
) ENGINE = InnoDB;

CREATE TABLE ouvrage (
  id           INT UNSIGNED NOT NULL AUTO_INCREMENT,
  titre        VARCHAR(150) NOT NULL,
  auteur       VARCHAR(100) NOT NULL,
  annee        SMALLINT     NOT NULL,
  categorie_id INT UNSIGNED NOT NULL,
  PRIMARY KEY (id),
  CONSTRAINT fk_ouvrage_categorie FOREIGN KEY (categorie_id) REFERENCES categorie (id)
) ENGINE = InnoDB;

CREATE TABLE exemplaire (
  id          INT UNSIGNED NOT NULL AUTO_INCREMENT,
  ouvrage_id  INT UNSIGNED NOT NULL,
  code_barres VARCHAR(20)  NOT NULL,
  disponible  TINYINT(1)   NOT NULL DEFAULT 1,
  PRIMARY KEY (id),
  UNIQUE KEY uq_exemplaire_code_barres (code_barres),
  CONSTRAINT fk_exemplaire_ouvrage FOREIGN KEY (ouvrage_id) REFERENCES ouvrage (id)
) ENGINE = InnoDB;

CREATE TABLE adherent (
  id               INT UNSIGNED NOT NULL AUTO_INCREMENT,
  nom              VARCHAR(60)  NOT NULL,
  prenom           VARCHAR(60)  NOT NULL,
  email            VARCHAR(120) NOT NULL,
  telephone        VARCHAR(20)  NULL,
  date_naissance   DATE         NULL,
  adresse          VARCHAR(150) NULL,
  code_postal      VARCHAR(10)  NULL,
  ville            VARCHAR(60)  NOT NULL,
  date_inscription DATE         NOT NULL,
  actif            TINYINT(1)   NOT NULL DEFAULT 1,
  PRIMARY KEY (id),
  UNIQUE KEY uq_adherent_email (email)
) ENGINE = InnoDB;

CREATE TABLE emprunt (
  id                 INT UNSIGNED NOT NULL AUTO_INCREMENT,
  adherent_id        INT UNSIGNED NOT NULL,
  exemplaire_id      INT UNSIGNED NOT NULL,
  date_emprunt       DATE         NOT NULL,
  date_retour_prevue DATE         NOT NULL,
  date_retour_reelle DATE         NULL,
  PRIMARY KEY (id),
  CONSTRAINT fk_emprunt_adherent   FOREIGN KEY (adherent_id)   REFERENCES adherent (id),
  CONSTRAINT fk_emprunt_exemplaire FOREIGN KEY (exemplaire_id) REFERENCES exemplaire (id)
) ENGINE = InnoDB;

CREATE TABLE reservation (
  id               INT UNSIGNED NOT NULL AUTO_INCREMENT,
  adherent_id      INT UNSIGNED NOT NULL,
  ouvrage_id       INT UNSIGNED NOT NULL,
  date_reservation DATE         NOT NULL,
  PRIMARY KEY (id),
  CONSTRAINT fk_reservation_adherent FOREIGN KEY (adherent_id) REFERENCES adherent (id),
  CONSTRAINT fk_reservation_ouvrage  FOREIGN KEY (ouvrage_id)  REFERENCES ouvrage (id)
) ENGINE = InnoDB;

CREATE TABLE penalite (
  id          INT UNSIGNED  NOT NULL AUTO_INCREMENT,
  adherent_id INT UNSIGNED  NOT NULL,
  montant     DECIMAL(6, 2) NOT NULL,
  date_penalite DATE        NOT NULL,
  PRIMARY KEY (id),
  CONSTRAINT fk_penalite_adherent FOREIGN KEY (adherent_id) REFERENCES adherent (id)
) ENGINE = InnoDB;
