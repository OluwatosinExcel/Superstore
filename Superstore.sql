USE Updated_portfolio
-----------------------------------------DATA EXPLORATION------------------------------------------
-- View the imported table(Superstore)
SELECT *
FROM Superstore

-- How many Rows do we have in the dataset? (9994 rows)
SELECT COUNT(*) AS num_rows
FROM Superstore

-- How many Columns do we have in the dataset? (21 columns)
SELECT COUNT(*) AS num_columns
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'Superstore';

-----------------------------------------DATA CLEANING------------------------------------------
--Do we have null values in our dataset? (Yes)
SELECT *
FROM Superstore
WHERE Row_ID IS NULL OR Order_ID IS NULL OR Order_Date IS NULL OR Ship_Date IS NULL OR Ship_Mode IS NULL OR Customer_ID IS NULL 
OR Customer_Name IS NULL OR Segment IS NULL OR City IS NULL OR State IS NULL OR Postal_Code IS NULL 
OR Region IS NULL OR Product_ID IS NULL OR Category IS NULL OR Sub_Category IS NULL OR Product_Name IS NULL OR Sales IS NULL 
OR Quantity IS NULL OR Discount IS NULL OR Profit IS NULL

--There are 11rows with null values in the Postal_code column
--Checks for replacement for missing values
SELECT *
FROM PortfolioProject..Superstore
WHERE State = 'Vermont'

--Updating null values for Burlington Vermont to 05401.
UPDATE Superstore
SET postal_code = 05401
WHERE state = 'Vermont' AND city = 'Burlington' AND postal_code IS NULL;

--Postal_code updated as '5401' instead of '05401' stated. So I will update the data type for the postal_code column
ALTER TABLE Superstore
ALTER COLUMN postal_code VARCHAR(10);

--Adding leading zero to existing values
UPDATE Superstore
SET postal_code = RIGHT('00000' + postal_code, 5) 

--There are some incorrect postal_code in my data without leading zeros and having just 4 digits
--Checked for the Postal_code with 4 digits instead of 5 and checked google for confirmation
SELECT *
FROM Superstore
WHERE LEN(postal_code) = 4 AND postal_code IS NOT NULL;

--Updating the 4 digits with leading zeros to make it 5 digits.
UPDATE Superstore
SET postal_code = RIGHT('0000' + postal_code, 5)
WHERE LEN(postal_code) = 4 AND postal_code IS NOT NULL;

--Replacing the null value in the profit column with 0
UPDATE Superstore
SET Profit = 0
WHERE Row_ID = 7345 AND Profit IS NULL;

--Changed the datatype for Order_date column from datetime(2) to date.
ALTER TABLE Superstore
ALTER COLUMN order_date DATE;

--Do we have duplicate rows in our dataset? (Yes)
SELECT Order_ID, Order_Date, Ship_Date, Ship_Mode, Customer_ID, Customer_Name, Segment, Country_Region, City, State, Postal_Code, Region, Product_ID, Category, Sub_Category, Product_Name, Sales, Quantity, Discount, Profit, COUNT(*)
FROM Superstore
GROUP BY Order_ID, Order_Date, Ship_Date, Ship_Mode, Customer_ID, Customer_Name, Segment, Country_Region, City, State, Postal_Code, Region, Product_ID, Category, Sub_Category, Product_Name, Sales, Quantity, Discount, Profit
HAVING COUNT(*) > 1;

--Delete one of the rows to remove the duplicate
DELETE FROM Superstore
WHERE Row_ID = 3406;

-----------------------------------------DATA ANALYSIS------------------------------------------
--What are the total sales and profit across different regions?
SELECT 
    Region,
    COUNT(*) AS num_orders,
    SUM(Sales) AS total_sales,
    SUM(Profit) AS total_profit
FROM Superstore
GROUP BY Region
ORDER BY num_orders DESC;

--What is the monthly trend of sales and profit? Using CTE
WITH MonthlySales AS (
    SELECT 
        DATENAME(month, order_date) AS order_month,
		DATEPART(month, order_date) AS month_number,
        SUM(sales) AS total_sales,
		SUM(profit) AS total_profit
    FROM Superstore
    GROUP BY DATEPART(month, order_date), DATENAME(month, order_date)
)
SELECT 
    order_month,
    total_sales,
	total_profit
FROM MonthlySales
ORDER BY month_number

--What is the yearly sales trend from 2020-2023
SELECT 
    YEAR(Order_Date) AS order_year,
    SUM(Sales) AS total_sales
FROM Superstore
GROUP BY YEAR(Order_Date)
ORDER BY order_year;


--How does the shipping mode affect delivery times?
WITH MAX_SHIPDAYS AS (
    SELECT 
        Ship_Mode,
        DATEDIFF(day, Order_Date, Ship_Date) AS days_to_ship
    FROM Superstore
)
SELECT
    Ship_Mode,
    MAX(days_to_ship) AS Max_ship_days,
    MIN(days_to_ship) AS Min_ship_days,
    AVG(days_to_ship) AS Average_ship_days
FROM MAX_SHIPDAYS
GROUP BY Ship_Mode
ORDER BY Average_ship_days;

--Which segment generates the most and least revenue?
SELECT 
    Segment,
    SUM(Sales) AS total_sales
FROM Superstore
GROUP BY Segment
ORDER BY total_sales DESC;

--What are the most purchased product categories?
SELECT 
    Category,
    COUNT(*) AS num_products
FROM Superstore
GROUP BY Category
ORDER BY num_products DESC;
