-- models/dim_contributor.sql
with
    contributor_data as (
        select distinct
            name as contributor_name,
            city,
            state,
            zip_code,
            employer,
            occupation,
            transaction_tp as transaction_type,
            transaction_amt as transaction_amount,
            tran_id as transaction_id,
            sub_id as sub_id  -- Adding SUB_ID column
        from {{ source("STAGED", "STA_INDIV") }}
        where
            name is not null
            and city is not null
            and state is not null
            and zip_code is not null
            -- Assuming you might also want to filter out null transactions, if not
            -- remove this line
            and transaction_tp is not null
            and transaction_amt is not null
            and tran_id is not null
    )

select
    row_number() over (
        order by contributor_name, city, state, zip_code
    ) as contributor_key,
    contributor_name,
    city,
    state,
    zip_code,
    employer,
    occupation,
    transaction_type,
    transaction_amount,
    transaction_id,
    sub_id  -- Adding sub_id column
from contributor_data
