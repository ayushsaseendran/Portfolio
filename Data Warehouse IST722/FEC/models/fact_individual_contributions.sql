-- models/fact_individual_contributions.sql
with
    fact_data as (
        select
            row_number() over (order by sta.tran_id) as contribution_key,  -- Added ORDER BY clause
            cmte.committee_key as committee_key,
            cand.candidate_key as candidate_key,
            contr.contributor_key as contributor_key,
            rpt.report_type_key as report_type_key,
            trn.transaction_type_key as transaction_type_key,
            sta.transaction_amt as contribution_amount_usd,  -- Corrected to use sta instead of trn for transaction_amt
            sta.tran_id as transaction_id
        from {{ source("STAGED", "STA_INDIV") }} sta
         join {{ ref("dim_committie") }} cmte on sta.cmte_id = cmte.committee_id
         join {{ ref("dim_candidate") }} cand on cmte.committee_id = cand.PRINCIPAL_CMTE_ID
         join
            {{ ref("dim_contributors") }} contr
            on sta.sub_id = contr.sub_id
            and sta.zip_code = contr.zip_code
         join
            {{ ref("dim_transactiontypes") }} trn
            on sta.transaction_tp = trn.transaction_type
         join {{ ref("ref_reporttypes") }} rpt on sta.rpt_tp = rpt.reporttypecode
    )

select
    contribution_key,
    committee_key,
    candidate_key,
    contributor_key,
    report_type_key,
    transaction_type_key,
    contribution_amount_usd,
    transaction_id
from fact_data
