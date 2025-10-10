/*
 ************************
       INTERMEDIATE
 ************************
 Description: Based on AdventureWorks dataset
 Source: https://github.com/Microsoft/sql-server-samples/releases/tag/adventureworks
 */

USE AdventureWorks2022

-- skimming through data...
SELECT TOP 10 *
FROM AdventureWorks2022.Person.Person;

SELECT TOP 10 * 
FROM AdventureWorks2022.Production.Product;

SELECT TOP 10 * 
FROM AdventureWorks2022.Sales.SalesOrderHeader; -- sales order ID, SO number, PO number, Cust ID, Sales person ID, Total Due (amount)

SELECT TOP 10 *
FROM AdventureWorks2022.Sales.Customer -- Cust ID, Store ID

SELECT TOP 10 *
FROM AdventureWorks2022.HumanResources.Employee -- NationalIDno., JOb title, birthdate, hiring date

SELECT TOP 10 *
FROM AdventureWorks2022.Sales.SalesOrderDetail

/* Notes
using Common Table Expressions (CTE)
 */

--find the top 5 customers by total sales amount
USE AdventureWorks2022;

WITH CustomerSales AS (
	SELECT c.CustomerID,
		p.FirstName + ' ' + p.LastName AS CustomerName,
		SUM(soh.TotalDue) AS TotalSpent
	FROM Sales.SalesOrderHeader soh
	JOIN Sales.Customer c ON soh.CustomerID = c.CustomerID
	JOIN Person.Person p ON soh.CustomerID = p.BusinessEntityID
	GROUP BY c.CustomerID, p.FirstName, p.LastName
	)
	
SELECT TOP 5 *
FROM CustomerSales
ORDER BY TotalSpent DESC	


/* Notes
creating temp tables
 */

--find number of high-value orders (defined as total due > $5,000)

SELECT *
INTO #HighValueOrders
FROM AdventureWorks2022.Sales.SalesOrderHeader
WHERE TotalDue > 5000;

SELECT COUNT(*) AS TotalHighValueOrders FROM #HighValueOrders


/* Notes
CTE vs Temporary Tables
-----------------------

CTE: temporary,named result set that exists only for the duration of a single SQL statement. defined right at the top of query using "WITH"

When to use: 
- when you need to organize complex logic into readable section
- when you want to reference the same derived results multiple times in one query
- when writing recursive queries

Limitations:
- exist ONLY DURING that query execution - can't reuse in another query
- SQL server doesn't index or store it in tempdb; it's re-evaluated each time you reference it
- can have performance issues if referenced multiple times in the same query because it's re-computed.

------------------------------------------------------------------------------------------------------------------------------------------------

Temp Tables: #TempTable is a physical table created in tempdb that can store intermediate results

When to use:
- when need to store intermediate results and query them multiple times
- when data is large and reused across multiple queries or steps
- when you want to add indexes to improve performance
- when debugging or want to inspect the intermediate data

Limitations:
- slightly slower setup because it writes to disk(tempdb)
- must be explicitly dropped (will automatically drop when session ends)

 */


/* Notes
case when logic
 */

--label orders as low (<1000), medium (>1000 and <5000) and high (>5000)

SELECT SalesOrderID,
		CASE
			WHEN TotalDue < 1000 THEN 'Low'
			WHEN TotalDue BETWEEN 1000 AND 5000 THEN 'Medium' -- Between is inclusive
			ELSE 'High'
		END AS OrderCategory,
		TotalDue	
FROM AdventureWorks2022.Sales.SalesOrderHeader;


-- classify employees by years of service

SELECT BusinessEntityID ,
		JobTitle ,
		DATEDIFF(YEAR, HireDate , GETDATE()) AS YearsofService,
		CASE
			WHEN DATEDIFF(YEAR, HireDate , GETDATE()) < 3 THEN 'Junior'
			WHEN DATEDIFF(YEAR, HireDate , GETDATE()) BETWEEN 3 AND 10 THEN 'Mid-Level'
			ELSE 'Senior'
		END AS EmployeeLevel
FROM AdventureWorks2022.HumanResources.Employee


/* Notes
window functions - analyse trends and rankings without groupby
 */

-- find EACH customer's most recent 3 orders

SELECT *
FROM (
	SELECT CustomerID,
	SalesOrderID ,
	OrderDate ,
	TotalDue ,
	ROW_NUMBER() OVER (PARTITION BY CustomerID ORDER BY OrderDate DESC) AS rn -- pivot by customer, rank order by most recent
	FROM AdventureWorks2022.Sales.SalesOrderHeader ) ranked
WHERE rn <= 3
ORDER BY CustomerID , rn 

-- rank products by total sales

SELECT p.ProductID,
		p.Name AS ProductName,
		SUM(sod.LineTotal) AS TotalSales,
		RANK() OVER (ORDER BY SUM(sod.LineTotal) DESC) AS SalesRank
FROM AdventureWorks2022.Sales.SalesOrderDetail sod
JOIN AdventureWorks2022.Production.Product p ON sod.ProductID = p.ProductID 
GROUP BY p.ProductID, p.Name
ORDER BY SalesRank

-- compare each month's total sales to the previous month

WITH MonthlySales AS (
SELECT 
	FORMAT(OrderDate, 'yyyy-MM') AS SalesMonth,
	SUM(TotalDue) AS TotalSales
FROM AdventureWorks2022.Sales.SalesOrderHeader
GROUP BY FORMAT(OrderDate, 'yyyy-MM')
)
SELECT SalesMonth,
		TotalSales,
		LAG(TotalSales) OVER (ORDER BY SalesMonth) AS PrevMonthSales,
		TotalSales - LAG(TotalSales) OVER (ORDER BY SalesMonth) AS ChangeFromPrevMonth
FROM MonthlySales 
ORDER BY SalesMonth