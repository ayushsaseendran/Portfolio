-- models/dim_committees.sql

WITH committee_keys AS (
  SELECT
    ROW_NUMBER() OVER (ORDER BY CMTE_ID) AS committee_key,
    CMTE_ID
  FROM {{ source('STAGED', 'STA_CM') }}
),
committee_data AS (
  SELECT
    ck.committee_key,
    sc.CMTE_ID AS committee_id,
    sc.CMTE_NM AS committee_name,
    sc.TRES_NM AS treasurer_name,
    sc.STREET_1 AS street_address1,
    sc.STREET_2 AS street_address2,
    sc.CITY,
    sc.STATE AS state_code,
    sc.ZIP AS zip_code,
    sc.CMTE_DSGN AS designation_code,
    sc.CMTE_TP AS type_code,
    sc.CMTE_PTY_AFFILIATION AS party_affiliation,
    sc.CMTE_FILING_FREQ AS filing_frequency_code,
    sc.ORG_TP AS organization_type_code,
    sc.CONNECTED_ORG_NM AS organization_name,
    -- Join with STA_CN to get CandidateId if CMTE_ID represents the candidate's committee
    cn.CAND_ID AS candidate_id
  FROM committee_keys ck
  LEFT JOIN {{ source('STAGED', 'STA_CM') }} sc ON ck.CMTE_ID = sc.CMTE_ID
  LEFT JOIN {{ source('STAGED', 'STA_CN') }} cn ON sc.CMTE_ID = cn.CAND_ID -- Adjust this join condition based on your data model's logic
)

SELECT
  committee_key,
  committee_id,
  candidate_id,
  party_affiliation,
  type_code,
  designation_code,
  filing_frequency_code,
  organization_type_code,
  committee_name,
  treasurer_name,
  street_address1,
  street_address2,
  CITY,
  state_code,
  zip_code
FROM committee_data
