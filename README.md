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
![image](https://github.com/user-attachments/assets/a46ac8f8-e857-410d-b0f9-3984f27bfed1)

### 2. Data Cleansing

![image](https://github.com/user-attachments/assets/a1bb5cd3-5b94-4282-91d6-d0f5d9e71d31)

We can see that the 'Description' column has 0.27% null values, and the 'CustomerID' column has 24.9% null values.

![image](https://github.com/user-attachments/assets/41933c7d-7618-438d-a233-4e65bf56dc62)
Furthermore, I found 0.01% unusual values in the 'Description' column and 1.96% values in the 'Quantity' column that are less than 0, which leads me to suspect these values represent product quantities that customers returned to the shop.
![image](https://github.com/user-attachments/assets/36955ff9-0717-41ed-a22e-e71ed926a73b)
After further investigation of the negative values in the 'Quantity' column and the related values in other columns, I confirmed that the negative values in the 'Quantity' column represent returned product quantities, and such orders are identified by an 'InvoiceNo' value that starts with the prefix 'C'.
![image](https://github.com/user-attachments/assets/6869bee4-d3c2-4c99-bd7c-70a1cd7055c7)
Based on this assumption, I further examined the details of the prefixes in the 'InvoiceNo' values, as well as other columns like 'StockCode' and 'Description.' I found that the data table also includes information on payment methods, shipping methods, and more.
![image](https://github.com/user-attachments/assets/cd35b8b0-0e4e-4e86-9d0b-911932225ac9)
To facilitate customer segmentation analysis and provide recommendations to improve and increase sales, I decided to separate transaction data from data serving other purposes. I also removed the 24.9% of null values in the 'CustomerID' column.

![image](https://github.com/user-attachments/assets/373f8e6c-9484-47cd-8bfe-f6d8f3d95c0b)

Before proceeding with the analysis, I will segment customers into various tiers: Platinum, Gold, Silver, Copper, and Iron.
![image](https://github.com/user-attachments/assets/bb75dc26-c318-4fba-9155-0326189f0f3f)

I classified customers using the RFM method combined with percentiles. For example, with Frequency, I sorted the values in descending order and used the PERCENT_RANK() function to label them. Customers with a Frequency > 0.75 are assigned to Tier 1, > 0.5 to Tier 2, > 0.25 to Tier 3, and the rest to Tier 4.

The same approach applies to R (Recency) and M (Monetary). However, there's a slight difference for Recency: we sort it in ascending order, as a lower recency value indicates a better (more recent) customer.
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
            WHEN rfm_score = 111 THEN 'Plantinum' 
            WHEN rfm_score LIKE '[3-4][3-4][1-4]' THEN 'Iron' -- KH r?i b? mà còn sieu te
			WHEN rfm_score LIKE '[3-4]2[1-4]' THEN 'Copper' -- KH roi bo nhung nhieu value (F = 3,4,5 )
			WHEN rfm_score LIKE '21[1-4]' THEN 'Copper' --sap mat KH nay
			WHEN rfm_score LIKE '11[2-4]' THEN 'Gold'
			WHEN rfm_score LIKE '[1-2][1-3]1' THEN 'Gold' -- KH chi nhiu tien
			WHEN rfm_score LIKE '[1-2]4[1-4]' THEN 'Iron' -- KH moi nen frequency chua nhiu
			WHEN rfm_score LIKE '[3-4]1[1-4]' THEN 'Iron' -- KH ngu dong (truoc do tung rat tot)
			WHEN rfm_score LIKE '[1-2][2-3][2-4]' THEN 'Silver' -- KH co tim nang
			ELSE 'unknown' END AS segment
FROM table_score
```





## DATA ANALYSIS
### OVERALL
![image](https://github.com/user-attachments/assets/9b5a1c8a-1460-4857-89d7-47b7a7ddd5c9)
The customers of this online shop come from various countries, but the largest source of revenue comes from the UK.


![image](https://github.com/user-attachments/assets/705b2ac3-4325-4cf8-baa0-b8f4f4c694f7)
Overall, the highest quantity of products is purchased at the end of the year. However, since most customers are wholesalers, they tend to buy in bulk about a month in advance, especially for major holidays such as Halloween, New Year, and Christmas. In contrast, the first two quarters see a slight decrease in quantities, partly because there are fewer major holidays during this period.


### SEGMENTATION
#### Plantinum & Gold 
![image](https://github.com/user-attachments/assets/e03a7a65-efdd-427f-83dd-85d00f1187f3)
Platinum customers are the best ones, while Gold customers are those who spend a lot of money and are loyal. These customers make significant purchases at the end of the year but continue to buy frequently throughout the months. The three products they purchase the most are the Popcorn Holder, White Hanging Heart T-Light Holder, and Brocade Ring Purse.


![image](https://github.com/user-attachments/assets/a29d3d85-81f6-4b3c-8d89-90da7fbc92f6)
For the return quantities of this group, there was a spike in August 2011, with the top 8 returned products being: PANTRY CHOPPING BOARD, HOME SWEET HOME MUG, COLOUR GLASS STAR T-LIGHT HOLDER, VINTAGE BILLBOARD TEA MUG, REGENCY TEA PLATE ROSES, SAVE THE PLANET MUG, WHITE HANGING HEART T-LIGHT HOLDER, and PLACE SETTING WHITE HEART.

### Silver & Copper
Silver customers are those with potential to become loyal and valuable clients. These customers have contributed well in the past, but have not returned for a while. The customers who are at risk of being lost are those in the Copper group.
![image](https://github.com/user-attachments/assets/fc170a81-cea2-4482-9792-938372cd2e97)

![image](https://github.com/user-attachments/assets/4ecfd5dc-648e-44bb-9e1c-99920a10ef98)

The top three products favored by these two groups are PAPER CRAFT, WORLD WAR 2, and JUMBO BAG. These customers made a significant purchase spike in November, mainly buying the PAPER CRAFT product. However, the most returned product is also PAPER CRAFT, which suggests that there may be an issue with this product, indicating it might not be perfect yet.
### Iron
![image](https://github.com/user-attachments/assets/c1263a4a-4773-4199-b8c9-a3b1a36d623b)
![image](https://github.com/user-attachments/assets/6f8babb3-526d-4b85-8a10-d5c0d7156916)

The Iron group consists of lost customers or new customers. The clearest patterns for these groups appear in two periods: January and November. In January, the lost customers primarily purchased the MEDIUM CERAMIC TOP STORAGE JAR, which accounted for nearly 80% of their purchases. However, the return rate for this product was very high, indicating that it was the main cause of customer loss.

## RECOMMENDATION & OBJECTIVES
![image](https://github.com/user-attachments/assets/89dafdc6-41d2-4a80-b54a-28f88f51266a)

  










  
    





