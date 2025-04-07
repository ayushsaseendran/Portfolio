-- models/dim_expense_purpose.sql
with
    purpose_data as (
        select distinct purpose as expense_purpose
        from {{ source("STAGED", "STA_OPERATING_EXPENDITURES") }}
        where purpose is not null
    )

select
    row_number() over (order by expense_purpose) as expense_purpose_key, expense_purpose
from purpose_data
