
---Case 01: Danh sách ID khách hàng mua sản phẩm tháng 01 năm 2013
Select 
Distinct CustomerID
From Sales.SalesOrderHeader
Where YEAR(OrderDate)=2013 and MONTH(OrderDate)=1

--- Case 02: Thống kê số lượng khách hàng theo từng tháng năm 2013

Select
MONTH(OrderDate) Thang,
COUNT(CustomerID) Soluong
From Sales.SalesOrderHeader
Where YEAR(OrderDate)=2013
Group by MONTH(OrderDate)
Order by Month(OrderDate) asc

---Case03: Thống kê số lượng KH mua hàng từ tháng 1 mua hàng ở các tháng tiếp theo

with cte as 
(select distinct  CustomerID
from [Sales].[SalesOrderHeader]
where year(Orderdate)= 2013
and month(orderdate) = 1)

select 
month(orderdate) as Month,
count( distinct  CustomerID) as num_cus
from [Sales].[SalesOrderHeader]
where year(Orderdate)=2013
and customerID in ( select * from cte)
group by month(orderdate)
order by  Month (orderdate)

---Case04:Tính thời gian chênh lệch giữa 2 lần mua của khách hàng

WITH cte AS (
SELECT CustomerID,
	DATEPART(week,orderDate) week,
	LEAD(DATEPART(week,orderDate)) over(partition by CustomerID order by DATEPART(week,orderDate)) lead
FROM Sales.SalesOrderHeader
WHERE YEAR(OrderDate)=2013
)

SELECT *,
	(lead - week) diff
FROM cte

---Case05: Phân loại khách hàng dựa vào thời gian chênh lệch giữa 2 lần mua

with cte as
(
SELECT
    CustomerID,
    datepart(week,OrderDate) AS week,
    LEAD(datepart(week,OrderDate)) OVER (PARTITION BY CustomerID ORDER BY datepart(week,OrderDate) asc) AS lead
FROM
    Sales.SalesOrderHeader
where year(orderdate) = 2013
),
ct2 as
(
select *, lead - week  as time_diff
from cte
)
select
CustomerID,
week,
case 
	when time_diff < 3 then 'kh_a'
	when time_diff > 3 then 'kh_b'
else 'kh_c'
end as type
from
ct2

---Case06: Tính số lượng khách hàng mua tiếp ở lần tiếp theo trong 3 tuần

with cte as
(SELECT
    CustomerID,
    datepart(week,OrderDate) AS week,
    LEAD(datepart(week,OrderDate)) OVER (PARTITION BY CustomerID ORDER BY datepart(week,OrderDate) asc) AS lead
FROM
    Sales.SalesOrderHeader
where year(orderdate) = 2013
),
ct2 as
(select *, lead - week  as time_diff
from cte
),
cte3 as
(select
CustomerID,
week,
case 
	when time_diff < 3 then 'kh_a'
	when time_diff > 3 then 'kh_b'
else 'kh_c'
end as cust_type
from
ct2
)
SELECT
WEEK,
COUNT(CUSTOMERID) AS num_cust,
COUNT(CASE WHEN cust_type = 'kh_a' then CUSTOMERID END) AS retention
FROM CTE3
GROUP BY WEEK
ORDER BY WEEK

---Case07: Lấy danh sách khách hàng có mua hàng trong 4 quý

with cte as
(
SELECT
    CustomerID,
    datepart(QUARTER,OrderDate) AS QUARTER,
    LEAD(datepart(week,OrderDate)) OVER (PARTITION BY CustomerID ORDER BY datepart(QUARTER,OrderDate) asc) AS lead
FROM
    Sales.SalesOrderHeader
where year(orderdate) = 2013
)
select
CustomerID,
count(case when lead is not null then lead end) as numb_quarters
from
cte
group by CustomerID
having count(case when lead is not null then lead end) = 3

