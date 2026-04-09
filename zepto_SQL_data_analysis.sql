CREATE DATABASE zepto_project;
USE zepto_project;

drop table zepto;

/* Create Table */
CREATE TABLE zepto (
    Category VARCHAR(100),
    name VARCHAR(255),
    mrp DECIMAL(10,2),
    discountPercent DECIMAL(5,2),
    availableQuantity INT,
    discountedSellingPrice DECIMAL(10,2),
    weightInGms INT,
    outOfStock varchar(10),
    quantity INT
);

-- data exploration

-- Count of rows
SELECT COUNT(*) FROM zepto;

-- Display first 10 rows 
SELECT * FROM zepto LIMIT 10;

-- null values
SELECT * FROM zepto
WHERE category IS NULL 
OR 
name IS NULL
OR 
mrp IS NULL
OR 
discountPercent IS NULL
OR
discountedSellingPrice IS NULL
OR
weightInGms IS NULL
OR
availableQuantity IS NULL
OR
outOfStock IS NULL
OR
quantity IS NULL;

-- Different Product Categories
SELECT DISTINCT category
FROM zepto
ORDER BY category;

-- products in stock vs out of stock
SELECT outOfStock, COUNT(*) AS product_count
FROM zepto 
GROUP BY outOfStock;

-- product names present multiple times
SELECT name, count(*) as frequency
FROM zepto
GROUP BY name
HAVING count(*) > 1
ORDER BY frequency DESC;

-- data cleaning

-- product with price = 0
SELECT * FROM zepto 
WHERE mrp = 0 OR discountedSellingPrice = 0;

SET SQL_SAFE_UPDATES = 0;

DELETE FROM zepto WHERE mrp = 0;

-- convert paise to rupees
UPDATE zepto 
SET mrp = mrp / 100.0,
discountedSellingPrice = discountedSellingPrice / 100.0;

SET SQL_SAFE_UPDATES = 0;

SELECT mrp,discountedSellingPrice FROM zepto;

-- data analysis 

-- Q1. Find the top 10 best-value products based on the discount percentage.
SELECT DISTINCT name, mrp, discountPercent
FROM zepto 
ORDER BY discountPercent DESC
LIMIT 10;

-- Q2.What are the Products with High MRP but Out of Stock
SELECT name, mrp 
FROM zepto 
WHERE outOfStock = 'True' and mrp > 300
ORDER BY mrp DESC;

-- Q3.Calculate Estimated Revenue for each category
SELECT Category,
SUM(discountedSellingPrice * availableQuantity) AS total_revenue
FROM zepto
GROUP BY Category
ORDER BY total_revenue DESC;

-- Q4. Find all products where MRP is greater than ₹500 and discount is less than 10%.
select name, mrp, discountPercent
FROM zepto 
WHERE mrp > 500 AND discountPercent < 10
ORDER BY mrp DESC, discountPercent DESC;

-- Q5. Identify the top 5 categories offering the highest average discount percentage.
SELECT category,
ROUND(AVG(discountPercent),2) AS avg_discount
FROM zepto
GROUP BY category
ORDER BY avg_discount DESC
LIMIT 5;

-- Q6. Find the price per gram for products above 100g and sort by best value.
SELECT DISTINCT name, weightInGms, discountedSellingPrice,
ROUND(discountedSellingPrice/weightInGms,2) AS price_per_gram
FROM zepto
WHERE weightInGms >= 100
ORDER BY price_per_gram;

-- Q7.Group the products into categories like Low, Medium, Bulk.
SELECT DISTINCT name, weightInGms,
CASE WHEN weightInGms < 1000 THEN 'Low'
	 WHEN weightInGms < 5000 THEN 'MEDIUM'
     else 'Bulk'
     END AS weight_category
FROM zepto;

-- Q8.What is the Total Inventory Weight Per Category 
SELECT category,
SUM(weightInGms * availableQuantity) AS total_weight
FROM zepto
GROUP BY category
ORDER BY total_weight;

-- Q9. Rank products based on highest discount percentage
SELECT name, discountPercent,
DENSE_RANK() OVER(ORDER BY discountPercent DESC) AS discount_rank
FROM zepto;

-- Q10. Find the highest priced product in each category
SELECT category, name, mrp
FROM (
	SELECT category, name, mrp,
    DENSE_RANK() OVER(PARTITION BY category ORDER BY mrp DESC) AS rnk
    FROM zepto
) ranked_products
WHERE rnk = 1;




