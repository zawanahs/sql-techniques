/*
 *****************
       BASIC
 *****************
 Description: Based on data of Nobel Laureates
 Source: https://sqlzoo.net/wiki/SELECT_from_Nobel_Tutorial
 */

-- select conditions based on column

SELECT yr, subject, winner
FROM nobel 
WHERE yr = 1950


SELECT yr, subject, winner
FROM nobel 
WHERE yr = 1950
AND subject = 'literature'


SELECT yr, subject, winner
FROM nobel 
WHERE winner = 'Albert Einstein'


-- use LIKE for extracting records that include a certain part of the entry and use % as  wildcard character

SELECT winner
FROM nobel
WHERE subject LIKE '%peace%' AND yr >= 2000

select winner 
from nobel
where winner like 'John%'


-- using BETWEEN vs OPERATORS >=/<= (Note: Between is NOT inclusive of the numbers ie. BETWEEN 20 AND 30 starts with 21 and ends with 29.)

select yr, subject, winner 
from nobel
where yr >= 1980 and yr <= 1989 and subject = 'literature'

-- using IN/NOT IN to extract just the data for certain conditions

SELECT * 
FROM nobel
where winner in ('Theodore Roosevelt',
    'Thomas Woodrow Wilson',
    'Jimmy Carter',
    'Barack Obama'
)


select yr, subject, winner
from nobel
where yr = 1980 and subject NOT IN ('chemistry', 'medicine')


-- use AND/OR for multiple conditions (Note: AND takes precedence over OR. Best practice is to use parantheses if using multiple ANDs or ORs)

select yr, subject, winner
from nobel
where subject = 'physics' and yr = 1980 OR subject = 'chemistry' and yr = 1984


-- non-ASCII characters (Easy solution: google the character and copy paste in query)

select *
from nobel
where winner = 'Peter Grünberg'

-- escape single quotes by adding one more single quote

select *
from nobel
where winner = 'Eugene O''Neill'

-- sorting by column in ascending or descending order. Note: default is ascending

select winner, yr, subject
from nobel
where winner LIKE 'Sir%'
order by yr desc, winner asc

-- using case when for boolean logic condition in order

SELECT winner, subject
FROM nobel
WHERE yr=1984
ORDER BY 
CASE 
	WHEN subject IN ('physics','chemistry') THEN 1 
	ELSE 0 
END,subject,winner


/*
 Description: Based on world country data
 Source: https://sqlzoo.net/wiki/SELECT_within_SELECT_Tutorial
 */

/* Notes
nested select or subqueries. if subquery is in FROM, must use an alias. it's good practice to use an alias for each subquery.
 */

SELECT name 
FROM world 
WHERE continent = (SELECT continent FROM world WHERE name = 'Brazil')


--List each country name where the population is larger than that of 'Russia'.
SELECT name 
FROM world
WHERE population >
     (SELECT population 
      FROM world
      WHERE name='Russia')
      
--Show the countries in Europe with a per capita GDP greater than 'United Kingdom'.
SELECT name
FROM world
WHERE continent = 'Europe' AND gdp/population > (SELECT gdp/population FROM world WHERE name = 'United Kingdom')


--Which country has a population that is more than United Kingdom but less than Germany? Show the name and the population.
select name,population
from world
where population > (select population from world where name = 'United Kingdom') 
AND population < (select population from world where name = 'Germany')

/* Notes
use IN for when subquery returns > 1 results
*/

SELECT name, continent 
FROM world
WHERE continent IN
  (SELECT continent 
     FROM world 
     WHERE name='Brazil'
        OR name='Mexico')

--List the name and continent of countries in the continents containing either Argentina or Australia. Order by name of the country.
SELECT name, continent
FROM world
WHERE continent IN 
(SELECT continent
FROM world
WHERE name = 'Argentina' OR name = 'Australia')

/* Notes
using subquery on select line for only if there is only one value returned
*/   
 SELECT
 population/(SELECT population FROM world
             WHERE name='United Kingdom') AS pop_rel_uk
  FROM world
WHERE name = 'China'

/* Notes
using ALL or ANY where query on the right side has multiple values and you want to add all
*/

SELECT name
FROM world
WHERE population > ALL
      (SELECT population 
       FROM world
       WHERE continent='Europe')
       
       
/* Notes
use CONCAT to add a symbol. use ROUND to doing to specific decimal places.
*/
        
 --Show the name and the population of each country in Europe. Show the population as a percentage of the population of Germany.
SELECT name, 
       CONCAT(ROUND(population/(SELECT population 
                          FROM world 
                          WHERE name = 'Germany')*100,0),'%') as percentage
FROM world
WHERE continent = 'Europe'


      
      

