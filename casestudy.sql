
--Total revenue for the current year
SELECT SUM(net_revenue) as Total_revenue 
FROM   casestudy
WHERE  [year] = ( SELECT MAX([year])
				  FROM   casestudy  )

--New Customer Revenue 
-- e.g. new customers not present in previous year only (KH mới ko có trong tháng trc)
WITH CTE_1 AS (
  SELECT DISTINCT
    customer_email, 
    [YEAR],
    MIN([YEAR]) OVER (PARTITION BY customer_email) AS first_purchase_year
  FROM casestudy
),
CTE_2 AS (
SELECT 
   c.customer_email, 
   c.[YEAR],
   c.net_revenue,
  f.first_purchase_year,
  CASE WHEN c.[YEAR] = f.first_purchase_year THEN 1 ELSE 0 END AS isNewCustomer,
  CASE WHEN c.[YEAR] <> f.first_purchase_year THEN 1 ELSE 0 END AS isReturningCustomer
FROM 
  casestudy as c
  JOIN CTE_1 as f ON c.customer_email = f.customer_email
)
SELECT
   SUM(net_revenue) as new_customer_revenue
FROM CTE_2
WHERE isNewCustomer = 1 AND customer_email NOT IN (
  SELECT customer_email                  
  FROM CTE_2
  WHERE isReturningCustomer = 1
)

--Revenue lost from attrition
SELECT 
    ((SELECT SUM(net_revenue) FROM casestudy WHERE [year] = (SELECT DATEADD(year, -1, MAX([year]))
                                                             FROM  casestudy ))
    -                      
    (SELECT SUM(net_revenue) FROM casestudy WHERE [year] =  (SELECT MAX([year])
				                                             FROM   casestudy )))
    AS Revenue_Lost_From_Attrition



--Existing Customer Growth. To calculate this, use the Revenue of existing customers for current year –(minus) Revenue of existing customers from the previous year

DECLARE @C_Year varchar(10);
SET @C_Year = '2017';

WITH CTE AS (
  SELECT SUM(CASE WHEN [year] = @C_Year THEN net_revenue ELSE 0 END) AS current_revenue,
         SUM(CASE WHEN [year] = DATEADD(yyyy, -1, @C_Year) THEN net_revenue ELSE 0 END) AS prev_year_revenue
  FROM casestudy
  WHERE [year] IN (@C_Year, DATEADD(yyyy, -1, @C_Year))
)
SELECT ((CTE.current_revenue - CTE.prev_year_revenue) / CTE.prev_year_revenue) AS growth_rate
FROM CTE;

--Existing Customer Revenue Current Year
SELECT SUM(net_revenue) as Customer_Revenue_Current_Year
FROM   casestudy
WHERE  [year] = @C_Year;

--Existing Customer Revenue Prior Year
SELECT SUM(net_revenue) as Customer_Revenue_Prior_Year
FROM casestudy
WHERE [year] = DATEADD(yyyy,-1,@C_Year);


--Total Customers Current Year
SELECT COUNT(distinct(customer_email)) as Total_Customers_Current_Year
FROM   casestudy
WHERE  [year] = (SELECT MAX([year])
				 FROM   casestudy )
-- [year] =  CAST( YEAR(GETDATE()) AS varchar(4) )

--Total Customers Previous Year

SELECT COUNT(distinct(customer_email)) as Total_Customers_Previous_Year
FROM casestudy
WHERE [year] = (SELECT DATEADD(yyyy,-1,MAX([year]))
                 FROM casestudy)
    
--New Customers
WITH CTE_1 AS (
  SELECT DISTINCT
    customer_email, 
    [YEAR],
    MIN([YEAR]) OVER (PARTITION BY customer_email) AS first_purchase_year
  FROM casestudy
),
CTE_2 AS (
SELECT 
   c.customer_email, 
   c.[YEAR],
   c.net_revenue,
  f.first_purchase_year,
  CASE WHEN c.[YEAR] = f.first_purchase_year THEN 1 ELSE 0 END AS isNewCustomer,
  CASE WHEN c.[YEAR] <> f.first_purchase_year THEN 1 ELSE 0 END AS isReturningCustomer
FROM 
  casestudy as c
  JOIN CTE_1 as f ON c.customer_email = f.customer_email
)
SELECT
   customer_email as new_customer
FROM CTE_2
WHERE isNewCustomer = 1 AND customer_email NOT IN (
  SELECT customer_email                  
  FROM CTE_2
  WHERE isReturningCustomer = 1
)

--Lost Customers
WITH CTE_1 AS (
  SELECT DISTINCT
    customer_email, 
    [YEAR],
    MIN([YEAR]) OVER (PARTITION BY customer_email) AS first_purchase_year
  FROM casestudy
),
CTE_2 AS (
SELECT 
   c.customer_email, 
   c.[YEAR],
   c.net_revenue,
  f.first_purchase_year,
  CASE WHEN c.[YEAR] = f.first_purchase_year THEN 1 ELSE 0 END AS isNewCustomer,
  CASE WHEN c.[YEAR] <> f.first_purchase_year THEN 1 ELSE 0 END AS isReturningCustomer
FROM 
  casestudy as c
  JOIN CTE_1 as f ON c.customer_email = f.customer_email
)
SELECT
   customer_email as new_customer
FROM CTE_2
WHERE isNewCustomer = 1 AND customer_email NOT IN (
  SELECT customer_email                  
  FROM CTE_2
  WHERE isReturningCustomer = 0
)
