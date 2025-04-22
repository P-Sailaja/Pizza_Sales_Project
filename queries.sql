create database Pizzahut_db;

create table orders(
order_id int not null,
order_date date not null,
order_time time not null,
primary key(order_id)
);

create table order_details (
order_details_id int not null,
order_id int not null,
pizza_id text not null,
quantity int not null,
primary key(order_details_id) );
---------------------------------- Easy Level ----------------------------------
-- Query 1. Retrieve the total number of orders placed.
SELECT 
    COUNT(order_id) AS Total_Orders
FROM
    orders;

-- Query 2. Calculate the total revenue generated from pizza sales.
SELECT 
    ROUND(SUM(order_details.quantity * pizzas.price),
            2) AS revenue
FROM
    order_details
        JOIN
    pizzas ON order_details.pizza_id = pizzas.pizza_id;
    
-- Query 3. Identify the highest-priced pizza.
SELECT 
    pizza_types.name, pizzas.price
FROM
    pizza_types
        JOIN
    pizzas ON pizza_types.pizza_type_id = pizzas.pizza_type_id
ORDER BY pizzas.price DESC
LIMIT 1;

-- Query 4. Identify the most common pizza size ordered.
SELECT 
    pizzas.size,
    COUNT(order_details.order_details_id) AS Total_count
FROM
    pizzas
        JOIN
    order_details ON pizzas.pizza_id = order_details.pizza_id
GROUP BY pizzas.size
ORDER BY Total_count DESC
LIMIT 1;

-- Query 5. List the top 5 most ordered pizza types along with their quantities.
SELECT 
    pizza_types.name, SUM(order_details.quantity) as quantity
FROM
    pizza_types
        JOIN
    pizzas ON pizza_types.pizza_type_id = pizzas.pizza_type_id
        JOIN
    order_details ON order_details.pizza_id = pizzas.pizza_id
GROUP BY pizza_types.name
ORDER BY quantity DESC
LIMIT 5;

-------------------------------- Intermediate Level -------------------------------------
-- Query 6. Join the necessary tables to find the total quantity of each pizza category ordered.
SELECT 
    pizza_types.category,
    SUM(order_details.quantity) AS quantity
FROM
    pizza_types
        JOIN
    pizzas ON pizza_types.pizza_type_id = pizzas.pizza_type_id
        JOIN
    order_details ON order_details.pizza_id = pizzas.pizza_id
GROUP BY pizza_types.category
ORDER BY quantity DESC;

-- Query 7. Determine the distribution of orders by hour of the day.
SELECT 
    HOUR(order_time) AS hour, COUNT(order_id) AS total_orders
FROM
    orders
GROUP BY hour;
 -- Query 8. Join relevant tables to find the category-wise distribution of pizzas.
SELECT 
    category, COUNT(name) AS distribution
FROM
    pizza_types
GROUP BY category;

-- Query 9. Group the orders by date and calculate the average number of pizzas ordered per day.
SELECT 
    ROUND(AVG(pizzas_ordered_per_day), 0)
FROM
    (SELECT 
        orders.order_date AS date,
            SUM(order_details.quantity) AS pizzas_ordered_per_day
    FROM
        orders
    JOIN order_details ON orders.order_id = order_details.order_id
    GROUP BY date) AS Total_orders;
    
-- Query 10. Determine the top 3 most ordered pizza types based on revenue.
SELECT 
    pizza_types.name AS name,
    SUM(order_details.quantity * pizzas.price) AS revenue
FROM
    pizza_types
        JOIN
    pizzas ON pizza_types.pizza_type_id = pizzas.pizza_type_id
        JOIN
    order_details ON order_details.pizza_id = pizzas.pizza_id
GROUP BY name
ORDER BY revenue DESC
LIMIT 3;

---------------------------------- Hard Level -------------------------------------
-- Query 11. Calculate the percentage contribution of each pizza type to total revenue.
SELECT 
    pizza_types.category AS category,
    ROUND(SUM(order_details.quantity * pizzas.price) / (SELECT 
                    ROUND(SUM(order_details.quantity * pizzas.price),
                                2)
                FROM
                    order_details
                        JOIN
                    pizzas ON order_details.pizza_id = pizzas.pizza_id) * 100,
            2) AS revenue
FROM
    pizza_types
        JOIN
    pizzas ON pizza_types.pizza_type_id = pizzas.pizza_type_id
        JOIN
    order_details ON order_details.pizza_id = pizzas.pizza_id
GROUP BY category;

-- Query 12. Analyze the cumulative revenue generated over time.
select date, sum(revenue) over(order by date) as cum_rev from
(select orders.order_date as date, sum(order_details.quantity* pizzas.price) as revenue from orders 
join order_details on orders.order_id = order_details.order_id join pizzas 
on pizzas.pizza_id = order_details.pizza_id group by date) as sales;

-- Query 13. Determine the top 3 most ordered pizza types based on revenue for each pizza category.
select category, name,revenue from
(select category, name, revenue, rank() over(partition by category order by revenue desc) as rn from
(select pizza_types.category as category, pizza_types.name as name, sum(order_details.quantity * pizzas.price) as revenue
from pizza_types join pizzas on pizza_types.pizza_type_id = pizzas.pizza_type_id join order_details
on order_details.pizza_id = pizzas.pizza_id group by category, name) as a) as b where rn <= 3;