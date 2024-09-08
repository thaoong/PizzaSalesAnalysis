# Pizza Sales Analysis using SQL
This project aims to analyze sales situation of a pizza store using SQL, find the key insights based on the analysis results and help business make data-driven decisions that can potentially increase the store's revenue.
## About the dataset
For this project, the data source is Pizza place sales data from Kaggle ([link](https://www.kaggle.com/datasets/mysarahmadbhat/pizza-place-sales)) which contains four csv files: 
* order_details.csv
* orders.csv
* pizza_types.csv
* pizzas.csv,

These csv files were imported into Microsoft SQL Server with the schema below:

![image](https://github.com/user-attachments/assets/fe72505b-515b-4f75-a0f0-9857745f983b)
## Define business tasks
1. Calculate total number of orders placed, total number of pizza types, total number of pizza types by each category?                 
2. Calculate total revenue of the store?
3. Identify the most common pizza size orderd?
4. Identify the most common pizza category orderd?
5. How many orders and number of pizzas do we have each day?
6. Calculate the average number of pizzas ordered per day?
7. Distribution of order by weekday?
8. Distribution of order by hour of the day?
9. List top 5 pizzas by quantity?
10. List top 5 pizzas by revenue?
11. Are there any pizzas we should take off the menu, or any promotions we could leverage?
12. Calculate the percentage distribution of each pizza category to total revenue?
## Analysis
**1. There are 21350 orders had been placed, 32 pizza types with 4 category**
* **_Total number of orders placed_**:
```
SELECT COUNT(*) AS total_orders
FROM orders
```
* _**Total number of pizza types**_:
```
SELECT COUNT(*) AS total_pizza_types
FROM pizza_types
```
* _**Total number of pizza types by each category**_:
```
SELECT category, COUNT(*) AS total_pizza_types
FROM pizza_types
GROUP BY category
```
![image](https://github.com/user-attachments/assets/d57c3361-e3c0-4d72-b573-82ef00870002)

**2. The total revenue of the store is 817860.05 USD**
```
SELECT ROUND(SUM(o.quantity*p.price),2) as revenue
FROM order_details o
JOIN pizzas p
ON o.pizza_id = p.pizza_id
```
**3. Based on the number of pizzas of each size, size L is the most common pizza size orderd**
```
SELECT size, SUM(quantity) AS number_of_pizzas
FROM order_details o
JOIN pizzas p
ON o.pizza_id = p.pizza_id
GROUP BY size
```
![image](https://github.com/user-attachments/assets/9ae60506-4c4c-428f-8e26-a124f1757033)

**4. Based on the number of pizzas of each pizza category, Classic category is the most common pizza category orderd**
```
SELECT category, SUM(quantity) AS number_of_pizzas
FROM order_details o
JOIN pizzas p
ON o.pizza_id = p.pizza_id
JOIN pizza_types pt
ON p.pizza_type_id = pt.pizza_type_id
GROUP BY category
ORDER BY number_of_pizzas DESC
```
![image](https://github.com/user-attachments/assets/5997b837-37cc-431d-b4a9-e9e6399553b5)

**5. The dataset contains sales information for 358 days of 2015 with the number of orders and pizzas queried through the following query**
```
SELECT date, COUNT(o.order_id) AS number_of_orders, SUM(od.quantity) AS number_of_pizzas
FROM orders o
JOIN order_details od
ON o.order_id = od.order_id
GROUP BY date
ORDER BY date
```
![image](https://github.com/user-attachments/assets/84582da5-0e03-49f0-9974-49f050636219)

**6. The average number of pizzas ordered per day is 138**
```
SELECT AVG(number_of_pizzas) AS average_pizza_ordered
FROM (
    	SELECT SUM(od.quantity) AS number_of_pizzas
    	FROM orders o
    	JOIN order_details od
    	ON o.order_id = od.order_id
    	GROUP BY date
) AS order_quantity
```

**7. Distribution of order by weekday**
```
SELECT DATEPART(WEEKDAY, date) AS weekday, COUNT(order_id) AS number_of_orders
FROM orders
GROUP BY DATEPART(WEEKDAY, date)
ORDER BY number_of_orders DESC
```
![image](https://github.com/user-attachments/assets/87579e95-3532-4646-bc76-219ea8ba5a0a)

**8. Distribution of order by hour of the day**
```
SELECT DATEPART(HOUR, time) AS hours, COUNT(order_id) AS number_of_orders
FROM orders
GROUP BY DATEPART(HOUR, time)
ORDER BY number_of_orders DESC
```
![image](https://github.com/user-attachments/assets/4b5681c8-ed7f-4721-b094-77766bc70e16)

**9. Top 5 pizzas by quantity**
```
SELECT TOP 5 PT.name, SUM(od.quantity) AS quantity
FROM order_details OD
JOIN pizzas P
ON OD.pizza_id = P.pizza_id
JOIN pizza_types PT
ON PT.pizza_type_id = P.pizza_type_id
GROUP BY PT.name
ORDER BY quantity DESC
```
![image](https://github.com/user-attachments/assets/801f1ab5-dbf3-4ba8-9f8f-b59901366952)

**10. Top 5 pizzas by revenue**
```
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
```
![image](https://github.com/user-attachments/assets/97568da8-0ed6-4617-af05-c2c50a21413f)

**11. There are 5 pizza we could consider take off the menu, have the lowest contribution to revenue**
```
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
```
![image](https://github.com/user-attachments/assets/74452d45-c13c-49a0-a76c-eca4d49cab5b)

**12. Percentage distribution of each pizza category to total revenue**
```
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
```
![image](https://github.com/user-attachments/assets/e355ad29-5068-4d60-b466-5c2e1097875f)
## Conclusion
* In 2015, the pizza store had **21350** orders and gained revenue **817860.05$** with the most common pizza size orderd was **size L**.
* On an average the store have **136** customers each day. Busiest day is **Friday** and the customer flow is minimum on **Sunday**. Considering this it would be beneficial to allocate additional resources on these days accordingly. The busiest hours of a day are **12 noon and 6pm**.
* The categories have no huge difference in the number of pizzas sold and the contribution rate to revenue of each category is quite even. The difference between the category with the most and the least contribution is only **3%**.
* **Thai Chicken Pizza** is the best selling pizza as per revenue and **Classic Deluxe Pizza** is the best selling pizza as per quantity.
* **Brie Carrer Pizza** is the least selling pizza as per revenue, only contribute **1.4%** to revenue.
