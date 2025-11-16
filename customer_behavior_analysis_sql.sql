select * from customer;
-- comparing based on gender
select gender,
       sum(purchase_amount) as revenue
from customer
group by gender;

select customer_id, purchase_amount
from customer
where discount_applied = 'Yes' and purchase_amount > (select avg(purchase_amount) from customer);

select top 5 item_purchased, round(avg(review_rating),2) as 'Average Product Rating'
from customer
group by item_purchased
order by avg(review_rating) desc;

-- comparing the avg purchase amount between standard and express shipping types
select shipping_type , round(avg(purchase_amount),2) as 'Average purchase amount'
from customer
where shipping_type in ('Standard' , 'Express')
group by shipping_type

-- comparing the subscribed and non subscribed customers
select subscription_status,
       count(customer_id) as 'total_customers',
       round(avg(purchase_amount),2) as 'avg_spend',
       round(sum(purchase_amount),2) as 'total_revenue'
from customer
group by subscription_status
order by total_revenue,avg_spend desc;

-- which 5 products have the highest percentage of sales when discount applied
SELECT TOP 5 
    item_purchased,
    round(100*SUM(CASE WHEN discount_applied = 'Yes' THEN 1 ELSE 0 end)/count(*) ,2) AS discount_rate
FROM customer
GROUP BY item_purchased
order by discount_rate;

-- no of previous customers and show their segment
with customer_type as (
select customer_id,previous_purchases,
case 
    when previous_purchases = 1 then 'NEW'
    when previous_purchases between 2 and 10 then 'Returning'
    else 'Loyal' end as customer_segment
from customer
)
select customer_segment, count(*) as 'No_of_customers'
from customer_type
group by customer_segment
order  by No_of_customers desc

-- top 3 most purchased products within each category
with item_counts as (
select category,item_purchased,count(customer_id) as total_orders,
      ROW_NUMBER() over(partition by category order by count(customer_id) desc) as item_rank
from customer
group by category,item_purchased
)
select * from item_counts where item_rank <= 3;

-- are repeat buyers took subscription
select subscription_status,count(customer_id) as repeat_buyers
from customer where previous_purchases > 5 group by subscription_status; 

-- what is the revenue contribution of each age group
select age_group,
       sum(purchase_amount) as total_revenue
from customer
group by age_group
order by total_revenue desc