-- Q1.What is the total amount each customer spent on zomato?

select a.userid ,sum(b.price) as amount 
from sales a inner join product b 
on a.produsct_id= b.product_id
group by a.userid;

--Q2.How many days has each customer visited zomato?

select userid, count(distinct created_date) as distinct_days
from sales
group by userid;

--Q3.What was the first product  purchased by each customer?

select * from
(select *,rank()over (partition by userid order by created_date desc)rnk from sales) a where rnk=1

--Q4.What is the most purchased item on the menu and how many times was it purchased by all customers?

select userid,count(product_id) cnt from sales
where product_id = (select product_id
from sales
group by product_id
order by count(product_id) desc limit 1)
group by userid;

--Q5.Which item was the most popular for each customer?

select * from
(select *, rank() over (partition by userid order by count desc)rnk from
(select userid,product_id,count(product_id) as count
from sales 
group by userid,product_id)a)b
where rnk=1;

--Q6.Which item was first purchased by the customer after they became a member.
select * from (select c.*, rank() over (partition by userid order by created_date) rnk 
from ( select a.userid,a.created_date,b.gold_signup_date from sales a
full join goldusers_signup b
on a.userid = b.userid
where a.created_date>= b.gold_signup_date) c) d
where rnk =1;

--Q7.Which item was purchased  just before the customer became a member?

select * from 
(select c.*, rank() over (partition by userid order by created_date desc) rnk 
 from (select a.userid,a.created_date,b.gold_signup_date 
from sales a
right join goldusers_signup b
on a.userid = b.userid
where a.created_date<= b.gold_signup_date)c)d
where rnk=1;

--Q8.What is the total orders and amount spent for each member before they became a member?

select userid ,sum(price) as total,count(userid) from
(select c.*,d.price from
(select a.userid,a.created_date,b.gold_signup_date,a.product_id from sales a inner join goldusers_signup b
on a.userid = b.userid where a.created_date <b.gold_signup_date) c
inner join
product d
on c.product_id = d.product_id)e
group by userid;

--Q9.If buying each product generates points for eg 5rs=2 zomato point and each product has different
--purchasing points for eg for p1 5rs=1 zomato point ,for p2 10rs=5zomato point and p3 5rs=1 zomato point
--Calculate points collected by each customers and for which product most points have been given till now

select userid,sum(totalpoints)*2.5 totalpoints from
(select d.*,(sumtotal/points)as totalpoints from
(select c.*, case when product=1 then 5 when product=2 then 2 when product=3 then 5 else 0 end as points from
(select a.userid ,a.product_id as product,sum(b.price)as sumtotal from sales a inner join product b 
 on a.product_id = b.product_id
group by product,a.userid
order by a.userid)c)d)e
group by userid;

select * from
(select f.*,rank() over ( order by productwise_pointstotal desc) rank from
(select product,sum(totalpoints) as productwise_pointstotal from
(select d.*,(sumtotal/points)as totalpoints from
(select c.*, case when product=1 then 5 when product=2 then 2 when product=3 then 5 else 0 end as points from
(select a.userid ,a.product_id as product,sum(b.price)as sumtotal from sales a inner join product b 
 on a.product_id = b.product_id 
 group by product,a.userid order by a.userid)c)d)e group by product)f)g
where rank=1

--Q10.In the first one year after a customer joins the gold program(including their join date) irrespective
--of what the customer has purchased they earn 5 zomato points for every 10rs spent who earned more 1 or 3
--and what was their points earnings in their first year?

select c.*,d.price,d.price*0.5 goldmember_points from
(select a.userid,a.product_id,a.created_date,b.gold_signup_date from sales a
full join goldusers_signup b
on a.userid = b.userid
where b.gold_signup_date+365 >= a.created_date and  a.created_date >= b.gold_signup_date)c
inner join product d
on c.product_id= d.product_id;

--Q11.Rank all the transactions of the customers

select *,rank()over (partition by userid order by created_date) rnk from sales;

--Q12.Rank all the transaction for each customer whenever they are a zomato gold member for
--non gold member transaction as na.

select d.* ,case when rnk ='0' then 'na' else rnk end as rnkk from 
(select c.*,cast ((case when gold_signup_date is null then 0 else rank() over 
(partition by userid order by created_date desc) end )as varchar )as rnk from
(select a.userid,a.created_date,a.product_id ,b.gold_signup_date from sales a
left join goldusers_signup b
on a.userid = b.userid and a.created_date>= b.gold_signup_date)c)d;

