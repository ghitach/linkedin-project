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
Bar Chart permettant de visualiser les titres de postes les plus publiés dans chaque secteur.
<img width="1916" height="923" alt="image" src="https://github.com/user-attachments/assets/da190569-99e0-42e5-8090-7b21bd75bea1" />
<br>
<br>

- **Top 10 des postes les mieux rémunérés par industrie** <br>
Bar Chart affichant les postes offrant les salaires maximums les plus élevés par industrie.
<img width="1918" height="921" alt="image" src="https://github.com/user-attachments/assets/e7cf91c3-625d-487d-98fc-fd85d158a703" />
<br>
<br>

- **Répartition des offres par taille d’entreprise**  
Bar Chart montrant la part des offres selon la taille des entreprises.
<img width="1917" height="926" alt="image" src="https://github.com/user-attachments/assets/ae72e88a-3c40-4f2c-b095-cdd65286f3e9" />
<br>
<br>

- **Répartition des offres par secteur d’activité**
<br>Bar Chart montrant la répartition des offres par secteur d’activité.
<img width="1913" height="923" alt="image" src="https://github.com/user-attachments/assets/ef25b886-0825-48c9-9290-6c6e8ff08fcc" />
<br>
<br>

- **Répartition des offres par type d’emploi** 
<br>Bar Chart montrant la répartition selon le type de contrat (temps plein, partiel, stage…).
<img width="1917" height="922" alt="image" src="https://github.com/user-attachments/assets/3db1bded-6c42-464d-add5-8b0f7df2b2cc" />
<br>


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
Linkedin-project/<br>
│<br>
├── sql_scripts.sql # Scripts SQL complets, commentés et organisés par étapes<br>
│<br>
├── streamlit_scripts.sql # Scripts Streamlit complets, avec explications des visualisations<br>
│<br>
├── README.md # Documentation complète du projet (ce fichier)<br>

