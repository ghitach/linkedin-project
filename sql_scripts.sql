/******************************************************************************************
PROJET : Analyse des Offres d'Emploi LinkedIn sur Snowflake
******************************************************************************************/

/***********************************************
ÉTAPE 1️ : Création de la base et du schéma
***********************************************/
-- Création de la base de données et du schéma
CREATE OR REPLACE DATABASE linkedin;
USE DATABASE linkedin;
CREATE OR REPLACE SCHEMA public;

/***********************************************
ÉTAPE 2️ : Création du stage S3
***********************************************/
-- Création du stage vers le bucket S3
CREATE OR REPLACE STAGE linkedin_stage
URL = 's3://snowflake-lab-bucket/';


/***********************************************
ÉTAPE 3️ : Définition des formats de fichiers
***********************************************/
-- Format CSV
CREATE OR REPLACE FILE FORMAT csv_format
TYPE = 'CSV'
FIELD_OPTIONALLY_ENCLOSED_BY = '"'
SKIP_HEADER = 1;

-- Format JSON
CREATE OR REPLACE FILE FORMAT json_format
TYPE = 'JSON';


/***********************************************
ÉTAPE 4️ : Création des tables de données RAW
***********************************************/
-- Tables des offres d'emploi (colonnes nommées)
CREATE OR REPLACE TABLE job_postings_raw (
    job_id STRING,
    company_name STRING,
    title STRING,
    description STRING,
    max_salary FLOAT,
    pay_period STRING,
    formatted_work_type STRING,
    location STRING,
    applies INT,
    original_listed_time STRING,
    remote_allowed BOOLEAN,
    views INT,
    job_posting_url STRING,
    application_url STRING,
    application_type STRING,
    expiry STRING,
    closed_time STRING,
    formatted_experience_level STRING,
    skills_desc STRING,
    listed_time STRING,
    posting_domain STRING,
    sponsored BOOLEAN,
    work_type STRING,
    currency STRING,
    compensation_type STRING
);

-- Autres tables CSV
CREATE OR REPLACE TABLE benefits (
    job_id STRING,
    inferred BOOLEAN,
    type STRING
);

CREATE OR REPLACE TABLE employee_counts (
    company_id STRING,
    employee_count INT,
    follower_count INT,
    time_recorded STRING
);

-- Tables JSON
CREATE OR REPLACE TABLE companies_json (data VARIANT);
CREATE OR REPLACE TABLE company_industries_json (data VARIANT);
CREATE OR REPLACE TABLE company_specialities_json (data VARIANT);
CREATE OR REPLACE TABLE job_industries_json (data VARIANT);


/***********************************************
ÉTAPE 5️ : Chargement des fichiers depuis S3
***********************************************/
-- Correction temporaire (27 colonnes anonymes)
CREATE OR REPLACE TABLE job_postings_raw (
    col1 STRING,
    col2 STRING,
    col3 STRING,
    col4 STRING,
    col5 STRING,
    col6 STRING,
    col7 STRING,
    col8 STRING,
    col9 STRING,
    col10 STRING,
    col11 STRING,
    col12 STRING,
    col13 STRING,
    col14 STRING,
    col15 STRING,
    col16 STRING,
    col17 STRING,
    col18 STRING,
    col19 STRING,
    col20 STRING,
    col21 STRING,
    col22 STRING,
    col23 STRING,
    col24 STRING,
    col25 STRING,
    col26 STRING,
    col27 STRING
);

COPY INTO job_postings_raw
FROM @linkedin_stage/job_postings.csv
FILE_FORMAT = (FORMAT_NAME = csv_format);

COPY INTO benefits
FROM @linkedin_stage/benefits.csv
FILE_FORMAT = (FORMAT_NAME = csv_format);

COPY INTO employee_counts
FROM @linkedin_stage/employee_counts.csv
FILE_FORMAT = (FORMAT_NAME = csv_format);

COPY INTO companies_json
FROM @linkedin_stage/companies.json
FILE_FORMAT = (FORMAT_NAME = json_format);

COPY INTO company_industries_json
FROM @linkedin_stage/company_industries.json
FILE_FORMAT = (FORMAT_NAME = json_format);

COPY INTO company_specialities_json
FROM @linkedin_stage/company_specialities.json
FILE_FORMAT = (FORMAT_NAME = json_format);

COPY INTO job_industries_json
FROM @linkedin_stage/job_industries.json
FILE_FORMAT = (FORMAT_NAME = json_format);


/***********************************************
ÉTAPE 6️ : Extraction des données JSON vers tables propres
***********************************************/
CREATE OR REPLACE TABLE companies AS
SELECT
    value:company_id::STRING AS company_id,
    value:name::STRING AS name,
    value:description::STRING AS description,
    value:company_size::STRING AS company_size,
    value:state::STRING AS state,
    value:country::STRING AS country,
    value:city::STRING AS city,
    value:zip_code::STRING AS zip_code,
    value:address::STRING AS address,
    value:url::STRING AS url
FROM companies_json,
LATERAL FLATTEN(input => data);

CREATE OR REPLACE TABLE company_industries AS
SELECT
    value:company_id::STRING AS company_id,
    value:industry::STRING AS industry
FROM company_industries_json,
LATERAL FLATTEN(input => data);

CREATE OR REPLACE TABLE company_specialities AS
SELECT
    value:company_id::STRING AS company_id,
    value:speciality::STRING AS speciality
FROM company_specialities_json,
LATERAL FLATTEN(input => data);

