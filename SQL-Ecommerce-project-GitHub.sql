CREATE DATABASE ecommerce_project;

CREATE TABLE customers_data (
customer_id INT PRIMARY KEY,
customer_name VARCHAR (100),
city VARCHAR(50)
);

CREATE TABLE orders_data(
order_id INT PRIMARY KEY,
customer_id INT,
order_date DATE,
amount NUMERIC (10,2),
FOREIGN KEY (customer_id) REFERENCES customers_data(customer_id)
);

INSERT INTO customers_data VALUES(
1, 'Amit', 'Delhi' ),
(2, 'Priya', 'Mumbai'),
(3, 'Rahul', 'Bangalore'),
(4, 'Sneha', 'Kolkata');


INSERT INTO orders_data VALUES (
101, 1, '2024-01-10', 500),
(102, 2, '2024-01-12', 700),
(103, 1, '2024-02-05', 300),
(104, 3, '2024-02-10', 900),
(105, 4, '2024-03-01', 400),
(106, 2, '2024-03-05', 650);

SELECT * FROM customers_data;
SELECT * FROM orders_data;

--============================
-- TOTAL REVENUE ANALYSIS
--============================
SELECT SUM(amount) AS total_revenue
FROM orders_data;

--============================
-- MONTHLY SALE ANALYSIS
--============================
SELECT 
DATE_TRUNC ('month', order_date) AS month,
SUM(amount) AS revenue
FROM orders_data
GROUP BY month
ORDER BY month;

--============================
-- TOP CUSTOMERS
--============================
SELECT 
    c.customer_id,
    c.customer_name, 
    SUM(o.amount) AS total_spent
FROM orders_data o
JOIN customers_data c
ON o.customer_id = c.customer_id
GROUP BY c.customer_id, c.customer_name
ORDER BY total_spent DESC;

--============================
-- RUNNING TOTAL ANALYSIS
--============================
SELECT *, 
SUM(amount) OVER(ORDER BY order_date) AS Running_Total
FROM orders_data;

--============================
-- REPEAT CUSTOMERS
--============================
SELECT customer_id, COUNT(order_id) AS total_orders
FROM orders_data
GROUP BY customer_id
HAVING COUNT(order_id) > 1;

--=============================
--CUSTOMERS WHO NEVER ORDERED
--=============================
SELECT c.customer_id, c.customer_name
FROM customers_data c
LEFT JOIN orders_data o
ON c.customer_id = o.customer_id
WHERE o.customer_id IS NULL;

--=============================
-- TOTAL ORDER PER CUSTOMER
--=============================
SELECT customer_id,
COUNT(*) AS total_orders
FROM orders_data
GROUP BY customer_id;

--=============================
-- AVERAGE ORDER VALUE
--=============================
SELECT ROUND(AVG(amount), 2) AS avg_order_value
FROM orders_data;

--=============================
-- HIGHEST SINGLE ORDER
--=============================
SELECT * FROM 
orders_data
ORDER BY amount DESC
LIMIT 1;

--=============================
--SALES BY CITY
--=============================
SELECT c.city, SUM(o.amount) AS total_sales
FROM customers_data c
JOIN orders_data o
ON c.customer_id = o.customer_id
GROUP BY c.city
ORDER BY total_sales DESC;

--==============================
--ORDERS PER MONTH
--==============================
SELECT 
DATE_TRUNC('month', order_date) AS month,
COUNT(order_id) AS total_orders
FROM orders_data
GROUP BY month
ORDER BY month;

--==============================
-- MONTH WITH HIGHEST SALE
--==============================
SELECT 
DATE_TRUNC ('month', order_date) AS month,
SUM(amount) AS revenue
FROM orders_data
GROUP BY month
ORDER BY revenue DESC
LIMIT 1;

--==============================
-- TOP TWO CUSTOMERS
--==============================
SELECT * FROM (SELECT customer_id, SUM(amount) AS total_spent,
DENSE_RANK() OVER(ORDER BY SUM(amount)DESC) AS rnk
FROM orders_data
GROUP BY customer_id)t
WHERE rnk <=2;

--===============================
-- FIRST ORDER OF EACH CUSTOMER
--===============================
SELECT * FROM (SELECT *, 
ROW_NUMBER() OVER(PARTITION BY customer_id ORDER BY order_date) AS rn
FROM orders_data
)t
WHERE rn=1;

--===============================
-- CUSTOMER LIFETIME VALUE
--===============================
SELECT customer_id, 
SUM(amount) AS lifetime_value
FROM orders_data
GROUP BY customer_id
ORDER BY lifetime_value DESC;

--==============================
-- DAYS BETWEEN ORDERS
--==============================
SELECT customer_id, order_date,
order_date - LAG(order_date) OVER(PARTITION BY customer_id ORDER BY order_date) AS days_between_orders
FROM orders_data;

--=============================
--TOP CUSTOMER PER CITY
--=============================
SELECT * FROM (SELECT c.customer_id, c.customer_name, c.city,
SUM(o.amount) AS total_spent, 
DENSE_RANK() OVER(PARTITION BY c.city ORDER BY SUM(o.amount) DESC) AS rnk
FROM customers_data c
JOIN orders_data o
ON c.customer_id = o.customer_id
GROUP BY c.city, c.customer_name, c.customer_id)t
WHERE rnk =1;

--------------------------------