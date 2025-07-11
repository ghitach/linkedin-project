import streamlit as st
import pandas as pd

#  Titre principal
st.title(" Analyses Streamlit")

# 📡 Connexion à Snowflake
session = st.connection("snowflake")

#  Fonction pour charger les données depuis Snowflake
@st.cache_data
def load_data(query):
    return session.query(query)

#  Menu déroulant pour sélectionner la visualisation
visu = st.selectbox(" Choisissez une visualisation :", [
    "Top 10 titres publiés par industrie",
    "Top 10 postes les mieux rémunérés par industrie",
    "Répartition par taille d’entreprise",
    "Répartition par secteur d’activité",
    "Répartition par type d’emploi"
])

# ----------------------------------------------------
#  Visualisation 1 : Top 10 titres de postes par industrie
# ----------------------------------------------------
if visu == "Top 10 titres publiés par industrie":
    st.header(" Top 10 titres de postes publiés par industrie")
    query_titles = """
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
    """
    df_titles = load_data(query_titles)
    selected_industry = st.selectbox("Sélectionnez une industrie :", df_titles['INDUSTRY_ID'].unique())
    filtered_titles = df_titles[df_titles['INDUSTRY_ID'] == selected_industry]
    st.bar_chart(filtered_titles.set_index('CLEAN_TITLE')['NUM_POSTINGS'])

# ----------------------------------------------------
#  Visualisation 2 : Top 10 postes les mieux rémunérés par industrie
# ----------------------------------------------------
elif visu == "Top 10 postes les mieux rémunérés par industrie":
    st.header(" Top 10 postes les mieux rémunérés par industrie")
    query_salaries = """
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
    """
    df_salaries = load_data(query_salaries)
    selected_industry_salary = st.selectbox("Sélectionnez une industrie :", df_salaries['INDUSTRY_ID'].unique())
    filtered_salaries = df_salaries[df_salaries['INDUSTRY_ID'] == selected_industry_salary]
    st.bar_chart(filtered_salaries.set_index('JOB_TITLE')['MAX_SALARY'])

# ----------------------------------------------------
# 🏢 Visualisation 3 : Répartition par taille d’entreprise
# ----------------------------------------------------
elif visu == "Répartition par taille d’entreprise":
    st.header(" Répartition par taille d’entreprise")
    query_size = """
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
    """
    df_size = load_data(query_size)
    st.bar_chart(df_size.set_index('COMPANY_SIZE_LABEL')['NUM_JOBS'])

# ----------------------------------------------------
# 🏭 Visualisation 4 : Répartition par secteur d’activité
# ----------------------------------------------------
elif visu == "Répartition par secteur d’activité":
    st.header("🏭 Répartition par secteur d’activité")
    query_sector = """
        SELECT
            ci.industry,
            COUNT(*) AS num_jobs
        FROM job_postings_cleaned jp
        JOIN companies c ON jp.company_name = c.name
        JOIN company_industries ci ON c.company_id = ci.company_id
        GROUP BY ci.industry
        ORDER BY num_jobs DESC
        LIMIT 10;
    """
    df_sector = load_data(query_sector)
    st.bar_chart(df_sector.set_index('INDUSTRY')['NUM_JOBS'])

# ----------------------------------------------------
#  Visualisation 5 : Répartition par type d’emploi
# ----------------------------------------------------
elif visu == "Répartition par type d’emploi":
    st.header(" Répartition par type d’emploi")
    query_type = """
        SELECT
            jp.work_type,
            COUNT(*) AS num_jobs
        FROM job_postings jp
        GROUP BY jp.work_type
        ORDER BY num_jobs DESC;
    """
    df_type = load_data(query_type)
    st.bar_chart(df_type.set_index('WORK_TYPE')['NUM_JOBS'])
