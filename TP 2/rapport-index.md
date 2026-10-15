# TP2 — Rapport d'optimisation

> Les chiffres attendus sont des **ordres de grandeur** : l'archive est générée
> aléatoirement, les vôtres seront proches sans être identiques.
>
> **État :** mesures relevées sur MySQL 8.4.11 avec la base officielle (`Base/01-schema.sql`,
> `02-donnees.sql`, `03-volume.sql` : 200 130 emprunts dont 30 en cours), sortie de `03-index.sql`.

## Avant / après

Pour chaque requête : le plan avant tout index, puis le plan après l'index que vous avez posé.

### R1 — les emprunts d'une journée

```sql
SELECT * FROM emprunt WHERE date_emprunt = '2024-03-12';
```

| | `type` | `key` | `rows` | `Extra` |
|---|---|---|---|---|
| avant | `ALL` | `NULL` | 199 875 | `Using where` |
| après | `ref` | `idx_emprunt_date` | 104 | — |

- Index créé : `idx_emprunt_date (date_emprunt)`
- Lignes réellement renvoyées : `104`
- Une phrase de conclusion : une journée pèse une infime part des 200 000 lignes, l'index remplace le parcours complet par un accès direct à ces lignes.

### R2 — les emprunts en cours

```sql
SELECT * FROM emprunt WHERE date_retour_reelle IS NULL;
```

| | `type` | `key` | `rows` | `Extra` |
|---|---|---|---|---|
| avant | `ALL` | `NULL` | 199 875 | `Using where` |
| après | `ref` | `idx_emprunt_retour_reel` | 30 | `Using index condition` |

- Index créé : `idx_emprunt_retour_reel (date_retour_reelle)`
- Lignes réellement renvoyées : `30`
- Une phrase de conclusion : l'index sert parce que les emprunts en cours sont peu nombreux face aux 200 000 lignes d'archive ; si la plupart des lignes étaient à `NULL`, l'optimiseur préférerait le parcours complet.

### R3 — l'historique récent d'un adhérent

```sql
SELECT id, date_emprunt FROM emprunt
 WHERE adherent_id = 12 AND date_emprunt >= '2025-01-01';
```

| | `type` | `key` | `rows` | `Extra` |
|---|---|---|---|---|
| avant | `ref` | `fk_emprunt_adherent` | 5 070 | `Using where` |
| après | `range` | `idx_emprunt_adherent_date` | 741 | `Using where; Using index` |

- Index créé : `idx_emprunt_adherent_date (adherent_id, date_emprunt)`
- Lignes réellement renvoyées : `741`
- Avant, l'index automatique de la clé étrangère servait déjà, mais seulement sur `adherent_id` : 5 070 lignes lues puis filtrées sur la date. Le composite lit directement la plage de dates de l'adhérent, et couvre la requête (`Using index`).
- Pourquoi les colonnes sont-elles dans cet ordre, et pas dans l'autre ? `adherent_id` est filtré par égalité et `date_emprunt` par intervalle. Égalité d'abord : l'index se positionne sur l'adhérent, puis lit la plage de dates, déjà triée. Dans l'ordre inverse, l'intervalle passe en tête et `adherent_id` ne sert plus à se positionner.

## Le préfixe gauche (consigne 7)

| Requête | L'index composite sert-il ? | Pourquoi |
|---|---|---|
| `WHERE adherent_id = 12` | oui | `adherent_id` est la première colonne de l'index (préfixe gauche). |
| `WHERE date_emprunt >= '2025-01-01'` | non | `date_emprunt` est la 2e colonne : l'index est trié d'abord par `adherent_id`, impossible de chercher la plage sans lui. C'est `idx_emprunt_date` qui sert. |

## L'index couvrant (consigne 8)

- Mention présente dans le premier `Extra` : `Using index`
- Elle disparaît dans le second parce que : `exemplaire_id` n'est pas dans l'index. Pour chaque entrée trouvée, le serveur doit aller lire la ligne complète dans l'index cluster (clé primaire) au lieu de répondre depuis l'index seul.

## La requête réécrite (consigne 9)

```sql
-- version d'origine
SELECT COUNT(*) FROM emprunt WHERE YEAR(date_emprunt) = 2024;
-- type : index   key : idx_emprunt_date   rows : 199 875   (parcours complet de l'index)

-- version réécrite
SELECT COUNT(*) FROM emprunt
 WHERE date_emprunt >= '2024-01-01' AND date_emprunt < '2025-01-01';

-- type : range   key : idx_emprunt_adherent_date (skip scan)   rows : 22 203 (estimation)
```

Les deux renvoient bien le même nombre : `43015`

`YEAR(date_emprunt)` cache la colonne derrière une fonction : l'optimiseur ne peut pas chercher une plage dans l'index et le parcourt en entier. La version réécrite compare la colonne nue, l'accès redevient un `range`.

## Le prix des index (consigne 10)

| | `donnees_mo` | `index_mo` |
|---|---|---|
| avant | 8.52 | 11.03 |
| après | 8.52 | 18.06 |

Conclusion : les données ne bougent pas, mais les index passent de 11 à 18 Mo (+64 %), plus que la table elle-même. Chaque index accélère les lectures ciblées mais se paie en disque et en écriture : chaque `INSERT`/`UPDATE` sur `emprunt` doit aussi mettre à jour tous les index. On ne garde que ceux qu'une requête fréquente justifie.

## Bonus

- Consigne 11 — l'index qu'on ne peut pas supprimer : erreur obtenue `ERROR 1553 (HY000): Cannot drop index 'idx_emprunt_adherent_date': needed in a foreign key constraint`. InnoDB exige un index dont le préfixe gauche est la colonne d'une clé étrangère. Le composite a remplacé l'index automatique de la FK sur `adherent_id`.
- Consigne 12 — `EXPLAIN` sur `v_retard` : tables visitées, index utilisés. la vue est fusionnée (algorithme MERGE) : `v_retard` n'apparaît pas, le plan montre `emprunt` (`ref` sur `idx_emprunt_retour_reel`, 30 lignes), puis `adherent`, `exemplaire` et `ouvrage` en `eq_ref` sur leur `PRIMARY`.
