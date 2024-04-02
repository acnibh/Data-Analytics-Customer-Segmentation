# Data-Analytics-Customer-Segmentation
In this project, we utilize publicly available datasets from an online retail store to explore customer segments and behaviors in order to increase enhance sales revenue Customer segmentation is performed by developing a RFM Model. RFM (Recency, Frequency, Monetary) analysis is a behavior-based approach grouping customers into segments. It groups the customers on the basis of their previous purchase transactions. Segmenting customers into different groups based on RFM and Quartile (Descriptive Statistical Method). This helps divide the data into equally sized intervals and is not influenced by outliers.
### Tools
- Excel - Data Cleaning
- SQL Server - Collect Data
- PowerBI - visualization and creating reports
## Background
The [Online Retail](https://archive.ics.uci.edu/dataset/352/online+retail) a transnational data set which contains all the transactions occurring between 01/12/2010 and 09/12/2011 for a UK-based and registered non-store online retail.The company mainly sells unique all-occasion gifts. Many customers of the company are wholesalers.
## Data Description & Data Cleansing
### 1. Data Description
Let's see the description of each column:

- InvoiceNo: A unique identifier for the invoice. An invoice number shared across rows means that those transactions were performed in a single invoice (multiple purchases).
- StockCode: Identifier for items contained in an invoice.
- Description: Textual description of each of the stock item.
- Quantity: The quantity of the item purchased.
- InvoiceDate: Date of purchase.
- UnitPrice: Value of each item.
- CustomerID: Identifier for customer making the purchase.
- Country: Country of customer
### 2. Data Cleansing

![image](https://github.com/acnibh/Data-Analytics-Customer-Segmentation/assets/146699917/0902ec24-9656-4db0-93f0-0db616c241f4)
We can observe that the columns Quantity, Unitprice, and Description contain sales data, and most of those rows do not have a Customer ID. Note that for all these records we do not have the customer ID. So we conclude that we can erase all records in that quantity or the price and negative. In addition, by the foregoing summary we see that there are 135,080 records without customer identification that we may also disregard.
## OVERVIEW
![image](https://github.com/acnibh/Data-Analytics-Customer-Segmentation/assets/146699917/5c58539a-b18f-49bd-953f-bf9ec7549ed2)

## Exploratory Data Analysis on Customer Segments
After the data cleaning process, exploratory analysis on the dataset is performed and the following insights are obtained :
### 1. Inernal Market & Customer Retention
  ![image](https://github.com/acnibh/Data-Analytics-Customer-Segmentation/assets/146699917/3d77abed-37d1-4b12-b649-f57fdfeff8c1)


  The data indicates that the main contributors to the store's revenue are domestic customers (United Kingdom), accounting for 82.01% of the revenue, with a customer retention rate of 92.09%. This suggests that 
  we should focus on domestic customers and customer retention to increase revenue.
### 2. Customer Segmentation
  ![image](https://github.com/acnibh/Data-Analytics-Customer-Segmentation/assets/146699917/2864b452-6d7e-4bc0-b659-62681cd254ce)
  ```SQL
-- Collect data to identify customer segmentation
WITH joined_table AS (
     SELECT CustomerID
       , CONVERT(Date, InvoiceDate) AS trans_date
	   , Quantity * UnitPrice AS	  [ summary_grand_total ]
     FROM OnlineRetail
)
, rfm_table AS (
     SELECT  DISTINCT CustomerID
       , DATEDIFF(Day, MAX(trans_date), '2011-12-10') AS Recency
       , COUNT( DISTINCT trans_date) AS Frequency
       , SUM ([ summary_grand_total ]) AS Monetary
     FROM joined_table
     GROUP BY CustomerID
	 
)
, rfm_rank AS (
     SELECT *
       , PERCENT_RANK () OVER (ORDER BY Recency ASC) r_rank
       , PERCENT_RANK () OVER (ORDER BY Frequency DESC) f_rank
       , PERCENT_RANK () OVER (ORDER BY Monetary DESC) m_rank
FROM rfm_table
)
, tier_table AS (
     SELECT *
       , CASE WHEN r_rank > 0.75 THEN 4
              WHEN r_rank > 0.5 THEN 3
	          WHEN r_rank > 0.25 THEN 2
	          ELSE 1 END r_tier
	   , CASE WHEN f_rank > 0.10 THEN 4
			  WHEN f_rank > 0.05 THEN 3
			  WHEN f_rank > 0.01 THEN 2
			  ELSE 1 END f_tier
       , CASE WHEN m_rank > 0.75 THEN 4
              WHEN m_rank > 0.5 THEN 3
	          WHEN m_rank > 0.25 THEN 2
	          ELSE 1 END m_tier
     FROM rfm_rank
)
, table_score AS (
      SELECT *
        , CONCAT (r_tier, f_tier, m_tier) AS rfm_score
      FROM tier_table
) 
	  SELECT *
        , CASE
            WHEN rfm_score = 111 THEN 'Best Customers' -- KH Hang tot nhat
            WHEN rfm_score LIKE '[3-4][3-4][1-4]' THEN 'Lost Bad Customer' -- KH r?i b? mà còn sieu te
			WHEN rfm_score LIKE '[3-4]2[1-4]' THEN 'Lost Customers' -- KH roi bo nhung nhieu value (F = 3,4,5 )
			WHEN rfm_score LIKE '21[1-4]' THEN 'Almost Lost' --sap mat KH nay
			WHEN rfm_score LIKE '11[2-4]' THEN 'Loyal Customers'
			WHEN rfm_score LIKE '[1-2][1-3]1' THEN 'Big Spenders' -- KH chi nhiu tien
			WHEN rfm_score LIKE '[1-2]4[1-4]' THEN 'New Customers' -- KH moi nen frequency chua nhiu
			WHEN rfm_score LIKE '[3-4]1[1-4]' THEN 'Hibernating' -- KH ngu dong (truoc do tung rat tot)
			WHEN rfm_score LIKE '[1-2][2-3][2-4]' THEN 'Potential Loyalists' -- KH co tim nang
			ELSE 'unknown' END AS segment
FROM table_score
```
  

  In this stage of analysis the customer segmentation was done by developing an RFM Model. Based on RFM and utilizing Quartiles (Descriptive Statistics) to divide into 4 tiers from 1,2,3,4 in ascending order for 
  Recency, Frequency, Monetary values, we can combine these tiers to classify customers into different groups such as  Best Customers (111), Lost Bad Customers ([3-4][3-4][1-4]), Lost Customers ([3-4]2[1-4]), 
  Almost Lost (21[1-4]), Loyal Customers (11[2-4]), Big Spenders ([1-2][1-3]1), New Customers ([1-2]4[1-4]), Hibernating ([3-4]1[1-4]), Potential Loyalists ([1-2][2-3][2-4]).

  When starting to explore the data, the results returned 7 customer segment groups for the online retail dataset:
  - Lost Bad Customers
  - New Customers
  - Big Spenders
  - Best Customers
  - Potential Loyalists
  - Lost Customers
  - Almost Lost
  ### Customer Behavior
  
  ![image](https://github.com/acnibh/Data-Analytics-Customer-Segmentation/assets/146699917/9071d064-f977-4f6d-94fe-ddddddd8f71d)
  
  
  The Big Spenders, Potential, Best, Loyal, and returning customers in the New customer segment, despite of smaller numbers, they contribute significantly to the store's revenue. Most of these customer groups 
  are domestic wholesalers, with a few from other countries, hence they tend to make large purchases for their businesses. Particularly during major holidays in the UK such as New Year, Halloween, and Christmas, 
  they tend to make bulk purchases a month before and at the beginning of the holiday month. This is the main reason why revenue spikes sharply in September, October, and November and tends to decrease in 
  December.
  
  ![image](https://github.com/acnibh/Data-Analytics-Customer-Segmentation/assets/146699917/7abc0c79-078b-4ced-ad9b-0ae652c98f4d)

  In the other months, there tends to be a flat trend due to the return of these customer segments, and some customers with higher Frequency tend to have higher Monetary values.
  
  ![image](https://github.com/acnibh/Data-Analytics-Customer-Segmentation/assets/146699917/e775b74c-9c4b-4761-92d8-5658f3d713a3)
  
  In December, a new product called PAPER CRAFT, LITTLE BIRDIE attracted many new customer segments to purchase more than other products, and it successfully attracted new customers to the store.

## Recommendations
- Focus on attracting new customers and retaining returning customers for future purchases by offering discounts when purchasing additional products or when buying two or more types of products.
- Introduce post-purchase policies and high-priority benefits or promotions for Big Spenders to encourage them to become Best Customers. Additionally, increase purchase incentives for Potential customer groups to boost their buying frequency.
  










  
    





