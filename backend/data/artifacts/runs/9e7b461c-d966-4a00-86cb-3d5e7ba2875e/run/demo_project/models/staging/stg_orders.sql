
  
  create view "test_project"."main"."stg_orders__dbt_tmp" as (
    select
    order_id,
    customer_id,
    order_date,
    status,
    order_amount
from "test_project"."main"."raw_orders"
  );
