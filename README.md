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


1.  Provide a list of products with a base price greater than 500 and that are featured in promo type of 'BOGOF' (Buy One Get One Free). This information will help us identify high-value products that are currently being heavily discounted, which can be useful for evaluating our pricing and promotion strategies.
  
     
    - Query:
      ```
      SELECT DISTINCT
    	dp.product_code,
    	dp.product_name,
    	fe.base_price
      FROM dim_products AS dp
    	JOIN fact_events AS fe
          ON dp.product_code = fe.product_code
      WHERE fe.base_price > 500
        AND fe.promo_type = "BOGOF";
      ```
    - Query Output:
  
      ![image](https://github.com/arbayzid/Retail-Promotion-Analysis/assets/146184500/f3efc41f-eaaf-4946-a6d2-91a30f489a8a)

2.  Generate a report that provides an overview of the number of stores in each city. The results will be sorted in descending order of store counts, allowing us to identify the cities with the highest store presence. The report includes two essential fields: city and store count, which will assist in optimizing our retail operations.

    - Query:
      ```
      SELECT city,
             count(store_id) as stores_count
      FROM dim_stores
      GROUP BY city
      ORDER BY stores_count DESC;
      ```
    - Query Output:
 
      ![image](https://github.com/arbayzid/Retail-Promotion-Analysis/assets/146184500/b695d9af-9b12-4156-b797-3aa32c6a84a5)

3. Generate a report that displays each campaign along with the total revenue generated before and after the campaign? The report includes three key fields: campaign_name, total_revenue(before_promotion), total_revenue(after_promotion). This report should help in evaluating the financial impact of our promotional campaigns. (Display the values in millions)
     - Query:
  	```
  	WITH discounted_events
  	AS (SELECT fe.campaign_id,
                   fe.base_price,
                   fe.quantity_sold_before_promo,
                   fe.quantity_sold_after_promo,
                   CASE
                       WHEN fe.promo_type = "50% OFF" THEN
                           ROUND(fe.base_price * (1 - 0.5))
                       WHEN fe.promo_type = "BOGOF" THEN
                           ROUND(fe.base_price * (1 - 0.5))
                       WHEN fe.promo_type = "25% OFF" THEN
                           ROUND(fe.base_price * (1 - 0.25))
                       WHEN fe.promo_type = "500 Cashback" THEN
                           (fe.base_price - 500)
                       WHEN fe.promo_type = "33% OFF" THEN
                           ROUND(fe.base_price * (1 - 0.33))
                       ELSE
                           fe.base_price -- No discount
                   END AS discounted_price
             FROM fact_events fe
            )
	SELECT dc.campaign_name,
               CONCAT(FORMAT(SUM((fe.base_price * fe.quantity_sold_before_promo) / 1000000), 2), " M") AS total_revenue_before_promo,
               CONCAT(FORMAT(SUM((fe.discounted_price * fe.quantity_sold_after_promo) / 1000000), 2), " M") AS total_revenue_after_promo
	FROM dim_campaigns dc
               JOIN discounted_events fe
                   ON dc.campaign_id = fe.campaign_id
	GROUP BY dc.campaign_name;
	```
	- Query Output:

	![image](https://github.com/arbayzid/Retail-Promotion-Analysis/assets/146184500/25b5e8f6-d9f7-48d6-a820-c0bc945562ca)

4. Produce a report that calculates the Incremental Sold Quantity (ISU%) for each category during the Diwali campaign. Additionally, provide rankings for the categories based on their ISU%. The report will include three key fields: category, isu%, and rank order. This information will assist in assessing the category-wise success and impact of the Diwali campaign on incremental sales.
Note: ISU% (Incremental Sold Quantity Percentage) is calculated as the percentage increase/decrease in quantity sold (after promo) compared to quantity sold (before promo)

    - Query:
       ```
    	  WITH DiwaliSales
     	  AS (SELECT dp.category,
              SUM(quantity_sold_before_promo) AS sales_before_promo,
              SUM(quantity_sold_after_promo) AS sales_after_promo
     	  FROM dim_products dp
     	      JOIN fact_events fe
      	          ON dp.product_code = fe.product_code
              JOIN dim_campaigns dc
                  ON dc.campaign_id = fe.campaign_id
     	  WHERE dc.campaign_name = "Diwali"
     	  GROUP BY dp.category
        	)
     	  SELECT ds.category,
              ROUND(((ds.sales_after_promo - ds.sales_before_promo) / ds.sales_before_promo) * 100, 2) AS isu_percentage,
              DENSE_RANK() OVER (ORDER BY ((ds.sales_after_promo - ds.sales_before_promo) / ds.sales_before_promo) DESC) AS rank_order
     	  FROM DiwaliSales ds
     	  ORDER BY rank_order;
       ```

    - Query Output:
     
      ![image](https://github.com/arbayzid/Retail-Promotion-Analysis/assets/146184500/40316faf-c7c5-4f38-858f-e535504eb0bd)

5. Create a report featuring the Top 5 products, ranked by Incremental Revenue Percentage (IR%), across all campaigns. The report will provide essential information including product name, category, and ir%. This analysis helps identify the most successful products in terms of incremental revenue across our campaigns, assisting in product optimization.

    - Query:
         ```
	      WITH ProductRevenue AS (
	          SELECT fe.product_code,
	                 fe.base_price,
	                 fe.quantity_sold_before_promo,
	                 fe.quantity_sold_after_promo,
	                 CASE
	                     WHEN fe.promo_type = '50% OFF' THEN ROUND(fe.base_price * (1 - 0.5))
	                     WHEN fe.promo_type = 'BOGOF' THEN ROUND(fe.base_price * (1 - 0.5))
	                     WHEN fe.promo_type = '25% OFF' THEN ROUND(fe.base_price * (1 - 0.25))
		             WHEN fe.promo_type = '500 Cashback' THEN (fe.base_price - 500)
		             WHEN fe.promo_type = '33% OFF' THEN ROUND(fe.base_price * (1 - 0.33))
		             ELSE fe.base_price  -- No discount
		             END AS discounted_price
	          FROM fact_events fe
	      )
	
	      SELECT dp.product_name,
	             dp.category,
	             ROUND(((SUM(pr.discounted_price* pr.quantity_sold_after_promo) - SUM(pr.base_price * pr.quantity_sold_before_promo))/SUM(pr.base_price * pr.quantity_sold_before_promo))*100,2) AS IR_percentage
	      FROM dim_products dp
	          JOIN ProductRevenue pr
	              ON dp.product_code = pr.product_code
	      GROUP BY dp.product_name, 
	               dp.category
	      ORDER BY IR_percentage DESC
	      LIMIT 5;
        ```
         
    - Query Output:
   
      ![image](https://github.com/arbayzid/Retail-Promotion-Analysis/assets/146184500/9c7f4b2d-c527-4d81-9b5d-d62747ff4a40)

## Dashboard Design and Development

Design and mock-up of a user-friendly dashboard have been developed using Figma to incorporate relevant metrics and visualizations, Segmented analysis by city, store, promotion, category, and product for deeper insights, providing a comprehensive overview of performance in revenue and sales growth.
The dashboard comprises the following components:

- ### Key Performance Indicators (KPI)
Designed a dashboard with key performance indicators (KPIs) such as revenue and sales during promotional period along with growth and growth percentage.


- ### Charts

#### Overall Analysis:

1.	Two Card Visuals: One card-visual displays absolute revenue and revenue growth. Another depicts absolute sales and sales growth. 
2.	Pie Charts for Campaign Comparisons: Two pie-chart depicts revenue and sales growth during the Diwali and Sankranti campaigns.
3.	Bar Charts for Top Performers: Five bar charts showcase the top performers in revenue growth. Five additional bar charts highlight the top performers in sales growth.
#### City Analysis:

1.	Two column charts visualize revenue and sales growth along with growth percentage, for each city.
2.	table provides a breakdown of the city analysis, detailing key metrics for each location.
3.	A scatter plot explores the relationship between IR% and ISU% across different cities.

#### Store Analysis:
1.	Two customized column charts display the top 5 performers with others based on IR and ISU. 
2.	Two table shows top and bottom stores based on IR% and ISU% respectively.
3.	A scatter plot explores the relationship between IR% and ISU% across different cities.

#### Promotion Analysis:
1.	Two customized bar chart depict absolute revenue and sales during promotional period alongside their growth percentage.
2.	A clustered bar chart compares IR% and ISU% 
3.	A table shows promotional details across different promotions, allowing for easy identification of the most effective ones.

#### Category Analysis:
1.	Two area chart visualize absolute revenue and sales throughout promotional period compared to the non-promotional period.
2.	A column chart shows comparison between IR% and ISU%, for each category.
3.	A table provides a breakdown of the city analysis, detailing key metrics for each category.

#### Product Analysis:

1.	Two customized column charts depict the top 5 performers alongside others based on Incremental Revenue (IR) and Incremental Sales Units (ISU).
2.	A table presents a detailed breakdown of the product analysis, outlining key metrics for each product.



- ### Unique Feature
The dashboard features advanced, customizable charts alongside a collapsible filter panel offering user-friendly options based on Campaign, City, Stores, Promotion, Category, and Product.

## Key Insights

#### City Analysis:
1.	Bengaluru and Chennai are the two most important cities. They ranked the highest in both Incremental Revenue (IR) and Incremental Sales Units (ISU). They also showed significant growth in terms of percentage increase in sales (ISU%) and percentage increase in revenue (IR%).
2.	Vijayawada and Trivandrum ranked the lowest in both IR and ISU, though they showed moderate growth in terms of percentage increase in sales (ISU%) and percentage increase in revenue (IR%).
3.	Madurai stood out with the highest increase in both IR% and ISU%, indicating strong growth potential.
4.	Mysuru showed impressive IR% growth with moderate ISU%.
5.	Mangalore and Visakhapatnam's performance fell behind in terms of IR% and ISU%.

#### Store Analysis:
1.	IR% and ISU% increased proportionally for most Atliq Mart stores.
2.	The STMYS-1 shop in Mysuru showed excellent performance in every metrics, becoming top performer in IR and ISU%.
3.	Top 5 store made only 16.3% of the total incremental revenue and 14.7% of the total incremental sales.
4.	The shop STVSK-3, STHYD-1, and STCHE-1 lagged behind other stores in sales growth.

#### Promotion Analysis:
1.	the "500 Cashback" and "BOGOF" promotions emerged as the most effective in driving sales and revenue growth. Considering their strong performance, the "500 Cashback" and "BOGOF" promotions should be prioritized in future marketing strategies.
2.	The "500 Cashback" promotion stands out as the most successful overall, driving the highest absolute revenue, incremental revenue, and incremental revenue percentage.
3.	The "BOGOF" offer excels in sales, generating the most absolute sales, incremental sales, and growth in sales volume (ISU%).
4.	The "33% off" promotion, while increasing sales by over 27,000 units, resulted in a revenue decrease compared to the non-promotional period. This suggests a need to optimize the discount rate for better profitability.
5.	The "25% off" and "50% off" promotions underperformed across all metrics, indicating they were less effective in driving sales and revenue growth.

#### Category Analysis:
1.	The "Combo1" category emerged as the leader in revenue generation, boasting the highest absolute revenue, incremental revenue, and incremental revenue percentage.
2.	The “Home Appliances” category achieved impressive growth, ranking first in Increase in Sales Units (ISU%) and second in Revenue Increase (IR%).
3.	As expected, Grocery and Staples led in sales volume, but its contribution to overall revenue growth and sales growth percentage was lower than most other categories.
4.	The Personal Care category underperformed significantly. Despite a slight increase in sales, revenue dropped by over 35% compared to the non-promotional period.

#### Product Analysis:
1.	A staggering 85% of the incremental revenue boost came from the Atliq_Home_Essential_8_Product_Combo alone.
2.	Top 3 products contributed a significant portion, nearly 60%, to the total increase in sales during the promotion.
3.	Most products experienced a decline in revenue growth percentage, despite having an increase in sales growth percentage.


## Recommendations

#### City Analysis:
1.	Focus on Bengaluru and Chennai: These cities are crucial for incremental revenue and sales units. Invest more resources and tailor promotions to these markets.

2.	Strategies for Vijayawada and Trivandrum: Despite lower performance, moderate growth suggests potential. Consider targeted promotions or campaigns to boost sales in these cities.

3.	Maximize Potential in Madurai: With the highest increase in both IR% and ISU%, Madurai shows strong growth potential. Explore expanding offerings or marketing efforts here.

4.	Capitalizing on Mysuru's Impressive IR% Growth: Leverage Mysuru's growth by analyzing what drove the success at STMYS-1 and applying similar strategies to other stores.

5.	Improvement Opportunities for Mangalore and Visakhapatnam: Identify reasons behind their lagging performance and adjust marketing tactics accordingly.

#### Store Analysis:
1.	Continued Improvement for Most Atliq Mart Stores: Stores showing proportional growth in IR% and ISU% are on the right track. Maintain strategies that have worked well.

2.	Recognizing Top Performers like STMYS-1: Highlight and share best practices from stores like STMYS-1 to inspire others and maintain their success.

3.	Diversification Beyond Top 5 Stores: While top 5 stores contributed significantly, diversify efforts to boost performance across all stores for sustained growth.

4.	Addressing Sales Growth for STVSK-3, STHYD-1, STCHE-1: Investigate reasons for lagging sales growth and implement targeted improvements.

#### Promotion Analysis:
1.	Prioritize "500 Cashback" and "BOGOF" Promotions: These have proven to be most effective. Allocate more resources and marketing efforts towards these promotions in the future.

2.	Optimization of "33% off" Promotion: Despite driving sales, revenue decrease suggests a need to adjust the discount rate for better profitability.

3.	Reassess "25% off" and "50% off" Promotions: Since these underperformed, consider revising or replacing them with more effective promotions.

#### Category Analysis:
1.	Leverage "Combo1" Category Leadership: This category is a revenue leader; consider expanding offerings or promotions within this category.

2.	Maximize "Home Appliances" Category Growth: Capitalize on the impressive growth of this category, especially in ISU%.

3.	Strategies for Grocery and Staples: While these categories lead in sales volume, explore ways to increase their contribution to overall revenue growth.

4.	Improving Performance in Personal Care Category: Address the significant revenue drop in this category with targeted promotions or product adjustments.

#### Product Analysis:
1.	Focus on Atliq_Home_Essential_8_Product_Combo: This product alone contributed significantly to incremental revenue. Ensure it remains a key focus.

2.	Optimize Top 3 Products' Impact: Since they contribute a large portion to total sales, ensure they are prominently featured in promotions and marketing.

3.	Revise Strategies for Declining Products: Products with declining revenue growth despite sales growth need revised marketing strategies or adjustments.


## Conclusion
Through this comprehensive data analysis project, the Sales Director will gain invaluable insights into the effectiveness of AtliQ Mart's current promotional strategies. Armed with a thorough understanding of the performance metrics across cities, stores, promotions, categories, and products, the Sales Director will be well-equipped to make data-driven decisions for future marketing campaigns, ultimately boosting sales and profitability for AtliQ Mart's branded products.






