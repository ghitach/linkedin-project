# 🧊 LinkedIn Job Market Analysis with Snowflake & Streamlit

## 📝 Description du projet

Projet d’analyse du marché de l’emploi à partir des données LinkedIn.  
L’objectif est de manipuler, transformer et analyser des données stockées dans un bucket S3 en utilisant **Snowflake** pour la gestion des données et **Streamlit** pour la visualisation directement dans Snowflake.

Ce projet couvre toutes les étapes : chargement des données, nettoyage, analyses et visualisations.

---

## 📄 Commandes SQL utilisées (avec explications)

L’ensemble des commandes SQL est regroupé dans le fichier [`sql_scripts.sql`](./sql_scripts.sql).

Les étapes couvertes :
- **Création de la base et du schéma**  
  Création de la base `linkedin` et du schéma `public`.

- **Création du stage externe**  
  Connexion au bucket S3 contenant les fichiers.

- **Définition des formats de fichiers**  
  Formats adaptés aux fichiers CSV et JSON fournis.

- **Création des tables**  
  Création des tables correspondant aux fichiers du projet (offres, entreprises, avantages, industries, etc.).

- **Chargement des données**  
  Utilisation de la commande `COPY INTO` pour importer les fichiers dans les tables.

- **Transformations et nettoyage**  
  Nettoyage des noms d'entreprises, extraction des colonnes JSON, jointures et renommage des colonnes.

- **Analyses** :
  - Top 10 des titres de postes les plus publiés par industrie.
  - Top 10 des postes les mieux rémunérés par industrie.
  - Répartition des offres par taille d’entreprise.
  - Répartition des offres par secteur d’activité.
  - Répartition des offres par type d’emploi.

Chaque requête est documentée directement dans le fichier SQL.

---

## 📊 Code Streamlit pour chaque visualisation (avec résultats obtenus)

Les scripts Streamlit utilisés dans Snowflake sont regroupés dans le fichier [`streamlit_scripts.sql`](./streamlit_scripts.sql).  
Chaque section correspond à une visualisation demandée, avec les explications et le résultat attendu.

### Visualisations incluses :
- **Top 10 des titres de postes les plus publiés par industrie**  
Bar Chart permettant de visualiser les titres de postes les plus fréquents dans chaque secteur.

- **Top 10 des postes les mieux rémunérés par industrie**  
Bar Chart affichant les postes offrant les salaires maximums les plus élevés par industrie.

- **Répartition des offres par taille d’entreprise**  
Diagramme circulaire ou en barres montrant la part des offres selon la taille des entreprises.

- **Répartition des offres par secteur d’activité**  
Bar Chart mettant en évidence les secteurs les plus représentés parmi les offres d’emploi.

- **Répartition des offres par type d’emploi**  
Bar Chart montrant la répartition selon le type de contrat (temps plein, partiel, stage…).

Chaque visualisation repose sur une requête SQL et les résultats sont commentés dans le fichier.

---

## 🚨 Problèmes rencontrés et solutions apportées

| Problème | Solution |
| -------- | -------- |
| Colonnes anonymes dans le fichier `job_postings.csv` | Utilisation de colonnes génériques (col1, col2…) avant renommage manuel après analyse. |
| Correspondances inexactes entre les noms d’entreprises | Nettoyage avancé des noms (suppression de termes comme "Inc", suppression de ponctuation, mise en minuscules) pour améliorer les jointures. |
| Certaines entreprises non retrouvées malgré le nettoyage | Mise en place d’une table de correspondance manuelle pour assurer une jointure complète. |

---

## ✅ Résumé

Ce projet propose une analyse complète des offres d’emploi LinkedIn, combinant :
- Snowflake pour la gestion, la transformation et l’analyse des données (CSV & JSON).
- Streamlit dans Snowflake pour la visualisation interactive des résultats.

Tous les scripts SQL et Streamlit sont commentés et organisés pour assurer une lecture claire et faciliter la reproduction des étapes.

---

## 📂 Structure du dépôt
LinkedIn_Job_Market_Analysis/<br>
│<br>
├── sql_scripts.sql # Scripts SQL complets, commentés et organisés par étapes<br>
│<br>
├── streamlit_scripts.sql # Scripts Streamlit complets, avec explications des visualisations<br>
│<br>
├── screenshots/ # Captures des résultats dans Snowflake Streamlit<br>
│<br>
├── README.md # Documentation complète du projet (ce fichier)<br>

