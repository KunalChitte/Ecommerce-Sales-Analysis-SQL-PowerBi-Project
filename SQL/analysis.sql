-- Calculate total revenue
SELECT 
    SUM(p.price * oi.quantity * (1 - oi.discount)) AS total_revenue
FROM order_items oi
JOIN products p ON oi.product_id = p.product_id;

-- Top 10 products by revenue
SELECT TOP 10
    p.product_name,
    SUM(p.price * oi.quantity * (1 - oi.discount)) AS revenue
FROM order_items oi
JOIN products p ON oi.product_id = p.product_id
GROUP BY p.product_name
ORDER BY revenue DESC;

-- Monthly revenue trend
SELECT 
    o.order_month, 
    SUM(p.price * oi.quantity * (1 - oi.discount)) AS revenue
FROM orders o
JOIN order_items oi ON o.order_id = oi.order_id
JOIN products p ON oi.product_id = p.product_id
GROUP BY o.order_month
ORDER BY o.order_month;

-- Top 10 customers by revenue
SELECT TOP 10
    c.customer_name,
    SUM(p.price * oi.quantity * (1 - oi.discount)) AS total_spent
FROM customers c
JOIN orders o ON c.customer_id = o.customer_id
JOIN order_items oi ON o.order_id = oi.order_id
JOIN products p ON oi.product_id = p.product_id
GROUP BY c.customer_name
ORDER BY total_spent DESC;

-- Return count by reason
SELECT 
    return_reason,
    COUNT(*) AS total_returns
FROM returns
GROUP BY return_reason
ORDER BY total_returns DESC;

-- Returns by product category
SELECT 
    p.category,
    COUNT(r.order_id) AS return_count
FROM returns r
JOIN orders o ON r.order_id = o.order_id
JOIN order_items oi ON o.order_id = oi.order_id
JOIN products p ON oi.product_id = p.product_id
GROUP BY p.category
ORDER BY return_count DESC;

-- Rank customers by spending
SELECT 
    c.customer_name,
    SUM(p.price * oi.quantity * (1 - oi.discount)) AS total_spent,
    
    RANK() OVER (
        ORDER BY SUM(p.price * oi.quantity * (1 - oi.discount)) DESC
    ) AS customer_rank

FROM customers c
JOIN orders o ON c.customer_id = o.customer_id
JOIN order_items oi ON o.order_id = oi.order_id
JOIN products p ON oi.product_id = p.product_id

GROUP BY c.customer_name;

-- RFM Analysis
WITH customer_data AS (
    SELECT 
        c.customer_id,
        c.customer_name,
        MAX(o.order_date) AS last_order_date,
        COUNT(DISTINCT o.order_id) AS frequency,
        SUM(p.price * oi.quantity * (1 - oi.discount)) AS monetary
    FROM customers c
    JOIN orders o ON c.customer_id = o.customer_id
    JOIN order_items oi ON o.order_id = oi.order_id
    JOIN products p ON oi.product_id = p.product_id
    GROUP BY c.customer_id, c.customer_name
)

SELECT 
    *,
    DATEDIFF(DAY, last_order_date, (SELECT MAX(order_date) FROM orders)) AS recency
    
FROM customer_data;

-- RFM Segmentation
WITH customer_data AS (
    SELECT 
        c.customer_id,
        c.customer_name,
        MAX(o.order_date) AS last_order_date,
        COUNT(DISTINCT o.order_id) AS frequency,
        SUM(p.price * oi.quantity * (1 - oi.discount)) AS monetary
    FROM customers c
    JOIN orders o ON c.customer_id = o.customer_id
    JOIN order_items oi ON o.order_id = oi.order_id
    JOIN products p ON oi.product_id = p.product_id
    GROUP BY c.customer_id, c.customer_name
),

rfm AS (
    SELECT *,
        DATEDIFF(DAY, last_order_date, (SELECT MAX(order_date) FROM orders)) AS recency
    FROM customer_data
)

SELECT 
    customer_id,
    customer_name,
    recency,
    frequency,
    monetary,

    -- Segmentation
    CASE 
        WHEN monetary > 50000 AND frequency > 10 THEN 'VIP'
        WHEN monetary > 20000 THEN 'Loyal'
        WHEN frequency > 5 THEN 'Regular'
        ELSE 'Low Value'
    END AS customer_segment

FROM rfm;

-- Cohort Analysis (Monthly Retention)
WITH first_order AS (
    SELECT 
        customer_id,
        MIN(order_date) AS first_order_date
    FROM orders
    GROUP BY customer_id
),

cohort_data AS (
    SELECT 
        o.customer_id,
        FORMAT(f.first_order_date, 'yyyy-MM') AS cohort_month,
        FORMAT(o.order_date, 'yyyy-MM') AS order_month
    FROM orders o
    JOIN first_order f ON o.customer_id = f.customer_id
)

SELECT 
    cohort_month,
    order_month,
    COUNT(DISTINCT customer_id) AS customers
FROM cohort_data
GROUP BY cohort_month, order_month
ORDER BY cohort_month, order_month;