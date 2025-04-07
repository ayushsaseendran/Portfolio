with stg_orders as
(
    select
        OrderID,  
        {{ dbt_utils.generate_surrogate_key(['employeeid']) }} as employeekey, 
        {{ dbt_utils.generate_surrogate_key(['customerid']) }} as customerkey, 
        replace(to_date(orderdate)::varchar,'-','')::int as orderdatekey
        from {{source('northwind','Orders')}}
),
stg_order_details as
(
    select 
        orderid,
        Quantity,
        productkey,
        extendedpriceamount,discountamount,extendedpriceamount-discountamount as soldamount from(
    select 
        orderid,
        Quantity,
        productkey,
        extendedpriceamount, extendedpriceamount*Discount as discountamount from 
        (select orderid,Quantity, Quantity*UnitPrice as extendedpriceamount,Discount,{{ dbt_utils.generate_surrogate_key(['productid']) }} as productkey from {{source('northwind','Order_Details')}} group by orderid,productid,Quantity,UnitPrice,Discount))

)
select o.*,productkey,Quantity,extendedpriceamount,discountamount,soldamount from stg_orders o join stg_order_details od on o.orderid = od.orderid