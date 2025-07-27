
SELECT *
from supplychaindataset;

 -- 🚚 Delivery & Logistics Analysis
-- Which orders were delivered late?

SELECT order_id,
		order_item_id,
		product_name,
		Product_price,
		(days_for_shipping_real - days_for_shipment_scheduled) total_days_late
FROM supplychaindataset
WHERE delivery_status = 'Late delivery';

-- What’s the average delivery time per Shipping Mode and Order Region?

SELECT order_region,
		shipping_mode,
		Round(AVG(days_for_shipping_real),2) as avg_devlivery_time_in_days
FROM supplychaindataset
GROUP BY 1,2

-- Which states have the most late deliveries?

SELECT order_state,
		(days_for_shipping_real - days_for_shipment_scheduled) total_days_late
FROM supplychaindataset
GROUP BY 1,2
ORDER BY 2 DESC
LIMIT 1;

--How does actual shipping time compare to scheduled time?

SELECT order_id,
		days_for_shipping_real AS actual_day,
		days_for_shipment_scheduled AS scheduled_day,
		(days_for_shipping_real- days_for_shipment_scheduled) AS delay_in_days,
		CASE 
		when days_for_shipping_real > days_for_shipment_scheduled THEN 'late'
		WHEN days_for_shipping_real < days_for_shipment_scheduled THEN 'Early'
		ELSE 'On_Time'
		END AS delivary_status
FROM supplychaindataset;


--B. 💸 Sales & Profit Analysis
--Total sales and profit by Customer Country, Region, Market

SELECT customer_country,
		order_region,
		market,
		Round(sum(sales)) as total_sales,
		Round(sum(order_profit_per_order)) as Profit
FROM supplychaindataset
GROUP BY 1,2,3;

--Top 10 most profitable products and categories

SELECT category_name,
		product_name,
		Round(SUM(order_profit_per_order)) AS profit
FROM supplychaindataset
GROUP BY 1,2
ORDER BY 3 DESC
LIMIT 10;

--Which departments generated the most sales?

SELECT department_name,
		Sum(sales) as total_sales
FROM supplychaindataset
GROUP BY 1
ORDER BY 2 desc
limit 1;

--C. 👥 Customer Behavior
--Which customers placed the most orders?

SELECT customer_id,
		customer_fname,
		customer_lname,
		COUNT(order_id) AS Total_orders
FROM supplychaindataset
GROUP BY 1,2,3
ORDER BY 4 DESC;

--What is the average number of orders per Customer Segment?

SELECT 
    Customer_Segment,
    COUNT(DISTINCT Order_Id) / COUNT(DISTINCT Customer_Id) AS avg_orders_per_customer
FROM supplychaindataset
GROUP BY 1;

--List all customers with more than 5 orders and their total spend.

SELECT customer_id,
		customer_fname,
		customer_lname,
		COUNT(order_id) as total_orders,
		Sum(sales_per_customer) AS customer_total_spend
FROM supplychaindataset
GROUP BY 1,2,3
HAVING COUNT(order_id) >5
ORDER BY 4 DESC;

--Which cities/states have the most high-value customers?

WITH customer_sales AS
(SELECT customer_id,
		customer_state,
		customer_city,
		Sum(sales) AS total_sales
FROM supplychaindataset
GROUP BY 1,2,3)
SELECT 
    Customer_City,
    Customer_State,
    COUNT(*) AS high_value_customer_count
FROM customer_sales
WHERE total_sales > 5000
GROUP BY 1,2
ORDER BY high_value_customer_count DESC
LIMIT 10;


--D. 📦 Product & Category Insights
--What’s the average profit margin per category?

SELECT category_name,
		ROUND(AVG((order_profit_per_order / sales) * 100)) AS AVG_profit_margin
FROM supplychaindataset
GROUP BY 1;

--Rank products by sales within each category

SELECT category_name,
		product_name,
		Round(sum(sales)) as sales,
		Rank()OVER(PARTITION BY category_name ORDER BY sum(sales) DESC )
FROM supplychaindataset
GROUP BY 1,2;

--Find underperforming products (low sales + low profit)

SELECT product_name,
		category_name,
		Round(SUM(sales)) as total_sales,
		Round(SUM(order_profit_per_order)) as Profit
FROM supplychaindataset
GROUP BY 1,2
ORDER BY 2,3 ASC
LIMIT 15;


--E. 📅 Time Series Analysis
--Total sales per month — identify seasonal trends

SELECT TO_CHAR(order_date_dateorders, 'mm-YYYY') AS date,
		Round(SUM(Sales)) AS total_sales
FROM supplychaindataset
GROUP BY 1
ORDER BY 1 ASC;

--Average order value by hour of day

SELECT EXTRACT(HOUR FROM order_date_dateorders::timestamp),
		(sum(sales)/ count(order_id)) AS order_value
FROM supplychaindataset
GROUP BY 1;

--Has delivery performance improved over time?

SELECT
    DATE_TRUNC('month', order_date_DateOrders) AS order_month,
    ROUND(AVG(Days_for_shipping_real - Days_for_shipment_scheduled),2) AS avg_delivery_delay
FROM supplychaindataset
GROUP BY order_month
ORDER BY order_month;



