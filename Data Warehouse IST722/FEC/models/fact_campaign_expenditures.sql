-- models/fact_campaign_expenditure.sql

with expenditure_data as (
    select
        row_number() over (order by ope.TRAN_ID) as expenditurekey,
        date.datekey as datekey,
        state.state_key as statekey,
        cmte.committee_key as committeekey,
        payee.payee_key as payeekey,
        ope.TRANSACTION_AMT as amount
    from {{ source('STAGED', 'STA_OPERATING_EXPENDITURES') }} ope
     join {{ ref('dim_date') }} date on to_date(ope.TRANSACTION_DT, 'MM/DD/YYYY') = date.date
     join {{ ref('dim_state') }} state on ope.STATE = state.state_code
     join {{ ref('dim_committie') }} cmte on ope.CMTE_ID = cmte.committee_id
     join {{ ref('dim_payees') }} payee on ope.SUB_ID = payee.payee_sub_id
)

select
    expenditurekey,
    datekey,
    statekey,
    committeekey,
    payeekey,
    amount
from expenditure_data
