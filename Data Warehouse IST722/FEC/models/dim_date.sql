SELECT
    DATEKEY::INT AS datekey,
    DATEVALUE AS date,
    YEAR AS year,
    MONTH AS month,
    QUARTER AS quarter,
    DAYOFMONTH AS day,
    DAYOFWEEK AS dayofweek,
    WEEK AS weekofyear,
    DAYOFYEAR AS dayofyear,
    CASE 
        WHEN QUARTER = 1 THEN 'Q1'
        WHEN QUARTER = 2 THEN 'Q2'
        WHEN QUARTER = 3 THEN 'Q3'
        WHEN QUARTER = 4 THEN 'Q4'
        ELSE NULL 
    END AS quartername,
    MONTHNAME AS monthname,
    -- Assuming WEEKDAYSHORT contains the full name of the weekday, otherwise adjust accordingly
    WEEKDAYSHORT AS dayname,
    -- Here we determine if the day is a weekday; adjust the logic to match how ISWEEKDAY is defined (e.g., 1 for weekdays, 0 for weekends)
    CASE 
        WHEN ISWEEKDAY = 1 THEN 'Yes' 
        WHEN ISWEEKDAY = 0 THEN 'No' 
        ELSE NULL 
    END AS weekday
FROM {{ source('STAGED', 'STA_DATES') }}
