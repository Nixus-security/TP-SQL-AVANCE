# TP1 — Matrice de tests

Douze tests. Dans la colonne **Obtenu**, écrivez `OK` (la commande passe et renvoie des lignes)
ou le numéro d'erreur complet, par exemple `ERROR 1142 (42000)`.

Un test se fait **connecté avec le compte concerné** :

```
mysql -u stagiaire -p mediatheque
```

Premier réflexe à chaque connexion : `SELECT CURRENT_ROLE();`. Si la réponse est `NONE`,
les rôles ne sont pas actifs et tous les tests qui suivent vont échouer pour la mauvaise raison.

## `app_media` — l'application web

| # | Commande | Attendu | Obtenu |
|---|---|---|---|
| 1 | `SELECT id, nom, prenom FROM adherent LIMIT 5;` | OK | OK |
| 2 | `SELECT email FROM adherent LIMIT 1;` | refus | ERROR 1143 (42000) |
| 3 | `UPDATE exemplaire SET disponible = 0 WHERE id = 3;` | OK | OK |
| 4 | `UPDATE exemplaire SET etat = 'use' WHERE id = 3;` | refus | ERROR 1143 (42000) |
| 5 | `DELETE FROM emprunt WHERE id = 1;` | refus | ERROR 1142 (42000) |

Les tests 3 et 4 portent sur la **même table** : c'est la colonne qui fait la différence.

## `biblio_marie` — la bibliothécaire

| # | Commande | Attendu | Obtenu |
|---|---|---|---|
| 6 | `SELECT nom, email, telephone FROM adherent LIMIT 3;` | OK | OK |
| 7 | `CREATE USER 'test'@'localhost' IDENTIFIED BY 'Test!2026';` | refus | ERROR 1227 (42000) |

## `stagiaire`

| # | Commande | Attendu | Obtenu |
|---|---|---|---|
| 8 | `SELECT nom, prenom, ville FROM adherent LIMIT 5;` | OK | OK |
| 9 | `SELECT email FROM adherent LIMIT 1;` | refus | ERROR 1143 (42000) |
| 10 | `SELECT * FROM adherent LIMIT 1;` | refus | ERROR 1142 (42000) |

**Question :** les tests 9 et 10 échouent tous les deux, mais pas avec le même numéro d'erreur. Pourquoi ?

> _votre réponse :_ Le test 9 nomme une colonne précise (`email`) : MySQL contrôle le privilège de colonne et refuse avec **1143** (« for column 'email' »). Le test 10 utilise `*` : l'étoile impose un `SELECT` sur la table entière, que `stagiaire` n'a pas (seulement des privilèges de colonne). Le refus tombe donc au niveau table : **1142** (« for table 'adherent' »).

## `analyste`

| # | Commande | Attendu | Obtenu |
|---|---|---|---|
| 11 | `SELECT COUNT(*) FROM adherent;` | refus | ERROR 1142 (42000) |
| 12 | `SELECT COUNT(*) FROM reservation;` | après le `GRANT` : OK — après le `REVOKE` : refus | après GRANT : OK — après REVOKE : ERROR 1142 (42000) |

## Conclusion

Une phrase : **parmi les quatre comptes, lequel peut encore faire quelque chose qu'il ne fera jamais — et comment le lui retireriez-vous ?**

> **`stagiaire`.** Son besoin a une date de fin (le stage), mais son compte, son mot de passe et ses droits de lecture sur le catalogue et sur les adhérents (adresse, ville…) survivent à son départ, sans limite de durée. On le lui retire à la fin du stage avec `ALTER USER 'stagiaire'@'localhost' ACCOUNT LOCK;` (réversible, droits conservés), puis `DROP USER 'stagiaire'@'localhost';` après la période d'audit.
