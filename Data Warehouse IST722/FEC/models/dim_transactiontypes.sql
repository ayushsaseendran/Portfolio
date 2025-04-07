-- models/dim_transactiontype.sql
with
    transactiontype_data as (
        select distinct
            transaction_type as transaction_type,
            transaction_type_description as transaction_type_desc
        from {{ source("STAGED", "STA_TRANSACTIONTYPE") }}
        where transaction_type is not null
    )

select
    row_number() over (order by transaction_type) as transaction_type_key,
    transaction_type,
    transaction_type_desc
from transactiontype_data
