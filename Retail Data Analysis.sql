--create database retail_analysis


--Data preparattion and understanding

--Q1
select count (customer_id)[count] 
from Customer

select count (prod_cat_code)[count] 
from prod_cat_info

select count (transaction_id)[count] 
from Transactions



--Q2
select count (transaction_id)[count of transaction with return] 
from Transactions
where total_amt < 0


--Q3
ALTER TABLE transactions
ALTER COLUMN tran_date date

--Q4
select min(tran_date)[start date],
max(tran_date)[end date],
DATEDIFF(day, min(tran_date), max(tran_date))[day],
DATEDIFF(month, min(tran_date), max(tran_date))[month],
DATEDIFF(year, min(tran_date), max(tran_date))[year]
from Transactions

--Q5
select prod_cat 
from prod_cat_info
where prod_subcat='DIY'


--Data analysis

--Q1
select top 1 Store_type[Frequently used channel]
from Transactions
group by Store_type
order by count(transaction_id) desc


--Q2
select Gender,count(customer_id)[count] 
from Customer
group by Gender

--Q3
select top 1 city_code 
from Customer
group by city_code
order by count(customer_id) desc


--Q4
select count(prod_subcat)[count of sub catagory-books] 
from prod_cat_info
where prod_cat='BOOKS'

--Q5
select top 1 prod_cat,
count(transaction_id)[count] 
from Transactions t inner join prod_cat_info p on t.prod_cat_code=p.prod_cat_code
group by prod_cat
order by count(transaction_id) desc




--Q6
select prod_cat,
sum(total_amt)[total revenue]
from Transactions t inner join prod_cat_info p on t.prod_cat_code=p.prod_cat_code
where prod_cat='electronics'or prod_cat='books'
group by prod_cat


--Q7
select cust_id,
count(transaction_id)[count] 
from Transactions
where total_amt>0
group by cust_id
having count(transaction_id)>10

--Q8

SELECT sum(total_amt)[revenue]
from Transactions t inner join prod_cat_info p on t.prod_cat_code=p.prod_cat_code
where Store_type='flagship store' and (prod_cat ='electronics' or prod_cat ='clothing')


--Q9

SELECT prod_subcat,
sum(total_amt)[Revenue] 
from Transactions t inner join prod_cat_info p on t.prod_cat_code=p.prod_cat_code inner join customer c on t.cust_id=c.customer_Id
where Gender= 'm' and prod_cat='electronics'
group by prod_subcat


--Q10
select top 5 P.prod_subcat [Subcategory] ,
    ((Round(SUM(cast( case when T.Qty < 0 then T.Qty  else 0 end as float)),2))/
                  (Round(SUM(cast( case when T.Qty > 0 then T.Qty else 0 end as float)),2)
                 - Round(SUM(cast( case when T.Qty < 0 then T.Qty   else 0 end as float)),2)))*100[%_Returs],
    ((Round(SUM(cast( case when T.Qty > 0 then T.Qty  else 0 end as float)),2))/
                  (Round(SUM(cast( case when T.Qty > 0 then T.Qty else 0 end as float)),2)
                 - Round(SUM(cast( case when T.Qty < 0 then T.Qty   else 0 end as float)),2)))*100[%_sales]
    from Transactions as T
    INNER JOIN prod_cat_info as P ON T.prod_subcat_code = P.prod_sub_cat_code
    group by P.prod_subcat
    order by [%_sales] desc




--Q11
--Age as of today
select sum(total_amt)[Revenue]
from(select *,datediff(year,DOB,getdate())[Age] from customer)cn inner join (select *,MAX(tran_date) OVER () [max_tran_date] from Transactions) t on cn.customer_Id=t.cust_id
where  t.tran_date >= DATEADD(day, -30,[max_tran_date])and  cn.[Age] between 25 and 35 


--Q12
SELECT TOP 1 prod_cat_code ,SUM(Total_amt) [totalreturns] FROM TRANSACTIONS
WHERE Tran_date >= DATEADD(day, -90,2014-02-28) AND Total_amt < 0
GROUP BY prod_cat_code
ORDER BY totalreturns ASC

--Q13

select top 1 store_type, sum(total_amt)[total sales], sum(Qty)[quantity sold]
from Transactions
group by Store_type
ORDER BY  [total sales] DESC,  [quantity sold] DESC 


--Q14
SELECT p.prod_cat, AVG(t.total_amt) [average]
FROM (SELECT *, AVG(total_amt) OVER ()[overall_average]
      FROM Transactions 
     ) t JOIN
     prod_cat_info P 
     ON T.prod_cat_code = P.prod_cat_code
GROUP BY p.prod_cat, overall_average
HAVING AVG(t.total_amt) > overall_average;


--Q15
select p.prod_cat,p.prod_subcat ,[total revenue],[average revenue] from 
(select t2.prod_subcat_code, sum(t2.total_amt)[total revenue],avg(total_amt)[average revenue] from
(select top 5 prod_cat_code, sum(qty)[Total Quantity] from Transactions
group by prod_cat_code
order by [Total Quantity] desc)t1 inner join Transactions t2 on t1.prod_cat_code=t2.prod_cat_code
group by t2.prod_subcat_code)t inner join prod_cat_info p on t.prod_subcat_code=p.prod_sub_cat_code