CREATE OR REPLACE TABLE job_industries AS
SELECT
    value:job_id::STRING AS job_id,
    value:industry_id::STRING AS industry_id
FROM job_industries_json,
LATERAL FLATTEN(input => data);


/***********************************************
ÉTAPE 7️ : Nettoyage et jointures
***********************************************/
-- Nettoyage noms entreprises dans job_postings_raw
CREATE OR REPLACE TABLE job_postings_cleaned AS
SELECT *,
  REPLACE(REPLACE(REPLACE(LOWER(TRIM(col2)), '.', ''), ',', ''), ' inc', '') AS cleaned_company_name
FROM job_postings_raw
WHERE col2 IS NOT NULL;

-- Nettoyage dans companies
CREATE OR REPLACE TABLE companies_cleaned AS
SELECT *,
  REPLACE(REPLACE(REPLACE(LOWER(TRIM(name)), '.', ''), ',', ''), ' inc', '') AS cleaned_name
FROM companies;

-- Jointure entre offres et entreprises
CREATE OR REPLACE TABLE job_postings AS
SELECT
    jp.*,
    c.company_id
FROM job_postings_cleaned jp
LEFT JOIN companies_cleaned c
    ON jp.cleaned_company_name = c.cleaned_name;

-- Mapping manuel colonnes
ALTER TABLE job_postings RENAME COLUMN col1 TO job_id;
ALTER TABLE job_postings RENAME COLUMN col2 TO company_name;
ALTER TABLE job_postings RENAME COLUMN col3 TO title;
ALTER TABLE job_postings RENAME COLUMN col4 TO description;
ALTER TABLE job_postings RENAME COLUMN col5 TO max_salary;
ALTER TABLE job_postings RENAME COLUMN col9 TO work_type;
ALTER TABLE job_postings RENAME COLUMN col10 TO location;

-- Mapping manuel entreprise
CREATE OR REPLACE TABLE company_mapping_manual AS
SELECT
    '1089558.0' AS job_company_id, 'IBM' AS company_name UNION ALL
SELECT
    '96654609.0', 'GE Healthcare' UNION ALL
SELECT
    '3894635.0', 'Oracle' UNION ALL
SELECT
    '18995316.0', 'Hewlett Packard Enterprise' UNION ALL
SELECT
    '89350959.0', 'Cisco';

-- Jointure avec mapping manuel
CREATE OR REPLACE TABLE job_postings_cleaned AS
SELECT
    jp.*,
    cm.company_name
FROM job_postings_raw jp
LEFT JOIN company_mapping_manual cm
    ON jp.col2 = cm.job_company_id;

/***********************************************
ÉTAPE 8️ : Analyses et Reporting
***********************************************/

-- Top 10 titres de postes par industrie
WITH ranked_titles AS (
    SELECT
        ji.industry_id,
        TRIM(REPLACE(REPLACE(LOWER(jp.title), '[', ''), ']', '')) AS clean_title,
        COUNT(*) AS num_postings,
        ROW_NUMBER() OVER (
            PARTITION BY ji.industry_id
            ORDER BY COUNT(*) DESC
        ) AS rank_in_industry
    FROM job_postings jp
    JOIN job_industries ji
        ON jp.job_id = ji.job_id
    GROUP BY ji.industry_id, clean_title
)
SELECT
    industry_id,
    clean_title,
    num_postings
FROM ranked_titles
WHERE rank_in_industry <= 10
ORDER BY industry_id, num_postings DESC;

-- Top 10 des postes les mieux rémunérés par industrie
WITH ranked_salaries AS (
    SELECT
        ji.industry_id,
        jp.title AS job_title,
        MAX(jp.max_salary) AS max_salary,
        ROW_NUMBER() OVER (
            PARTITION BY ji.industry_id
            ORDER BY MAX(jp.max_salary) DESC
        ) AS rank
    FROM job_postings jp
    JOIN job_industries ji ON jp.job_id = ji.job_id
    WHERE jp.max_salary IS NOT NULL
    GROUP BY ji.industry_id, jp.title
)
SELECT
    industry_id, job_title, max_salary
FROM ranked_salaries
WHERE rank <= 10
ORDER BY industry_id, rank;

-- Répartition des offres par taille d’entreprise
SELECT
    CASE c.company_size
        WHEN '0' THEN 'Très petite'
        WHEN '1' THEN 'Petite'
        WHEN '2' THEN 'Moyenne'
        WHEN '3' THEN 'Grande'
        WHEN '4' THEN 'Très grande'
        WHEN '5' THEN 'Entreprise nationale'
        WHEN '6' THEN 'Entreprise internationale'
        WHEN '7' THEN 'Multinationale'
        ELSE 'Inconnue'
    END AS company_size_label,
    COUNT(*) AS num_jobs
FROM companies c
JOIN employee_counts ec ON c.company_id = ec.company_id
GROUP BY company_size_label
ORDER BY num_jobs DESC;


-- Répartition des offres par secteur d’activité
SELECT
    ci.industry,
    COUNT(*) AS num_jobs
FROM job_postings_cleaned jp
JOIN companies c
    ON jp.company_name = c.name
JOIN company_industries ci
    ON c.company_id = ci.company_id
GROUP BY ci.industry
ORDER BY num_jobs DESC
LIMIT 10;


-- Répartition par type d’emploi
SELECT
    jp.work_type,
    COUNT(*) AS num_jobs
FROM job_postings jp
GROUP BY jp.work_type
ORDER BY num_jobs DESC;

