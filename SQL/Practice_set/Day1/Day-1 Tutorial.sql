-- 1. show all data from the orders table
SELECT order_id FROM sample_dataset;

-- show only product and quantity
SELECT product, quantity
FROM sample_dataset;

-- show all orders where product = 'T-shirt'
SELECT product
FROM sample_dataset
WHERE product = 'T-shirt';

-- Show orders with quantity greater than 2
SELECT quantity FROM sample_dataset
WHERE quantity > 2;

-- Show the most expensive order
SELECT order_id, customer_name, product, price
FROM sample_dataset
WHERE price = (SELECT MAX(price) FROM sample_dataset);

-- Total number of orders
SELECT COUNT(*) AS total_orders FROM sample_dataset;

-- total revenue
SELECT SUM(price * quantity) AS total_revenue
FROM sample_dataset;

-- top selling 3 products
SELECT 
	product, 
    SUM(quantity) As total_sold
FROM sample_dataset
GROUP BY product
ORDER BY total_sold DESC
LIMIT 3;
