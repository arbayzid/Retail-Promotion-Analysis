/*1.	Provide a list of products with a base price greater than 500 
and that are featured in promo type of 'BOGOF' (Buy One Get One Free).*/

SELECT 
	DISTINCT dp.product_code,
    dp.product_name, 
    fe.base_price
FROM 
	dim_products AS dp
JOIN 
	fact_events AS fe ON dp.product_code = fe.product_code
WHERE 
	fe.base_price > 500 AND fe.promo_type = "BOGOF";
            
/*2.	Generate a report that provides an overview of the number of stores in each city. 
The results will be sorted in descending order of store counts, allowing us to identify the cities with the highest store presence. 
The report includes two essential fields: city and store count, which will assist in optimizing our retail operations.*/

SELECT 
	city,
    count(store_id) as stores_count
FROM 
	dim_stores
GROUP BY
	city
ORDER BY
	stores_count DESC;

/*3. Generate a report that displays each campaign along with the total revenue generated before and after the campaign?
The report includes three key fields: campaign_name, total_revenue(before_promotion), total_revenue(after_promotion).
This report should help in evaluating the financial impact of our promotional campaigns. (Display the values in millions)*/

WITH discounted_events AS (
    SELECT
        fe.campaign_id,
        fe.base_price,
        fe.quantity_sold_before_promo,
        fe.quantity_sold_after_promo,
        CASE
            WHEN fe.promo_type = "50% OFF" THEN ROUND(fe.base_price * (1 - 0.5))
            WHEN fe.promo_type = "BOGOF" THEN ROUND(fe.base_price * (1 - 0.5))
            WHEN fe.promo_type = "25% OFF" THEN ROUND(fe.base_price * (1 - 0.25))
            WHEN fe.promo_type = "500 Cashback" THEN (fe.base_price - 500)
            WHEN fe.promo_type = "33% OFF" THEN ROUND(fe.base_price * (1 - 0.33))
            ELSE fe.base_price  -- No discount
        END AS discounted_price
    FROM
        fact_events fe
)

SELECT
    dc.campaign_name,
    CONCAT(FORMAT(SUM((fe.base_price * fe.quantity_sold_before_promo) / 1000000),2)," M") AS total_revenue_before_promo,
    CONCAT(FORMAT(SUM((fe.discounted_price * fe.quantity_sold_after_promo) / 1000000),2)," M") AS total_revenue_after_promo
FROM
    dim_campaigns dc
JOIN
    discounted_events fe ON dc.campaign_id = fe.campaign_id
GROUP BY
    dc.campaign_name;
    
/*4. Produce a report that calculates the Incremental Sold Quantity (ISU%) for each category during the Diwali campaign. 
Additionally, provide rankings for the categories based on their ISU%. The report will include three key fields: category, isu%, and rank order.
This information will assist in assessing the category-wise success and impact of the Diwali campaign on incremental sales.
Note: ISU% (Incremental Sold Quantity Percentage) is calculated as the percentage increase/decrease in quantity sold (after promo) compared to quantity sold (before promo)*/

WITH DiwaliSales AS (
	SELECT
		dp.category,
        SUM(quantity_sold_before_promo) AS sales_before_promo,
        SUM(quantity_sold_after_promo) AS sales_after_promo
	FROM
		dim_products dp
	JOIN
		fact_events fe ON dp.product_code = fe.product_code
	JOIN
		dim_campaigns dc ON dc.campaign_id = fe.campaign_id
	WHERE
		dc.campaign_name = "Diwali"
	GROUP BY
		dp.category
)

SELECT
	ds.category,
    ROUND(((ds.sales_after_promo - ds.sales_before_promo) / ds.sales_before_promo)*100,2) AS isu_percentage,
    DENSE_RANK() OVER(ORDER BY ((ds.sales_after_promo - ds.sales_before_promo) / ds.sales_before_promo) DESC) AS rank_order
FROM
	DiwaliSales ds
ORDER BY
	rank_order;
	
/*5. Create a report featuring the Top 5 products, ranked by Incremental Revenue Percentage (IR%), across all campaigns.
The report will provide essential information including product name, category, and ir%.
This analysis helps identify the most successful products in terms of incremental revenue across our campaigns, 
assisting in product optimization.*/

WITH ProductRevenue AS (
    SELECT
        fe.product_code,
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
    FROM
        fact_events fe
)

SELECT
    dp.product_name,
    dp.category,
    ROUND(((SUM(pr.discounted_price* pr.quantity_sold_after_promo) - SUM(pr.base_price * pr.quantity_sold_before_promo))/SUM(pr.base_price * pr.quantity_sold_before_promo))*100,2) AS IR_percentage
FROM
    dim_products dp
JOIN
    ProductRevenue pr ON dp.product_code = pr.product_code
GROUP BY
    dp.product_name, dp.category
ORDER BY
	IR_percentage DESC
LIMIT 5;
    