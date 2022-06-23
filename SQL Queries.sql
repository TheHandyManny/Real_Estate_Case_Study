#1. Create a database called `house_price_regression`.
-- Used MySQL to just create a new schema

#2 2. Create a table `house_price_data` with the same columns as given in the csv file. Please make sure you use the correct data types for the columns.

-- All of the dtypes were compated against dtypes of dataframe using jupyter.
use house_price_regression;

CREATE TABLE house_price_data(
id bigint,
sell_date date,
bedrooms int,
bathrooms float,	
sqft_living int,	
sqft_lot int,	
floors float,	
waterfront int,	
good_view int,	
house_condition int,	
grade int,	
sqft_above int,	
sqft_basement int,	
yr_built int,	
yr_renovated int,	
zipcode int,	
lat_pos float,
long_pos float,	
sqft_living15 int,	
sqft_lot15 int,	
price int);

#3 Import the data from the csv file into the table. Before you import the data into the empty table, make sure that you have deleted the headers from the csv file. To not modify the original data, 
#  if you want you can create a copy of the csv file as well. Note you might have to use the following queries to give permission to SQL to import data from csv files in bulk.

use house_price_regression;
SET GLOBAL local_infile = 1;
-- Had to make a connection variable to finish importing this.
LOAD DATA LOCAL INFILE 'E:/Ironhack/Projects/Real Estate Case Study/data_mid_bootcamp_project_regression/regression_data.csv' INTO TABLE house_price_data
FIELDS TERMINATED BY ',';

-- To simplify the process I will be creating

#4.  Select all the data from table `house_price_data` to check if the data was imported correctly
SELECT * from house_price_data;
SELECT COUNT(*) from house_price_data;

#5.  Use the alter table command to drop the column `date` from the database, as we would not use it in the analysis with SQL. Select all the data from the table to verify if the command worked. Limit your returned results to 10.
ALTER TABLE house_price_data
DROP COLUMN sell_date;

#6.   Use sql query to find how many rows of data you have.
SELECT COUNT(*) from house_price_data;

/*
7.  Now we will try to find the unique values in some of the categorical columns:
    - What are the unique values in the column `bedrooms`?
    - What are the unique values in the column `bathrooms`?
    - What are the unique values in the column `floors`?
    - What are the unique values in the column `condition`?
    - What are the unique values in the column `grade`?
*/

SELECT distinct bedrooms from house_price_data order by 1 desc;
SELECT distinct bathrooms from house_price_data order by 1 desc;
SELECT distinct floors from house_price_data order by 1 desc;
SELECT distinct house_condition from house_price_data order by 1 desc;
SELECT distinct grade from house_price_data order by 1 desc;

# 8.  Arrange the data in a decreasing order by the price of the house. Return only the IDs of the top 10 most expensive houses in your data.
SELECT id, price FROM house_price_data
ORDER BY price DESC
LIMIT 10;

#9.  What is the average price of all the properties in your data?
-- 540296.5735
SELECT AVG(price) from house_price_data; 

/*
10. In this exercise we will use simple group by to check the properties of some of the categorical variables in our data
    - What is the average price of the houses grouped by bedrooms? The returned result should have only two columns, bedrooms and Average of the prices. Use an alias to change the name of the second column.
    - What is the average `sqft_living` of the houses grouped by bedrooms? The returned result should have only two columns, bedrooms and Average of the `sqft_living`. Use an alias to change the name of the second column.
    - What is the average price of the houses with a waterfront and without a waterfront? The returned result should have only two columns, waterfront and `Average` of the prices. Use an alias to change the name of the second column.
    - Is there any correlation between the columns `condition` and `grade`? You can analyse this by grouping the data by one of the variables and then aggregating the results of the other column. Visually check if there is a positive correlation or negative correlation or no correlation between the variables.
*/

SELECT bedrooms, AVG(price) AS "average_house_price_by_bedroom_count"
FROM  house_price_data
GROUP BY bedrooms
ORDER BY bedrooms DESC;

SELECT bedrooms, AVG(sqft_living) AS "average_living_footage_by_bedroom_count"
FROM  house_price_data
GROUP BY bedrooms
ORDER BY bedrooms DESC;

SELECT waterfront, AVG(price) AS "average_price_based_on_waterfront"
FROM house_price_data
GROUP BY waterfront
ORDER BY waterfront DESC;

/*
11. One of the customers is only interested in the following houses:

    - Number of bedrooms either 3 or 4
    - Bathrooms more than 3
    - One Floor
    - No waterfront
    - Condition should be 3 at least
    - Grade should be 5 at least
    - Price less than 300000

    For the rest of the things, they are not too concerned. Write a simple query to find what are the options available for them?
    */
    
SELECT *
FROM house_price_data
WHERE price < 300000
AND grade >= 5
AND house_condition >= 3
AND waterfront = 0
AND floors = 1
AND bathrooms > 3
AND bedrooms in (3,4);

#12. Your manager wants to find out the list of properties whose prices are twice more than the average of all the properties in the database. Write a query to show them the list of such properties. You might need to use a sub query for this problem.
SELECT id, price
FROM house_price_data
WHERE price > (SELECT AVG(price) FROM house_price_data);

#13. Since this is something that the senior management is regularly interested in, create a view of the same query.
CREATE VIEW Houses_over_double_average AS
SELECT id, price
FROM house_price_data
WHERE price > (SELECT AVG(price) FROM house_price_data);

#14. Most customers are interested in properties with three or four bedrooms. What is the difference in average prices of the properties with three and four bedrooms?
with averages as 
(
select bedrooms, avg(price) as average_price
from house_price_data
WHERE bedrooms in (3,4)
GROUP BY bedrooms
ORDER BY bedrooms ASC
)

select MAX(average_price) - MIN(average_price) from averages;

#15. What are the different locations where properties are available in your database? (distinct zip codes)
SELECT DISTINCT(zipcode) from house_price_data;

#16. Show the list of all the properties that were renovated.
select * 
from house_price_data
WHERE yr_renovated > 0;

#17. Provide the details of the property that is the 11th most expensive property in your database.
select *
from(
select *, dense_rank() OVER (ORDER BY price DESC) as price_ranking
from house_price_data
) sub
WHERE price_ranking = 11;