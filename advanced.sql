/*
 ************************
        ADVANCED
 ************************
 Description: Based on Seattle Data Guy
 Source: https://youtu.be/ztvxmGtrNA0?si=W9XMEzmxG2zdky_T
 
 */


/* Case Logic and when should it be a table
 * 
 * Are we repeating the logic in other queries?
 * Are we using SQL like an enumeration? (enumeration: act of mentioning a number of thigns one by one)
 * 
 * Case clauses are very useful. However, there are two specific ways that some people use them that can bite you later in the future.
 * 
 * First, duplicative logic.
 * 
 * What do we mean by duplicative logic? 
 * We mean using the same case statement in multiple queries, views, and pipelines.
 * 
 * You can look at the gist link below to see the queries. 
 * In them we have the same logic in multiple places. 
 * In this case in an ad-hoc query that is used in a data analyses analysis they repeat every month and in a BI developers Tableau dashboard.
 * 
 * Now, let's imagine the logic for the category needs to be updated for any reason. 
 * You might not even know all the places an update needs to occur. 
 * What if different teams are managing all of these different queries.
 * 
 * Who is going to tell them to update it and how will you inform them of the change?
 * 
 * Not every company has great tools to help find repetitive logic like this.
 * 
 * Another similar issue is engineers decide they want to use case statements as enumerations vs using a table. 
 * This is also in the gist code example.
 * 
 * What you will notice is that they are essentially checking an ID and providing a value for said ID. 
 * 
 * The problem here is, what if you want to add a new ID? 
 * Then you need to edit the code.
 * 
 */

--this query is being used in a tableau dashboard by a BI Developer
SELECT patient_id
	,total_cost DATE
	,CASE 
		WHEN PROCEDURE_CODE  BETWEEN '9990'
				AND '10000'
			AND age BETWEEN 30
				AND 40
			THEN 'category 1'
		WHEN PROCEDURE_CODE BETWEEN '9980'
				AND '9990'
			AND age BETWEEN 40
				AND 50
			THEN 'category 2'
		ELSE 'No Category'
		END
FROM patient_claims


-- this query is an adhoc query just meant to filter out category 2 by a data analyst on a different team
SELECT patient_id
	,total_cost DATE
FROM patient_claims
WHERE PROCEDURE_CODE BETWEEN '9980'
		AND '9990'
	AND age BETWEEN 40
		AND 50

/*  
 * Description: AdventureWorks Dataset
 * Source: https://github.com/Microsoft/sql-server-samples/releases/tag/adventureworks
*/

USE AdventureWorks2022	

-- skimming through data...
SELECT TOP 10 *
FROM AdventureWorks2022.HumanResources.Employee

-- recursive CTEs to navigate organization hierarchy 

WITH EmployeeHierarchy AS (
	SELECT BusinessEntityID,
		JobTitle,
		OrganizationLevel,
		0 AS HierarchyLevel
	FROM AdventureWorks2022.HumanResources.Employee
	WHERE OrganizationLevel IS NULL 
	
	UNION ALL
	
	SELECT 
		e.BusinessEntityID,
		e.JobTitle,
		e.OrganizationLevel,
		eh.HierarchyLevel + 1
	FROM AdventureWorks2022.HumanResources.Employee e
	JOIN EmployeeHierarchy eh
		ON e.OrganizationLevel = eh.BusinessEntityID
		)
SELECT *
FROM EmployeeHierarchy 
ORDER BY HierarchyLevel, OrganizationLevel

-- advanced window functions for sales performance ranking 

	
		