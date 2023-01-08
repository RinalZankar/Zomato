 use  zomato;
drop table if exists goldusers_signup;
CREATE TABLE goldusers_signup(userid integer,gold_signup_date date); 

INSERT INTO goldusers_signup(userid,gold_signup_date) 
 VALUES (1,'2017-09-22'),
(3,'2017-04-21');

drop table if exists users;
CREATE TABLE users(userid integer,signup_date date); 

INSERT INTO users(userid,signup_date) 
 VALUES (1,'2014-02-09'),
(2,'2015-01-15'),
(3,'2014-11-04');

drop table if exists sales;
CREATE TABLE sales(userid integer,created_date date,product_id integer); 

INSERT INTO sales(userid,created_date,product_id) 
 VALUES (1,'2017-04-19',2),
(3,'2019-12-18',1),
(2,'2020-07-20',3),
(1,'2019-10-23',2),
(1,'2018-03-19',3),
(3,'2016-12-20',2),
(1,'2016-11-09',1),
(1,'2016-05-20',3),
(2,'2017-09-24',1),
(1,'2017-03-11',2),
(1,'2016-03-11',1),
(3,'2016-11-10',1),
(3,'2017-12-07',2),
(3,'2016-12-15',2),
(2,'2017-11-08',2),
(2,'2018-09-10',3);


drop table if exists product;
CREATE TABLE product(product_id integer,product_name text,price integer); 

INSERT INTO product(product_id,product_name,price) 
 VALUES
(1,'p1',980),
(2,'p2',870),
(3,'p3',330);


select * from sales;
select * from product;
select * from goldusers_signup;
select * from users;
-- what is total amount each customer spent on zomato?
select sales.userid, sum(product.price) from sales inner join product on sales.product_id=product.product_id 
 group by sales.userid;
 
-- how many days has each customer visited zomato?
select userid, count(distinct created_date) distinct_days from sales group by userid;

-- what was the first product purchased by each customer?
select * from
(select *, rank() over(partition by userid order by created_date ) rnk from sales) a where rnk =1;

-- what is the mostb purchased item in menu and how many times it was purchased by all customer?
select product_id, count(product_id) from sales group by product_id order by count(product_id)desc limit 1;

-- which item was most popular for each customer?
select * from
(select *, rank() over(partition by userid order by cnt desc) rnk from
(select userid,product_id, count(product_id) cnt from sales group by userid, product_id)a)b
where rnk=1;

-- which item was purchased first by the customer after they became member?
select * from 
(select c.*, rank() over (partition by userid order by created_date) rnk from  
(select a.userid, a.created_date, a.product_id,b.gold_signup_date from sales a inner join goldusers_signup b
 on a.userid= b.userid and created_date>=gold_signup_date)c)d where rnk =1;
 
 -- which item was purchased just before the customer became gold member?
 select * from 
(select c.*, rank() over (partition by userid order by created_date desc) rnk from  
(select a.userid, a.created_date, a.product_id,b.gold_signup_date from sales a inner join goldusers_signup b
 on a.userid= b.userid and created_date<gold_signup_date)c)d where rnk =1;
 
 -- what is total orders and amount spent for each member before they became a member?
select userid,count(created_date) order_purchased , sum(price) amount from
(select c.*,d.price from
(select a.userid, a.created_date, a.product_id,b.gold_signup_date from sales a inner join goldusers_signup b
 on a.userid= b.userid and created_date<gold_signup_date)c inner join product d on c.product_id=d.product_id) e 
 group by userid;
 
 -- if buying each product generates point for eg 5rs-2 zomato points and each product has different purchasing points 
 -- for eg for p1 5rs-1 zomato point, for p2 10rs -5 zomato pointand p3 5rs-1 zomato point
 -- calculate points collected by each customer and for which product most points have been given .
 select userid, sum(total_points) total_points_earned from
 (select e.*, amt/points total_points from
 (select d.*, case when product_id=1 then 5 when product_id=2 then 2 when product_id=3 then 5 else 0 end as points from
 (select c.userid, c.product_id, sum(price) amt from
 (select a.*, b.price from sales a inner join product b on a.product_id=b.product_id)c
 group by userid,product_id)d)e)f group by userid;
  
 -- in the first one year after a customer join the gold program(including their join date)
 -- irrespective of what the customer has purchased the y earn 5 zomato points for every10 rs
 -- spent who earned more 1 or 3 and what was their points earnings in their first year
 -- 1zp= 2 rs
 select * from goldusers_signup;
   
   -- rank all the transaction of the customer
   select*, rank() over (partition by userid order by created_date )rnk from sales;
   -- rank all the transaction for each member wherever they are a zomato gold member or non gold member transaction mark as NA
   select e.*, case w  hen rnk=0 then 'na' else  rnk end as rnkk from
   (select c.*, cast((case when gold_signup_date is null then 0 else rank() over(partition by userid order by created_date desc) end) as varchar) as rnk from 
   (select a.userid, a.created_date, a.product_id, b.gold_signup_date from sales a left join
   goldusers_signup b on a.userid= b.userid and created_date>= gold_signup_date)c)e;
   