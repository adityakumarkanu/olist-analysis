select column_name, data_type
from information_schema.columns
where table_schema ='olist' and table_name = 'olist_orders_dataset';

select 
	count(distinct o.order_id) as total_orders,
	round(sum(p.payment_value)::numeric, 2) as total_revenue,
	round((sum(p.payment_value) / count(distinct o.order_id))::numeric, 2) as avg_order_value
from olist.olist_orders_dataset o
join olist.olist_order_payments_dataset p on o.order_id = p.order_id
where o.order_status = 'delivered';

select 
	date_trunc('month', o.order_purchase_timestamp::timestamp) as month,
	count(distinct o.order_id) as orders,
	round(sum(p.payment_value)::numeric, 2) as revenue
from olist.olist_orders_dataset o
join olist.olist_order_payments_dataset p on o.order_id = p.order_id
where o.order_status = 'delivered'
group by 1
order by 1;

WITH monthly AS (
  SELECT
    DATE_TRUNC('month', o.order_purchase_timestamp::timestamp) AS month,
    COUNT(DISTINCT o.order_id) AS orders,
    ROUND(SUM(p.payment_value)::numeric, 2) AS revenue
  FROM olist.olist_orders_dataset o
  JOIN olist.olist_order_payments_dataset p ON o.order_id = p.order_id
  WHERE o.order_status = 'delivered'
  GROUP BY 1
)
SELECT
  month,
  orders,
  revenue,
  LAG(revenue) OVER (ORDER BY month) AS prev_month_revenue,
  ROUND(((revenue - LAG(revenue) OVER (ORDER BY month))
        / LAG(revenue) OVER (ORDER BY month) * 100)::numeric, 1) AS growth_pct
FROM monthly
ORDER BY month;