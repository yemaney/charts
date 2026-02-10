
  
  create view "test_project"."main"."stg_payments__dbt_tmp" as (
    select
    payment_id,
    order_id,
    payment_date,
    payment_method,
    amount
from "test_project"."main"."raw_payments"
  );
