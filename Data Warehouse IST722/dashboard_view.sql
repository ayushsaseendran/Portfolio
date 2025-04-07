-- models/individual_contributions.sql
{{ config(materialized="table", schema="DBT_AYUSHSASEENDRAN_FEC") }}

select
    ic.contribution_key,
    ic.candidate_key,
    ic.contributor_key,
    ic.report_type_key,
    ic.transaction_type_key,
    ic.contribution_amount_usd,
    ic.transaction_id,
    dc.committee_id,
    dc.party_affiliation as committee_party_affiliation,
    dc.type_code as committee_type_code,
    dc.designation_code as committee_designation_code,
    dc.filing_frequency_code as committee_filing_frequency_code,
    dc.organization_type_code as committee_organization_type_code,
    dc.committee_name,
    dc.treasurer_name as committee_treasurer_name,
    dca.candidate_id,
    dca.principal_cmte_id as candidate_principal_cmte_id,
    dca.party_code as candidate_party_code,
    dca.office_code as candidate_office_code,
    dca.election_year as candidate_election_year,
    dca.office_state_code as candidate_office_state_code,
    dca.district_number as candidate_district_number,
    dca.incumbent_code as candidate_incumbent_code,
    dca.status_code as candidate_status_code,
    dca.candidate_name,
    dca.street_address1 as candidate_street_address1,
    dca.street_address2 as candidate_street_address2,
    dca.city as candidate_city,
    dca.state_code as candidate_state_code,
    dca.zip_code as candidate_zip_code,
    dco.contributor_name,
    dco.city as contributor_city,
    dco.state as contributor_state_code,
    dco.zip_code as contributor_zip_code,
    dco.employer as contributor_employer,
    dco.occupation as contributor_occupation,
    rt.reporttypecode,
    rt.reporttypename,
    rt.reporttypedesc,
    tt.transaction_type,
    tt.transaction_type_desc as transaction_type_description,
    ds.state_name as contributor_state_name
from {{ ref("fact_individual_contributions") }} ic
left join {{ ref("dim_committie") }} dc on ic.committee_key = dc.committee_key
left join {{ ref("dim_candidate") }} dca on ic.candidate_key = dca.candidate_key
left join {{ ref("dim_contributors") }} dco on ic.contributor_key = dco.contributor_key
left join {{ ref("ref_reporttypes") }} rt on ic.report_type_key = rt.report_type_key
left join
    {{ ref("dim_transactiontypes") }} tt
    on ic.transaction_type_key = tt.transaction_type_key
left join {{ ref("dim_state") }} ds on dco.state = ds.state_code
