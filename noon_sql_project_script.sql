-- Top 3 outlets by cuisine type without using limit and top funcion

with cte as (
  select cuisine, restaurant_id, count(*) as no_of_orders
  from orders
  group by cuisine, restaurant_id)

select * from (  
  select *,
    row_number() over(partition by cuisine order by no_of_orders desc) as rn
    from cte )
where rn<=3;