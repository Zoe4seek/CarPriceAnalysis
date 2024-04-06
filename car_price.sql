# CREATE a new dataset, kaggle_car_sales.analyz_car_prices, for practice purpuse

create database kaggle_car_sales;
use kaggle_car_sales;
CREATE TABLE analyz_car_prices AS
SELECT * FROM
    365_database.car_prices;
    
# check how many NULL values there if any - it seems like none

SELECT 
    COUNT(CASE
        WHEN year IS NULL THEN 1
    END) AS year_missing_count,
    COUNT(CASE
        WHEN make IS NULL THEN 1
    END) AS make_missing_count,
    COUNT(CASE
        WHEN model IS NULL THEN 1
    END) AS model_missing_count,
    COUNT(CASE
        WHEN trim IS NULL THEN 1
    END) AS trim_missing_count,
    COUNT(CASE
        WHEN body IS NULL THEN 1
    END) AS body_missing_count,
    COUNT(CASE
        WHEN transmission IS NULL THEN 1
    END) AS transmission_missing_count,
    COUNT(CASE
        WHEN vin IS NULL THEN 1
    END) AS vin_missing_count,
    COUNT(CASE
        WHEN state IS NULL THEN 1
    END) AS state_missing_count,
    COUNT(CASE
        WHEN 'condition' IS NULL THEN 1
    END) AS condition_missing_count,
    COUNT(CASE
        WHEN odometer IS NULL THEN 1
    END) AS odometer_missing_count,
    COUNT(CASE
        WHEN color IS NULL THEN 1
    END) AS color_missing_count,
    COUNT(CASE
        WHEN interior IS NULL THEN 1
    END) AS interior_missing_count,
    COUNT(CASE
        WHEN seller IS NULL THEN 1
    END) AS seller_missing_count,
    COUNT(CASE
        WHEN mmr IS NULL THEN 1
    END) AS mmr_missing_count,
    COUNT(CASE
        WHEN sellingprice IS NULL THEN 1
    END) AS sellingprice_missing_count,
    COUNT(CASE
        WHEN saledate IS NULL THEN 1
    END) AS saledate_missing_count
FROM
    analyz_car_prices;

# However, there are some empty string or whitespace values in the table as we look into it.
# For example, there are 10,309 out of 546,976 records do not have 'make' or 'medel' inofrmaiton. Need to make sure the accurcy of the data when conduct relevent analysis.

SELECT *
FROM analyz_car_prices
WHERE LENGTH(make) = 0 OR LENGTH(model) = 0;

---------------------------------------------------------------------------------------------------------------------------------------------------------------

SELECT make, model, AVG(sellingprice) AS avg_selling_price,
       MIN(sellingprice) AS min_selling_price,
       MAX(sellingprice) AS max_selling_price,
       COUNT(*) AS num_vehicles
FROM analyz_car_prices
WHERE LENGTH(make) > 0 AND LENGTH(model) > 0 
GROUP BY make, model
ORDER BY make, model;

##-------To keep the dataset's authenity, I use temporary tables for analysis purpose.
# 1) Look at the relationship between year of manufacturing and price; * Note, there are a few selling_price value shows $1. I excluded these records first by conduct 

CREATE TEMPORARY TABLE temp_analysis_table AS
	SELECT
		year,
		mmr, 
		sellingprice
	FROM analyz_car_prices
	WHERE sellingprice > 1;
	#--There were 3 records found with $1.
    
# 	--- Then, we can use this CLEANED temp table to conduct the analysis.
SELECT 
    year,
    AVG(mmr),
    AVG(sellingprice),
    MIN(sellingprice) AS min_selling_price,
    MAX(sellingprice) AS max_selling_price,
    COUNT(*) AS num_vehicles
FROM
    temp_analysis_table
GROUP BY year
ORDER BY year DESC;

DROP TABLE IF EXISTS temp_analysis_table;


 # ---  2) Study the relationship between make and model with selling price and also you see how the price is changing with year
 #      * Note: There are some make and model values that are empty in the dataset. Againd, I'm going to use temp a table to excule the invalid data.
 
 CREATE TEMPORARY TABLE temp_makemodel_price_final AS
	SELECT
		make,
		model, 
		sellingprice
	FROM analyz_car_prices
	WHERE make <> 0 or model <> 0;       #---- the temp table contains 30931 rows.
Select * from 
temp_makemodel_price_f;
	
Drop table if exists temp_makemodel_price2;
Drop table if exists temp_makemodel_price_final;
# 	--- Then, we can use this CLEANED temp table to conduct the analysis of relationship between make, model and price.
# Note: Upon execution of the quary, I spot a few records like model of BMW shows 1, apparently, this should be corrected to 1 Series.
# so I went back to the origianl dataset and did some data cleaning. 

SELECT 
    make,
    model,
    AVG(sellingprice),
    MIN(sellingprice) AS min_selling_price,
    MAX(sellingprice) AS max_selling_price,
    COUNT(*) AS num_vehicles
FROM
    temp_makemodel_price_final
GROUP BY make , model
ORDER BY make;

# --- data cleaning: for BMW 1 change to 1 Series, 320!,323!,328! change to 3 Series as there was only 1 car for each;
SET SQL_SAFE_UPDATES = 0;
UPDATE analyz_car_prices
SET model = 
    CASE 
        WHEN model = '1' THEN '1 Series'
        WHEN model = '7' THEN '7 Series'
        WHEN model IN ('320i', '323i', '328i') THEN '3 Series'
        ELSE model 
    END;
SET SQL_SAFE_UPDATES = 1;
# There are 6 rows changed.

# --- Create a new temp table as the data updated, and re run the quary to study the relationship. There are 56 rows returned.
