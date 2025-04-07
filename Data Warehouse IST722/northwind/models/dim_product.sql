with stg_products as (
    select * from {{ source('northwind','Products')}}
),
stg_categories as (
    select * from {{ source('northwind','Categories')}}
)
select  {{ dbt_utils.generate_surrogate_key(['stg_products.productid']) }} as productkey, 
    stg_products.productid,stg_products.productname,stg_products.supplierid as supplierkey,
    stg_categories.categoryname,stg_categories.description as categorydescription
from stg_products join stg_categories on stg_products.categoryid=stg_categories.categoryid