create database Sales_Store ;

use Sales_Store ;

select * from Sales_data  ;

---data cleaning 
---1
select transaction_id , count(*) count 
from Sales_data 
group by  transaction_id 
having count(transaction_id) > 1 ;


TXN240646
TXN342128
TXN855235
TXN981773

with cte as (
		select * , 
		ROW_NUMBER () over (partition by transaction_id order by transaction_id ) as row_no 
		from Sales_data 
		)


		--delete from cte 
		--where row_no = 2 ; 
select * from cte 
where transaction_id in ('TXN240646','TXN342128','TXN855235','TXN981773') ;

----2

select * from sales_data ;

exec sp_rename 'sales_data.quantiy' , 'quantity' , 'column ' ;

exec sp_rename 'sales_data.prce' , 'price' , 'column ' ; 


---3

select column_name , data_type
from INFORMATION_SCHEMA.columns
where table_name = 'sales_data' ;

---4
--- work with Nulls
select * from sales_data 
where transaction_id is null
	  or 
	  customer_id is null
	  or 
	  customer_name is null
	  or 
	  customer_age is null
	  or 
	  gender is null
	  or 
	  product_id is null
	  or
	  product_name is null
	  or 
	  product_category is null
	  or 
	  quantity is null
	  or 
	  price is null
	  or 
	  payment_mode is null
	  or
	  purchase_date is null
	  or 
	  time_of_purchase is null
	  or
	  status is null ;
	   
delete from sales_data 
where transaction_id is null ;

select * from sales_data 
where customer_name = 'Ehsaan Ram' ;

update sales_data 
set customer_id = 'CUST9494'
where transaction_id = 'TXN977900' ;

select * from sales_data 
where customer_name = 'Damini Raju' ;

update sales_data 
set customer_id = 'CUST1401'
where transaction_id = 'TXN985663';


select * from sales_data 
where customer_id = 'CUST1003' ;

update sales_data 
set gender = 'Male' 
where transaction_id = 'TXN432798';


----- 5

select * from sales_data ;

update sales_data 
set gender = 'Female'
where gender = 'F' ;

update sales_data 
set gender = 'Male'
where gender = 'M' ;

update sales_data 
set payment_mode = 'Credit Card'
where payment_mode = 'CC';

select distinct gender from sales_data ; 
select distinct payment_mode   from sales_data ;
select * from sales_data ; 



--- Q1 What are the top 5 most selling products by quantity 
	   select top 5 product_name , sum(quantity) as quantity_sum
	   from sales_data
       where status = 'delivered'
	   group by product_name
	   order by quantity_sum desc ;


---Q2 Which products are most frequently canceled .
	  select top 5 product_name ,status , count(status) as count_status  
	  from sales_data 
	  where status = 'cancelled'
	  group by product_name ,status
	  order by count_status desc ;


---Q3 What time of the day has highest number of purchases.
	  select 
			case
				when datepart (hour ,time_of_purchase ) between 0 and 5 then 'Night'
				when datepart (hour ,time_of_purchase ) between 6 and 11 then 'Morning'
				when datepart (hour ,time_of_purchase ) between 12 and 17 then 'Afternoon'
				when datepart (hour ,time_of_purchase ) between 18 and 23 then 'Evening'
				end as time_of_day,
				count(*) as total_orders 
				from sales_data
				group by 
				case
				when datepart (hour ,time_of_purchase ) between 0 and 5 then 'Night'
				when datepart (hour ,time_of_purchase ) between 6 and 11 then 'Morning'
				when datepart (hour ,time_of_purchase ) between 12 and 17 then 'Afternoon'
				when datepart (hour ,time_of_purchase ) between 18 and 23 then 'Evening'
				end 
				order by total_orders desc ;
		

---Q4 who are the top 5 highest spending customers.
      select top 5 customer_name , concat( '$ ' ,sum(price * QUANTITY)) as total_spend  
	  from sales_data 
	  group by customer_name
	  order by total_spend desc ;


---Q5 which product categories generate the highest revnue.
	  select product_category , sum(price * quantity )as Highest_revnue 
	  from sales_data 
	  group by product_category
	  order by Highest_revnue desc ;


---Q6 what is the return/cancellation rate per product category.
		--- cancellation
		select product_category,
			concat(cast(count(case when status = 'cancelled' then 1 end)*100.0/count(*)as decimal (10,2)),' %' ) as cancelled_percentage
		 from sales_data 
		 group by product_category
		 order by cancelled_percentage desc;

		 --- return
		 select product_category,
			concat(cast(count(case when status = 'returned' then 1 end)*100.0/count(*)as decimal (10,2)),' %' ) as returned_percentage
		 from sales_data 
		 group by product_category
		 order by returned_percentage desc;


---Q7 what is the most preferred payment mode .
	 select top 1 payment_mode ,count(payment_mode) as payment_mode_count 
	 from sales_data
	 group by payment_mode
	 order by payment_mode_count desc ;


---Q8 How does age group affect purchasing behavior.
	  select 
			case 
			    when customer_age between 18 and 25 then '18-25'
				when customer_age between 26 and 35 then '26-35'
				when customer_age between 36 and 50 then '36-50'
				else '51+'
				end as customer_age , 
				format(sum(price * quantity),'C0' ,'en-IN' )as total_purchase 
				from sales_data
				group by case 
			    when customer_age between 18 and 25 then '18-25'
				when customer_age between 26 and 35 then '26-35'
				when customer_age between 36 and 50 then '36-50'
				else '51+'
				end
				order by total_purchase desc ;


---Q9 what's the monthly sales tread .
	  select 
			format(purchase_date ,'yyyy-MM') as month_year,
			format(sum(price * quantity ) , 'C0' , 'en-IN') as total_sales,
			sum(quantity) as sum_quantity 
			from sales_data
			group by format(purchase_date ,'yyyy-MM')  ;


---Q10 Are certain genders buying more specific product categories .
       --- method 1
       select gender , product_category , count(product_category) as count_category
	   from sales_data 
	   group by gender ,product_category
	   order by gender ;
	   

	    --- method 2
       select *
	   from ( select gender , product_category
	   from sales_data 
	   ) as temp_table
	   pivot (
	   count(gender) for gender in ([Male] , [Female])
	   ) as pivot_table 
	   order by product_category ;



