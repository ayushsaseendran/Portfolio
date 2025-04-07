-- ref_zipcode.sql
WITH source_data AS (
  SELECT
    ZIPCODE,
    CITY,
    STATE,
    LATITUDE,
    LONGITUDE
  FROM {{ source('STAGED', 'STA_ZIPCODES') }}
)

SELECT
  *
FROM source_data
