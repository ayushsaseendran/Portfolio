-- models/dim_payee.sql

WITH payee_data AS (
  SELECT
    NAME AS payee_name,
    CITY AS payee_city,
    STATE AS payee_state,
    ZIP_CODE AS payee_zip_code,
    SUB_ID as payee_sub_id
  FROM {{ source('STAGED', 'STA_OPERATING_EXPENDITURES') }}
)

SELECT
  ROW_NUMBER() OVER (ORDER BY payee_name, payee_city, payee_state, payee_zip_code) AS payee_key,
  payee_name,
  payee_city,
  payee_state,
  payee_zip_code,
  payee_sub_id
FROM payee_data