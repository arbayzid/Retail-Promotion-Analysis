# Retail-Promotion-Analysis

#### A data analysis project on retail promotion in the FMCG domain, leveraging SQL and Power BI

![210844-P1YZBA-430](https://github.com/arbayzid/Retail-Promotion-Analysis/assets/146184500/e647bd54-cd24-448a-a49f-4b0fd6b1f7a0)

## Project Title
Retail Promotion Analysis at AtliQ Mart
## Domain
Fast-Moving Consumer Goods (FMCG)
## Function
Sales / Promotion

## Key dependencies
#### Stakeholders
- Bruce Haryali, Sales Director
- Tony Sharma, Analytics Manager
#### Project Team
- Peter Pandey, Data Analyst
- Tony Sharma, Analytics Manager

## Project Overview
AtliQ Mart, a leading retail chain in southern India, recently conducted extensive promotions on its own branded products during the festive periods of Diwali 2023 and Sankranti 2024. These promotions were held across all 50 of their supermarkets, aiming to boost sales and customer engagement during these culturally significant times in India. The Sales Director, Bruce Haryali, seeks to understand the success of these promotions to guide future strategies. Tony Sharma, the Analytics Manager, delegated this task to Peter Pandey, the data analyst.  This analysis should answer key questions such as:
- Which promotions performed well in terms of sales volume and revenue?
- Did certain product categories see a significant uplift in sales during the promotions?
- What types of promotions (discounts, bundle offers, etc.) were most effective?
- Are there any regional variations in promotion success across AtliQ Mart's store locations?

## Project Objective:
This data analysis project focuses on assessing the effectiveness of promotions on AtliQ Mart's branded products across their 50 supermarkets. By analyzing promotional data, the project aims to deliver actionable insights for the Sales Director to make informed decisions for future promotional strategies.

## Project Scope
This project focuses on analyzing the effectiveness of promotional strategies for AtliQ branded products. 

#### Inclusions:

- Analyze sales performance for AtliQ branded products during promotion periods compared to baseline data.
- Evaluate the impact of different promotion types (e.g., discounts, bundled offers) on sales.
- Assess product category performance (e.g., groceries, apparel) under the promotions.
- Explore regional variations in customer response to promotions, identifying any city- or store-level trends.

#### Exclusions:

- In-depth customer segmentation analysis (e.g., demographics, buying habits)
- Detailed marketing campaign effectiveness evaluation beyond promotions (e.g., social media impact)
- Building predictive models for future sales forecasting
- External market factors impacting sales (economic conditions, competitor promotions, etc.)

## Data Collection

Promotional sales data of AtliQ Mart branded products across all 50 supermarkets obtained from the internal database named "retail_events_db" includes the following tables:

- dim_campaigns: Contains information about promotional campaigns run by AtliQ Mart, including campaign IDs, names, start and end dates.
- dim_products: Provides details about the products sold, such as unique product codes, names, and categories.
- dim_stores: Includes data on AtliQ Mart store locations, with store IDs and corresponding cities.
- fact_events: Records sales events, linking store IDs, campaign IDs, and product codes to sales data like base prices, promotion types, and quantities sold.

## Data Preparation and Modeling:
The data was accessed from a MySQL database utilizing SQL queries, and it underwent extensive inspection to ensure quality and integrity. This inspection included checks for missing values, significant outliers, correct data types, and proper formatting.


The prepared data was then loaded into the Power BI environment for further transformation, such as creating calculated columns and potentially restructuring the data. Subsequently, relationships between the tables were established for effective data modeling and optimal analysis.

## Data Analysis


### Ad-hoc Requests


1. Provide a list of products with a base price greater than 500 and that are featured in promo type of 'BOGOF' (Buy One Get One Free). This information will help us identify high-value products that are currently being heavily discounted, which can be useful for evaluating our pricing and promotion strategies.
  
     
    - Query:
  ```
  SELECT 
  	DISTINCT dp.product_code, dp.product_name, fe.base_price
  FROM 
  	dim_products AS dp
  JOIN 
  	fact_events AS fe ON dp.product_code = fe.product_code
  WHERE
  	fe.base_price > 500
      		AND 
  			fe.promo_type = "BOGOF";
  ```
    - Query Output:
  
  ![image](https://github.com/arbayzid/Retail-Promotion-Analysis/assets/146184500/f3efc41f-eaaf-4946-a6d2-91a30f489a8a)



2.	Generate a report that provides an overview of the number of stores in each city. The results will be sorted in descending order of store counts, allowing us to identify the cities with the highest store presence. The report includes two essential fields: city and store count, which will assist in optimizing our retail operations.

  - Query:
```
SELECT 
	city,
    	count(store_id) as stores_count
FROM 
dim_stores
GROUP BY
	city
ORDER BY
	stores_count DESC;
```
  - Query Output:
 
![image](https://github.com/arbayzid/Retail-Promotion-Analysis/assets/146184500/b695d9af-9b12-4156-b797-3aa32c6a84a5)



