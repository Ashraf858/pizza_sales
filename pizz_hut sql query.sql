create database pizza_hut;

use pizza_hut;

create table orders(
order_id int not null,
order_date date not null,
order_time time not null,
primary key(order_id));

create table order_details(
order_details_id int not null,
order_id int not null,
pizza_id text not null,
quantity int not null,
primary key(order_details_id));

/*Basic:
Retrieve the total number of orders placed.
Calculate the total revenue generated from pizza sales.
Identify the highest-priced pizza.
Identify the most common pizza size ordered.
List the top 5 most ordered pizza types along with their quantities.


Intermediate:
Join the necessary tables to find the total quantity of each pizza category ordered.
Determine the distribution of orders by hour of the day.
Join relevant tables to find the category-wise distribution of pizzas.
Group the orders by date and calculate the average number of pizzas ordered per day.
Determine the top 3 most ordered pizza types based on revenue.

Advanced:
Calculate the percentage contribution of each pizza type to total revenue.
Analyze the cumulative revenue generated over time.
Determine the top 3 most ordered pizza types based on revenue for each pizza category.
*/

-- Retrieve the total number of orders placed.

select count(order_id) as Total_Orders from orders;

-- Calculate the total revenue generated from pizza sales.

SELECT 
    ROUND(SUM(order_details.quantity * pizzasp.price),
            2) AS Total_Revenue
FROM
    order_details
        JOIN
    pizzasp ON pizzasp.pizza_id = order_details.pizza_id;
    
    -- Identify the highest-priced pizza.

SELECT 
    pizza_types.name, pizzasp.price AS Highest_Price
FROM
    pizza_types
        INNER JOIN
    pizzasp ON pizza_types.pizza_type_id = pizzasp.pizza_type_id
ORDER BY pizzasp.price DESC
LIMIT 1
;

-- Identify the most common pizza size ordered.

SELECT 
    pizzasp.size AS Most_common_pizza_size,
    COUNT(order_details.order_details_id) AS order_count
FROM
    pizzasp
        INNER JOIN
    order_details ON pizzasp.pizza_id = order_details.pizza_id
GROUP BY pizzasp.size
ORDER BY order_count DESC;

-- List the top 5 most ordered pizza types along with their quantities.

SELECT 
    pizza_types.name AS Pizza_name,
    SUM(order_details.quantity) AS total_quantity
FROM
    pizza_types
        INNER JOIN
    pizzasp ON pizza_types.pizza_type_id = pizzasp.pizza_type_id
        INNER JOIN
    order_details ON pizzasp.pizza_id = order_details.pizza_id
GROUP BY Pizza_name
ORDER BY total_quantity DESC
LIMIT 5;

-- Join the necessary tables to find the total quantity of each pizza category ordered.

SELECT 
    pizza_types.category AS Pizza_category,
    SUM(order_details.quantity) AS total_quantity
FROM
    pizza_types
        INNER JOIN
    pizzasp ON pizza_types.pizza_type_id = pizzasp.pizza_type_id
        INNER JOIN
    order_details ON pizzasp.pizza_id = order_details.pizza_id
GROUP BY Pizza_category
ORDER BY total_quantity DESC;

-- Determine the distribution of orders by hour of the day.

SELECT 
    HOUR(order_time) AS hour, COUNT(order_id) AS order_count
FROM
    orders
GROUP BY hour;

-- Join relevant tables to find the category-wise distribution of pizzas.

select category ,count(name)
from pizza_types
group by category;

-- Group the orders by date and
-- calculate the average number of pizzas ordered per day.
SELECT 
    ROUND(AVG(Quantity), 0) AS Average_no_of_pizza_ordered_per_day
FROM
    (SELECT 
        orders.order_date, SUM(order_details.quantity) AS Quantity
    FROM
        order_details
    INNER JOIN orders USING (order_id)
    GROUP BY orders.order_date) AS order_quantity;

    -- Determine the top 3 most ordered pizza types based on revenue.
    
    select pizza_types.name as pizza_name, sum(order_details.quantity * pizzasp.price) as Revenue
    from pizza_types inner join pizzasp using(pizza_type_id) inner join
    order_details using(pizza_id) group by pizza_name order by Revenue desc limit 3;
    
    
    -- Calculate the percentage contribution of each pizza type to total revenue.
    
  SELECT 
    pizza_types.category,
    ROUND((SUM(order_details.quantity * pizzasp.price) / (SELECT 
                    ROUND(SUM(order_details.quantity * pizzasp.price),
                                2) AS Total_Revenue
                FROM
                    order_details
                        JOIN
                    pizzasp ON pizzasp.pizza_id = order_details.pizza_id)) * 100,
            2) AS Revenue
FROM
    pizza_types
        INNER JOIN
    pizzasp USING (pizza_type_id)
        INNER JOIN
    order_details USING (pizza_id)
GROUP BY pizza_types.category
ORDER BY Revenue DESC;

-- Analyze the cumulative revenue generated over time.
select order_date,sum(Revenue) over(order by order_date) as cum_revenue
from
(select orders.order_date, sum(order_details.quantity * pizzasp.price) as Revenue
from orders inner join	order_details using(order_id) inner join pizzasp using(pizza_id)
group by orders.order_date) as Sales ;

-- Determine the top 3 most ordered pizza types 
-- based on revenue for each pizza category.

select name, revenue from
(select category,name,revenue,
rank() over(partition by category order by revenue desc) as rn from
(
select pizza_types.category,pizza_types.name,
sum(order_details.quantity * pizzasp.price) as revenue
from pizza_types inner join pizzasp using(pizza_type_id) inner join
order_details using(pizza_id)
group by pizza_types.category,pizza_types.name) as a) as b
where rn <=3;
