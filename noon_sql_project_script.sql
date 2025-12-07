-- Q. Top 3 outlets by cuisine type without using limit and top funcion

with cte as (
  select cuisine, restaurant_id, count(*) as no_of_orders
  from orders
  group by cuisine, restaurant_id)

select * from (  
  select *,
    row_number() over(partition by cuisine order by no_of_orders desc) as rn
    from cte )

where rn<=3;

-- Q. Daily new customer count from launch date (Number of new customers acquired everyday)

--Solution 1
select a.placed_at, count(a.customer_code) as uni_customer_count
from(
  select customer_code, placed_at,
      row_number() over (partition by customer_code order by placed_at asc) as customer_orders
  from orders) as a
where a.customer_orders = 1
group by a.placed_at;

-- Solution 2
with cte as (
	select customer_code, cast(min(placed_at) as date) as first_order_date
	from orders
	group by customer_code)
    
select first_order_date, count(*) as no_of_new customers
from cte
group by first_order_date
order by first_order_date;

-- Count of all the users who were acquired in Jan 2025 and only place one order in Jan and did not place any other order

select customer_code, count(*) as no_of_orders
from orders
where month(placed_at)=1 and year(placed_at)=2025 and
  customer_code not in (
		select distinct(customer_code
		from orders
		where not (month(placed_at)=1 and year(placed_at)=2025)
group by customer_code
having count(*)=1;

-- Q. List all the customers with no order in last 7 days but were acquired one month ago with their first order on promo

WITH CustomerSummary AS (
  SELECT
      customer_code,
      MIN(placed_at) AS first_order_date,  
      MAX(placed_at) AS latest_order_date  
  FROM orders
  GROUP BY customer_code
)
SELECT
    cs.*,
    o.promo_code_name AS first_order_promo
FROM CustomerSummary cs
INNER JOIN orders o
ON cs.customer_code = o.customer_code 
    AND cs.first_order_date = o.placed_at
WHERE
    cs.latest_order_date < DATEADD(day, -7, GETDATE())
    AND cs.first_order_date < DATEADD(month, -1, GETDATE()) 
    AND o.promo_code_name IS NOT NULL;

-- Q. A trigger query that will target customers after their every third order with a personalised communication

with cte as (
	select cutomer_code, placed_at,
      row_number() over (partition by customer_code order by placed_at asc) as rn
    from orders )
select * from cte
where cte.rn%3=0 and cast(placed_at as date) = cat(getdate() as date);

--Q.Customers who placed more than one order and all of their orders on promo only

-- This query first filters out all non-promoted orders, and then counts the remaining promoted orders. Hence, an incorrect approach.
select customer_code, count(*) as number_of_orders
from orders
where promo_code_name is not null
group by customer_code
having count(*) > 1;

-- Correct Solution
select customer_code, count(*) as number_of_orders, count(promo_code_name) as promo_orders
from orders
group by customer_code
having count(*) > 1 and count(*)=count(promo_code_name)





