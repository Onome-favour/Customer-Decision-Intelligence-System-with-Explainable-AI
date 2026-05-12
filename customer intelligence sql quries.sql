SELECT * FROM customer_rfm LIMIT 10;

SELECT * FROM customer_rfm LIMIT 10;SELECT segment, COUNT(*) AS total_customers
FROM customer_rfm
GROUP BY segment
ORDER BY total_customers DESC;

SELECT segment, SUM(monetary) AS total_revenue
FROM customer_rfm
GROUP BY segment
ORDER BY total_revenue DESC;

SELECT *
FROM customer_rfm
WHERE segment = 'Best Customers'
ORDER BY monetary DESC;

SELECT *
FROM customer_rfm
WHERE segment = 'At Risk';

SELECT cluster, 
       AVG(monetary) AS avg_spending,
       AVG(frequency) AS avg_orders,
       AVG(recency) AS avg_recency
FROM customer_rfm
GROUP BY cluster;



