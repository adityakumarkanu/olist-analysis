DROP TABLE IF EXISTS olist.olist_order_reviews_dataset;

CREATE TABLE olist.olist_order_reviews_dataset (
    review_id TEXT,
    order_id TEXT,
    review_score INT,
    review_comment_title TEXT,
    review_comment_message TEXT,
    review_creation_date TIMESTAMP,
    review_answer_timestamp TIMESTAMP
);

COPY olist.olist_order_reviews_dataset
FROM '/tmp/reviews.csv'
WITH (FORMAT csv, HEADER true);

SELECT COUNT(*) FROM olist.olist_order_reviews_dataset;
SELECT 'orders' t, COUNT(*) FROM olist.olist_orders_dataset
UNION ALL SELECT 'products', COUNT(*) FROM olist.olist_products_dataset
UNION ALL SELECT 'sellers', COUNT(*) FROM olist.olist_sellers_dataset
UNION ALL SELECT 'translation', COUNT(*) FROM olist.product_category_name_translation;

select column_name, data_type
from information_schema.columns 
where table_schema = 'olist' and table_name ='olist_orders_dataset'

ALTER TABLE olist.olist_orders_dataset
 ALTER COLUMN order_purchase_timestamp TYPE TIMESTAMP USING order_purchase_timestamp::timestamp,
 ALTER COLUMN order_approved_at TYPE TIMESTAMP USING order_approved_at::timestamp,
 ALTER COLUMN order_delivered_carrier_date TYPE TIMESTAMP USING order_delivered_carrier_date::timestamp,
 ALTER COLUMN order_delivered_customer_date TYPE TIMESTAMP USING order_delivered_customer_date::timestamp,
 ALTER COLUMN order_estimated_delivery_date TYPE TIMESTAMP USING order_estimated_delivery_date::timestamp;


SELECT order_status, COUNT(*) AS total_orders
FROM olist.olist_orders_dataset
GROUP BY order_status
ORDER BY total_orders DESC;