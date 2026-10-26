drop table if exists zepto;

create table zepto(
sku_id SERIAL PRIMARY KEY,
category VARCHAR(120),
name VARCHAR(150) NOT NULL,
mrp NUMERIC(8,2),
discountpecent NUMERIC(5,2),
availablequantity INTEGER,
discounedSellingPrice NUMERIC(8,2),
weightingrams INTEGER,
outofstock BOOLEAN,
quantity INTEGER
);

--data exploration

--count of rows
SELECT COUNT(*) FROM zepto;

--sample data
SELECT * FROM zepto
LIMIT 10;

--null values
SELECT * FROM zepto
WHERE name IS NULL
OR
category IS NULL
OR
mrp IS NULL
OR
discountpecent IS NULL
OR
availablequantity IS NULL
OR 
discounedsellingprice IS NULL
OR
weightingrams IS NULL
OR
outofstock IS NULL
OR
quantity IS NULL;


---new qr
SELECT column_name
FROM information_schema.columns
WHERE table_name = 'zepto';

--renaming
ALTER TABLE public.zepto
RENAME COLUMN discountpecent TO "discountpercent";

--changename
ALTER TABLE public.zepto
RENAME COLUMN discounedsellingprice TO "discountsellingprice";

--null
SELECT * FROM zepto
WHERE name IS NULL
OR
category IS NULL
OR
mrp IS NULL
OR
discountpercent IS NULL
OR
availablequantity IS NULL
OR 
discountsellingprice IS NULL
OR
weightingrams IS NULL
OR
outofstock IS NULL
OR
quantity IS NULL;

--diff prod category
SELECT DISTINCT category
FROM zepto
ORDER BY category;

--outofstock
SELECT outofstock, COUNT(sku_id)
FROM zepto
GROUP BY outofstock;

--products present multiple times
SELECT name, COUNT(sku_id) as "Number of SKUs"
FROM zepto
GROUP BY name
HAVING COUNT (sku_id)>1
ORDER BY count (sku_id)DESC;

--data cleaning
--products with price as 0

SELECT * FROM zepto
WHERE mrp = 0 OR discountsellingprice = 0;

DELETE FROM zepto
WHERE mrp = 0;

--convert paisa into rup
UPDATE zepto
SET mrp = mrp/100.0,
discountsellingprice = discountsellingprice/100.0;

SELECT mrp,discountsellingprice FROM zepto;

--top 10 best value	products based on disc.
SELECT DISTINCT name, mrp, discountpercent
FROM zepto
ORDER BY discountpercent DESC
LIMIT 10;

--out of stock products with high rate
SELECT DISTINCT name,mrp
FROM zepto
WHERE outofstock = 'true'
ORDER BY mrp DESC
LIMIT 10;

--estimated revenue for each category
SELECT category,
SUM(discountsellingprice * availablequantity) AS total_revenue
FROM zepto
GROUP BY category
ORDER BY total_revenue;

--products with mrp > 500 and disc. is less than 10%
SELECT DISTINCT name,mrp,discountpercent
FROM zepto
WHERE mrp > 500 and discountpercent <10
ORDER BY mrp DESC,discountpercent DESC;

--TOP 5 categories with highest avg. disc. percent
SELECT category,
ROUND(AVG(discountpercent),2) AS avg_disc
FROM zepto
GROUP BY category
ORDER BY avg_disc DESC
LIMIT 5;

--number of categories available
SELECT COUNT(DISTINCT category)
FROM zepto;

--number of prods in each categ
SELECT category,
COUNT(category)
FROM zepto
GROUP BY category;

--find the price per gram for products > 100g and sort by best value 
SELECT DISTINCT name,weightingrams,discountsellingprice,
ROUND(discountsellingprice/weightingrams,2) AS price_per_gram
FROM zepto
WHERE weightingrams >= 100
ORDER BY price_per_gram;

--grp prods into categ as low,med,bulk
SELECT DISTINCT name,weightingrams,
CASE WHEN weightingrams < 1000 THEN 'Low'
    WHEN weightingrams < 5000 THEN 'Med'
    ELSE 'Bulk'
	END AS wc
FROM zepto;

--tot inventory weight per category
SELECT category,
SUM(weightingrams * availablequantity) AS total_weight
FROM zepto
GROUP BY category;
	