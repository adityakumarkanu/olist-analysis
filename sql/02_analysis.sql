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

select
	coalesce(t.product_category_name_english, p.product_category_name) as category,
	count(distinct oi.order_id) as orders,
	round(sum(oi.price)::numeric, 2) as revenue
from olist.olist_order_items_dataset oi
join olist.olist_products_dataset p on oi.product_id = p.product_id 
left join olist.product_category_name_translation t
on p.product_category_name = t.product_category_name 
group by 1
order by revenue desc 
limit 10;

SELECT
  COUNT(*) AS delivered_orders,
  SUM(CASE WHEN order_delivered_customer_date::timestamp > order_estimated_delivery_date::timestamp
           THEN 1 ELSE 0 END) AS late_orders,
  ROUND(100.0 * SUM(CASE WHEN order_delivered_customer_date::timestamp > order_estimated_delivery_date::timestamp
           THEN 1 ELSE 0 END) / COUNT(*), 2) AS late_pct
FROM olist.olist_orders_dataset
WHERE order_status = 'delivered'
  AND order_delivered_customer_date IS NOT NULL;