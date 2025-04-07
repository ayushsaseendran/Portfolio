-- models/dim_candidate.sql

WITH source_candidates AS (
  SELECT
    cn.CAND_ID,
    cn.CAND_NAME,
    cn.CAND_PTY_AFFILIATION,
    cn.CAND_ELECTION_YR,
    cn.CAND_OFFICE_ST,
    cn.CAND_OFFICE,
    cn.CAND_OFFICE_DISTRICT,
    cn.CAND_ICI,
    cn.CAND_STATUS,
    cn.CAND_PCC,
    cn.CAND_ST1,
    cn.CAND_ST2,
    cn.CAND_CITY,
    cn.CAND_ST,
    cn.CAND_ZIP,
    cm.CMTE_ID AS PRINCIPAL_CMTE_ID
  FROM {{ source('STAGED', 'STA_CN') }} cn
  LEFT JOIN {{ source('STAGED', 'STA_CM') }} cm ON cn.CAND_PCC = cm.CMTE_ID
),

candidate_keys AS (
  SELECT
    ROW_NUMBER() OVER (ORDER BY CAND_ID) AS candidate_key,
    CAND_ID
  FROM source_candidates
)

SELECT
  ck.candidate_key,
  sc.CAND_ID AS candidate_id,
  sc.PRINCIPAL_CMTE_ID,
  sc.CAND_PTY_AFFILIATION AS party_code,
  sc.CAND_OFFICE AS office_code,
  sc.CAND_ELECTION_YR::INT AS election_year,
  sc.CAND_OFFICE_ST AS office_state_code,
  sc.CAND_OFFICE_DISTRICT AS district_number,
  sc.CAND_ICI AS incumbent_code,
  sc.CAND_STATUS AS status_code,
  sc.CAND_NAME AS candidate_name,
  sc.CAND_ST1 AS street_address1,
  sc.CAND_ST2 AS street_address2,
  sc.CAND_CITY AS city,
  sc.CAND_ST AS state_code,
  sc.CAND_ZIP AS zip_code
FROM source_candidates sc
JOIN candidate_keys ck ON sc.CAND_ID = ck.CAND_ID
