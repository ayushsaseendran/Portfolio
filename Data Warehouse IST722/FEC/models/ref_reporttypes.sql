-- sta_report_types.sql
WITH report_types_data AS (
    SELECT
        ROW_NUMBER() OVER (ORDER BY REPORTTYPECODE) AS report_type_key,
        REPORTTYPECODE,
        REPORTTYPENAME,
        REPORTTYPEDESC
    FROM {{ source('STAGED', 'STA_REPORT_TYPES') }}
)

SELECT
    report_type_key,
    REPORTTYPECODE,
    REPORTTYPENAME,
    REPORTTYPEDESC
FROM report_types_data