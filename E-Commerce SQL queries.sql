#1) Weekday Vs Weekend (order_purchase_timestamp) Payment Statistics 
SELECT 
    kpil.day_end,
    CONCAT(ROUND((kpil.total_payment / (SELECT SUM(payment_value) FROM olist_order_payments_dataset)) * 100, 2), '%') AS percentage_payment_values
FROM
    (SELECT 
        ord.day_end, 
        SUM(pmt.payment_value) AS total_payment
     FROM 
        olist_order_payments_dataset AS pmt
     JOIN
        (SELECT DISTINCT 
            order_id,
            CASE
                WHEN WEEKDAY(order_purchase_timestamp) IN (5, 6) THEN 'Weekend'
                ELSE 'Weekday'
            END AS day_end 
         FROM olist_orders_dataset) AS ord
     ON ord.order_id = pmt.order_id
     GROUP BY ord.day_end) AS kpil;


#2)Number of Orders with review score 5 and payment type as credit card. 

SELECT 
    COUNT(pmt.order_id) AS Total_Orders
FROM 
    olist_order_payments_dataset pmt
INNER JOIN 
    olist_order_reviews_dataset rev ON pmt.order_id = rev.order_id
WHERE 
    rev.review_score = 5
    AND pmt.payment_type = 'credit_card';
    
#3)Average number of days taken for order_delivered_customer_date for pet_shop
SELECT 
    prod.product_category_name, 
    round(avg(DATEDIFF(ord.order_delivered_customer_date, ord.order_purchase_timestamp)),0) AS Avg_delivery_days
FROM 
    olist_orders_dataset ord
JOIN 
    (SELECT 
        oi.order_id, 
        p.product_category_name 
     FROM 
        olist_products_dataset p
     JOIN 
        olist_order_items_dataset oi 
     ON p.product_id = oi.product_id
    ) AS prod
ON ord.order_id = prod.order_id
WHERE 
    prod.product_category_name = 'pet_shop'
GROUP BY 
    prod.product_category_name;

#4)Average price and payment values from customers of sao paulo city 

WITH orderItemsAvg AS (
    SELECT 
        ROUND(AVG(item.price), 2) AS avg_order_item_price
    FROM 
        olist_order_items_dataset item
    JOIN 
        olist_orders_dataset ord ON item.order_id = ord.order_id
    JOIN 
        olist_customers_dataset cust ON ord.customer_id = cust.customer_id
    WHERE 
        cust.customer_city = 'Sao Paulo'
)
SELECT 
    (SELECT avg_order_item_price FROM orderItemsAvg) AS avg_order_item_price, 
    ROUND(AVG(pmt.payment_value), 2) AS avg_payment_value
FROM 
    olist_order_payments_dataset pmt
JOIN 
    olist_orders_dataset ord ON pmt.order_id = ord.order_id
JOIN 
    olist_customers_dataset cust ON ord.customer_id = cust.customer_id
WHERE 
    cust.customer_city = 'Sao Paulo';

# 5)Relationship between shipping days (order_delivered_customer_date - order_purchase_timestamp) Vs review scores. 

SELECT 
    rew.review_score,
    ROUND(AVG(DATEDIFF(ord.order_delivered_customer_date, ord.order_purchase_timestamp)), 0) AS "Avg_shipping_days"
FROM 
    olist_orders_dataset AS ord
JOIN 
    olist_order_reviews_dataset AS rew ON rew.order_id = ord.order_id
GROUP BY 
    rew.review_score
ORDER BY 
    rew.review_score;

