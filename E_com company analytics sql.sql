use ecom;
select * from customers;
select * from order_details;
select * from orders;
select * from products;

alter table customers rename column ï»¿customer_id to customer_id ;
alter table order_details rename column ï»¿order_id to order_id;
alter table orders rename column ï»¿order_id to order_id;
alter table products rename column ï»¿product_id to product_id;

# Delete unknown column  if  itis 1 or 2.
create table AB as select customer_id, name,location from customers;
select* from AB; 
drop table customers;
alter table AB rename to customers;
select * from customers;

create table BC as select order_id, product_id, quantity, price_per_unit from order_details;
select* from BC; 
drop table order_details;
alter table BC rename to order_details;
alter table corder_details rename to order_details;
select * from order_details; 

create table CD as select order_id, order_date,customer_id,total_amount from orders;
select* from CD; 
drop table orders;
alter table CD rename to orders;
select * from orders;

create table DE as select product_id, name,category,price from products;
select* from DE; 
drop table products;
alter table DE rename to products;
select * from products;


#1 You can analyze all the tables by describing their contents.
describe customers;
describe order_details;
describe orders;
describe products;


#2 Identify the top 3 cities with the highest number of customers to determine key markets for targeted marketing and logistic optimization.
select location, count(*) as number_of_customers from customers 
group by location
order by number_of_customers desc
limit 3;

#3 As per the last query's result, Which of the cities must be focused as a part of marketing strategies?
# Ans- Delhi, chennai,Jaipur.

#4 Determine how many customers fall into each order frequency category based on the number of orders they have placed.
select number_of_orders,count(*) as customer_count 
from
(select customer_id,count(*) number_of_orders from orders
group by customer_id 
) as customer_orders
group by number_of_orders
order by number_of_orders asc ;

#5 As per the Engagement Depth Analysis question, What is the trend of the number of customers v/s number of orders?
#Ans- As the Number of orders increases, the Customer count decreases.

#6 As per the Engagement Depth Analysis question, Which customers category does the company experiences the most?
#Ans- Occasional shoppers/customers. 

#7 Identify products where the average purchase quantity per order is 2 but with a high total revenue, suggesting premium product trends.
select * from order_details;
select product_id, avg(quantity) as avg_quantity, sum(quantity * price_per_unit) as total_revenue from order_details
group by product_id
having avg_quantity = 2
order by total_revenue desc;

#8 Among products with an average purchase quantity of two, which ones exhibit the highest total revenue?
# Ans - Product1 


#9 For each product category, calculate the unique number of customers purchasing from it. This will help understand which categories have wider appeal across the customer base.

select p.category, count(distinct o.customer_id) as unique_customers from products p
join
order_details od on p.product_id = od.product_id
join
orders o on o.order_id = od.order_id
group by p.category
order by unique_customers desc;

#10 As per the last question, Which product category needs more focus as it is in high demand among the customers?
#Ans- Electronics


#11 Analyze the month-on-month percentage change in total sales to identify growth trends.
select * from orders;

select date_format(order_date, '%Y-%m') as month,
sum(total_amount) as total_sales ,
round(
(sum(total_amount) - lag(sum(total_amount)) over (order by date_format(order_date, '%Y-%m')))/ lag(sum(total_amount)) over (order by date_format(order_date,'%Y-%m'))* 100, 2)as percentage_change from orders
group by date_format(order_date,'%Y-%m')
order by month;

# OR 
WITH monthly_sales AS (
    SELECT DATE_FORMAT(order_date, '%Y-%m') AS month,
           SUM(total_amount) AS total_sales
    FROM orders
    GROUP BY DATE_FORMAT(order_date, '%Y-%m')
)
SELECT month,
       total_sales,
       ROUND(
           (total_sales - LAG(total_sales) OVER (ORDER BY month))
           / LAG(total_sales) OVER (ORDER BY month) * 100,
           2
       ) AS percentage_change
FROM monthly_sales
ORDER BY month;

#12 As per Sales Trend Analysis question, During which month did the sales experience the largest decline?
#Ans- Feb 2024

#13 As per Sales Trend Analysis question, What could be inferred about the sales trend from March to August?
#Ans - Sales fluctuated with no clear trend.

#14 Examine how the average order value changes month-on-month. Insights can guide pricing and promotional strategies to enhance order value.
select * from orders;

with MonthlyAOV as(
		select date_format(order_date,'%Y-%m') as month,
        avg(total_amount) as avg_order_value
        from orders
        group by date_format(order_date,'%Y-%m')
        ),
        
    MonthlyChange as (
		select month, avg_order_value,
        avg_order_value - lag(avg_order_value) over(order by month) as change_in_value
        from MonthlyAOV )
 select month, round(avg_order_value,2) as avg_order_value, round(change_in_value,2) as change_in_value
 from MonthlyChange
 order by change_in_value  desc;
 
 #15 As per last question, Which month has the highest change in the average order value?
 # Ans- December
 
 #16 Based on sales data, identify products with the fastest turnover rates, suggesting high demand and the need for frequent restocking.
 select product_id, count(*) as salesfrequency
 from order_details
 group by product_id
 order by count(*) desc
 limit 5;
 
 #17 As per last question, Which product_id has the highest turnover rates and needs to be restocked frequently?
 #Ans- product_id 7
 
 #18 List products purchased by less than 40% of the customer base, indicating potential mismatches between inventory and customer interest.

select p.product_id, p.name, count(distinct o.customer_id) as unique_customers_count
from products p
join 
order_details od on od.product_id = p.product_id
join
orders o on od.order_id = o.order_id
group by p.product_id ,p.name
having unique_customers_count < (select count(*) from customers) * 0.40;

#19 Why might certain products have purchase rates below 40% of the total customer base?
#Ans- Poor visibility on the platform
 
#20 After running an analysis to identify products purchased by less than 40% of the customer base, it was found that a few products have lower purchase rates than expected.
	# What could be a strategic action to improve the sales of these underperforming products?
# Ans- Implement targeted marketing campaigns to raise awareness and interest.

#21 Evaluate the month-on-month growth rate in the customer base to understand the effectiveness of marketing campaigns and market expansion efforts.
with monthly_new_customers as(
	select date_format(min(order_date),'%Y-%m') as first_purchase_month,
	count(distinct customer_id) as new_customers
	from orders
    group by customer_id
)
select first_purchase_month, sum(new_customers) as total_new_custmers
from monthly_new_customers 
group by first_purchase_month 
order by first_purchase_month;

#22 As per last question, What can be inferred about the growth trend in the customer base from the result table?
#Ans- It is downward trend which implies the marketing campaign are not much effective

#23 Identify the months with the highest sales volume, aiding in planning for stock levels, marketing efforts, and staffing in anticipation of peak demand periods.
select date_format(order_date,'%Y-%m') as month,
sum(total_amount) as total_sales from orders
group by date_format(order_date,'%Y-%m')
order by total_sales desc
limit 3;

#24 As per last question, Which months will require major restocking of product and increased staffs?
#Ans- September, December

        