
  
  create view "test_project"."main"."stg_customers__dbt_tmp" as (
    select
    customer_id,
    customer_name as name,
    customer_email as email
from "test_project"."main"."raw_customers"
  );
