--viewing both tables to work with

SELECT * FROM dbo.foodprices

SELECT * FROM SQLPortfolio.dbo.priceindices

--DATA CLEANING

--Remove first row from both tables, because they contain not relevant data.

DELETE FROM SQLPortfolio.dbo.foodprices
WHERE Iso3 = 'NA'

DELETE FROM SQLPortfolio.dbo.priceindices
WHERE Iso3 = 'NA'

--Rename two column names in foodprices table for clarity

EXEC sp_rename 'SQLPortfolio.dbo.foodprices.admin1', 'state'

EXEC sp_rename 'SQLPortfolio.dbo.foodprices.admin2', 'LGA'

SELECT * FROM dbo.foodprices

--Standardize date format

SELECT date, CONVERT(Date, date)
FROM dbo.foodprices

UPDATE dbo.foodprices
SET date = CONVERT(Date, date)

ALTER TABLE dbo.foodprices
ADD datenew Date

UPDATE dbo.foodprices
SET datenew = CONVERT(Date, date)

SELECT * FROM dbo.foodprices

--Clean pricetype column. Change 'WHOSALE' to 'W' and RETAIL to 'R'

SELECT DISTINCT pricetype, 
COUNT(pricetype)
FROM dbo.foodprices
GROUP BY pricetype

SELECT pricetype
, CASE WHEN pricetype = 'Wholesale' THEN 'W'
	WHEN pricetype = 'Retail' THEN 'R'
	ELSE pricetype
	END
FROM dbo.foodprices

--Delete unused columns

ALTER TABLE dbo.foodprices
DROP COLUMN latitude, longitude, dateconverted

SELECT * FROM dbo.foodprices

--DATA PREPARATION

--looking at how many rows in the table

SELECT COUNT(*) FROM dbo.foodprices

--looking at the unique catgories of items/food

SELECT DISTINCT category 
FROM dbo.foodprices

SELECT COUNT(DISTINCT (category)) 
FROM dbo.foodprices

SELECT DISTINCT commodity 
FROM dbo.foodprices

SELECT COUNT(DISTINCT (commodity)) 
FROM dbo.foodprices
--there are 8 categories and 42 commodities

--DATA PREPARATION

--Return list and prices of non food items

SELECT commodity, price
FROM SQLPortfolio.dbo.foodprices
WHERE category = 'non-food'

--looking at the names of market where prices of goods greater than 100 for specific commodity

SELECT market, price
FROM SQLPortfolio.dbo.foodprices
WHERE price >= 100 AND commodity = 'Millet'


--checking states and LGA with highest prices of food

SELECT state, LGA, commodity, price
FROM SQLPortfolio.dbo.foodprices
ORDER BY price DESC
OFFSET 0 ROWS FETCH FIRST 10 ROWS ONLY

--Looking at commodities in price range between 100 and 200 in specific market

SELECT market, commodity
FROM SQLPortfolio.dbo.foodprices
WHERE price BETWEEN 100 AND 200
AND market LIKE '%gur%'

--performing some mathematical operations

SELECT category, SUM(price) AS totalprice
FROM SQLPortfolio.dbo.foodprices
GROUP BY category

--average price of maize accross different markets.
SELECT commodity, AVG(price) AS totalprice
FROM SQLPortfolio.dbo.foodprices
WHERE commodity = 'Maize'
GROUP BY commodity
HAVING AVG(price) >= 100

--looking at exchange rate between naira and USD in prices of goods

SELECT ROUND(usdprice/price * 100, 2)
AS exchangerate
FROM SQLPortfolio.dbo.foodprices
WHERE price != 0

--COMPARING PRICES OF GOODS WITH CONSUMER PRICE INDICES

SELECT commodity, price FROM SQLPortfolio.dbo.foodprices
JOIN SQLPortfolio.dbo.priceindices
ON SQLPortfolio.dbo.foodprices.unit = SQLPortfolio.dbo.priceindices.unit
WHERE SQLPortfolio.dbo.foodprices.price is null
OR commodity is null

