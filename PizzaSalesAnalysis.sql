-- 1. Total number of orders placed
SELECT COUNT(*) AS total_orders
FROM orders

-- Total number of pizza types
SELECT COUNT(*) AS total_pizza_types
FROM pizza_types

-- Total number of pizza types by each category
SELECT category, COUNT(*) AS total_pizza_types
FROM pizza_types
GROUP BY category

-- 2. Total revenue of the store
SELECT ROUND(SUM(o.quantity*p.price),2)
FROM order_details o
JOIN pizzas p
ON o.pizza_id = p.pizza_id

-- 3. Identify the most common pizza size orderd
SELECT size, SUM(quantity) AS number_of_pizzas
FROM order_details o
JOIN pizzas p
ON o.pizza_id = p.pizza_id
GROUP BY size

-- 4. Identify the most common pizza category orderd
SELECT size, SUM(quantity) AS number_of_pizzas
FROM order_details o
JOIN pizzas p
ON o.pizza_id = p.pizza_id
GROUP BY size

-- 5. How many orders and number of pizzas do we have each day? 
SELECT date, COUNT(o.order_id) AS number_of_orders, SUM(od.quantity) AS number_of_pizzas
FROM orders o
JOIN order_details od
ON o.order_id = od.order_id
GROUP BY date
ORDER BY date

-- 6. Calculate the average number of pizzas ordered per day
SELECT AVG(number_of_pizzas) AS average_pizza_ordered
FROM 
	(
	SELECT SUM(od.quantity) AS number_of_pizzas
	FROM orders o
	JOIN order_details od
	ON o.order_id = od.order_id
	GROUP BY date
	) AS order_quantity

-- 7. Distribution of order by weekday
SELECT DATEPART(WEEKDAY, date) AS weekday, COUNT(order_id) AS number_of_orders
FROM orders
GROUP BY DATEPART(WEEKDAY, date)
ORDER BY number_of_orders DESC

-- 8. Distribution of order by hour of the day
SELECT DATEPART(HOUR, time) AS hours, COUNT(order_id) AS number_of_orders
FROM orders
GROUP BY DATEPART(HOUR, time)
ORDER BY number_of_orders DESC

-- 9. Top 5 pizzas by quantity
SELECT TOP 5 PT.name, SUM(od.quantity) AS quantity
FROM order_details OD
JOIN pizzas P
ON OD.pizza_id = P.pizza_id
JOIN pizza_types PT
ON PT.pizza_type_id = P.pizza_type_id
GROUP BY PT.name
ORDER BY quantity DESC

-- 10. Top 5 pizzas by revenue
SELECT TOP 5 PT.name, 
	SUM(od.quantity*price) AS revenue,
	CONCAT(ROUND(
			SUM(od.quantity*price)
			/
			(SELECT SUM(o.quantity*p.price)
				FROM order_details o
				JOIN pizzas p
				ON o.pizza_id = p.pizza_id), 3)*100, '%') 
			AS revenue_percentage
FROM order_details OD
JOIN pizzas P
ON OD.pizza_id = P.pizza_id
JOIN pizza_types PT
ON PT.pizza_type_id = P.pizza_type_id
GROUP BY PT.name
ORDER BY revenue DESC

-- 11. Are there any pizzas we should take off the menu, or any promotions we could leverage?
SELECT TOP 5 PT.name, 
	ROUND(SUM(od.quantity*price),2) AS revenue,
	CONCAT(ROUND(
			SUM(od.quantity*price)
			/
			(SELECT SUM(o.quantity*p.price)
				FROM order_details o
				JOIN pizzas p
				ON o.pizza_id = p.pizza_id), 3)*100, '%') 
			AS revenue_percentage
FROM order_details OD
JOIN pizzas P
ON OD.pizza_id = P.pizza_id
JOIN pizza_types PT
ON PT.pizza_type_id = P.pizza_type_id
GROUP BY PT.name
ORDER BY revenue

-- 12. Calculate the percentage distribution of each pizza category to total revenue
SELECT PT.category, 
		CONCAT(ROUND(
			SUM(od.quantity*price)
			/
			(SELECT SUM(o.quantity*p.price)
				FROM order_details o
				JOIN pizzas p
				ON o.pizza_id = p.pizza_id), 3)*100, '%') 
			AS revenue_percentage
FROM order_details OD
JOIN pizzas P
ON OD.pizza_id = P.pizza_id
JOIN pizza_types PT
ON PT.pizza_type_id = P.pizza_type_id
GROUP BY PT.category
