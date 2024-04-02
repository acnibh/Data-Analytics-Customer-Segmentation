
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

