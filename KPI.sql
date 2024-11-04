  ##Lifetime Value (LTV) Estimation
SELECT 
    ID,
        (SUM(Amount_per_Day) * 365 * 3) AS Estimated_Lifetime_Value_3_Yrs
FROM 
    Smoker
GROUP BY 
    ID;
    
##Customer Segmentation by Consumption and Spending Behavior
    SELECT 
    ID,
    CASE 
        WHEN Consumption_per_Day >= 15 AND Amount_per_Day>= 200 THEN 'Heavy User - High Spender'
        WHEN Consumption_per_Day >= 15 AND Amount_per_Day < 200 THEN 'Heavy User - Low Spender'
        WHEN Consumption_per_Day < 15 AND Amount_per_Day >= 200 THEN 'Light User - High Spender'
        ELSE 'Light User - Low Spender'
    END AS Customer_Segment
FROM 
    smoker;

##Brand Loyalty Index

SELECT 
    ID,
    CASE 
        WHEN Previous_Tried_Brand IS NOT NULL AND Brands IS NOT NULL THEN 1.0
        WHEN Previous_Tried_Brand IS NULL AND Brands IS NOT NULL THEN 0.5
        ELSE 0.0
    END AS Loyalty_Index
FROM 
    Smoker;
    
    ##Trend Analysis by Demographics
    
    SELECT 
    Age,
    Gender,
    Market_Trend,
    COUNT(*) AS Trend_Count
FROM 
    Smoker
GROUP BY 
    Age, Gender, Market_Trend
ORDER BY 
    Trend_Count DESC;

##Consumption Intensity Index (CII)

SELECT 
    Area,
    SUM(Consumption_per_Day) / COUNT(DISTINCT ID) AS Consumption_Intensity_Index
FROM 
    Smoker
GROUP BY 
    Area;
    
    ##Cost of Addiction Analysis
    
    SELECT 
    ID,
    (Amount_per_Day* 365) AS Annual_Cost_of_Addiction
FROM 
    Smoker;
    
    ##Most Preferred Product Aspects
    
    SELECT 
    Liked_Aspect,
    COUNT(*) AS Preference_Count
FROM 
    Smoker
GROUP BY 
    Liked_Aspect
ORDER BY 
    Preference_Count DESC;

##Predictive Analysis: Shift to Alternative Products

SELECT 
    Gender,
    Age,
    Area,
    COUNT(*) AS Shift_Count
FROM 
    smoker
WHERE 
    Market_Trend = 'Shift to alternative products'
GROUP BY 
    Gender, Age, Area
ORDER BY 
    Shift_Count DESC;
    
    ##Average Daily Consumption by Age Group
    
    SELECT 
    Age_Group,
    AVG(Daily_Consumption) AS Avg_Consumption
FROM 
    (SELECT 
         CASE 
             WHEN Age BETWEEN 18 AND 25 THEN '18-25'
             WHEN Age BETWEEN 26 AND 35 THEN '26-35'
             WHEN Age BETWEEN 36 AND 45 THEN '36-45'
             ELSE '46+' 
         END AS Age_Group,
         Consumption_per_day
     FROM Smoker) AS AgeConsumption
GROUP BY 
    Age_Group;

##Join query

SELECT
    s.ID,
    s.Shop_Id,
    s.Gender,
    s.Age,
    s.Products,
    s.Brands,
    s.Reason_for_Consuming,
    s.Purchase_Behavior,
    s.Liked_Aspect,
    s.Previous_Tried_Brand,
    s.Area AS Smoker_Area,
    s.Urban_Rural AS Smoker_Urban_Rural,
    s.Consumption_per_Day,
    s.Amount_per_Day,
    s.Market_Trend,
    re.Shop_Name,
    re.Location AS Shop_Location,
    re.Urban_Rural AS Shop_Urban_Rural,
    re.How_do_you_usually_get_ITC_Cigarettes,
    re.Available_Brands
FROM Smoker s
JOIN retail re ON s.shop_ID = re.Unique_ID;

##Average Purchase Frequency per Smoker by Shop
SELECT
    s.Shop_Id,
    AVG(s.Consumption_per_day) AS Avg_Quantity_Purchase
FROM Smoker s
JOIN retail re ON s.shop_ID = re.Unique_ID
GROUP BY s.Shop_Id;

##Total Consumption per Shop

SELECT
    s.Shop_Id,
    SUM(s.Consumption_per_Day) AS Total_Consumption
FROM Smoker s
JOIN retail re ON s.shop_ID = re.Unique_ID
GROUP BY s.Shop_Id;

    ##Top 10 Shops with the Highest Smoker Retention Rate
    
    SELECT re.unique_id, 
       COUNT(re.unique_id) / (SELECT COUNT(*) FROM Smoker) * 100 AS retention_rate
FROM Smoker s
JOIN Retail re ON s.shop_id = re.unique_id
GROUP BY re.unique_id
ORDER BY retention_rate DESC
LIMIT 10;

    ##Top 3 Most Popular Brands in Urban vs. Rural Areas
    
    SELECT 
    s.Urban_Rural,
    s.Brands,
    COUNT(*) AS Brand_Popularity
FROM 
    Smoker s
JOIN 
    retail re ON s.Shop_Id = re.Unique_ID
GROUP BY 
    s.Urban_Rural, s.Brands
ORDER BY 
    s.Urban_Rural, Brand_Popularity DESC
LIMIT 3;

##Brand Switching Rate per Shop

SELECT 
    s.Shop_Id,
    SUM(CASE WHEN s.Previous_Tried_Brand <> s.Brands THEN 1 ELSE 0 END) * 100.0 / COUNT(*) AS Brand_Switching_Rate
FROM 
    Smoker s
JOIN 
    retail re ON s.Shop_Id = re.Unique_ID
GROUP BY 
    s.Shop_Id;

##Favorite Purchase Channel for ITC Cigarettes by Smoker Region (Urban vs. Rural)

SELECT 
    s.Urban_Rural,
    re.How_do_you_usually_get_ITC_Cigarettes,
    COUNT(*) AS Channel_Preference_Count
FROM 
    Smoker s
JOIN 
    retail re ON s.Shop_Id = re.Unique_ID
GROUP BY 
    s.Urban_Rural, re.How_do_you_usually_get_ITC_Cigarettes
ORDER BY 
    Channel_Preference_Count DESC;
    
    ##Revenue Impact by Reason for Consumption
    
    SELECT 
    s.Reason_for_Consuming,
    AVG(s.Amount_per_Day) AS Avg_Revenue_Impact
FROM 
    Smoker s
GROUP BY 
    s.Reason_for_Consuming
ORDER BY 
    Avg_Revenue_Impact DESC;

##Customer Satisfaction Analysis by 'Liked Aspect' of the Product

SELECT 
    s.Liked_Aspect,
    COUNT(*) AS Satisfaction_Count
FROM 
    Smoker s
GROUP BY 
    s.Liked_Aspect
ORDER BY 
    Satisfaction_Count DESC;

## Market Share Prediction for Each Brand

SELECT 
    s.Brands,
    COUNT(s.ID) AS Current_Market_Share,
    (COUNT(s.ID) * 1.05) AS Predicted_Market_Share_Next_Year       ##Assuming a 5% growth rate
FROM 
    Smoker s
JOIN 
    retail re ON s.Shop_Id = re.Unique_ID
GROUP BY 
    s.Brands;

##Brand Loyalty Prediction (Retention Rate)

SELECT 
    s.Brands,
    SUM(CASE WHEN s.Previous_Tried_Brand = s.Brands THEN 1 ELSE 0 END) * 100.0 / COUNT(*) AS Current_Retention_Rate,
    (SUM(CASE WHEN s.Previous_Tried_Brand = s.Brands THEN 1 ELSE 0 END) * 1.03) * 100.0 / COUNT(*) AS Predicted_Retention_Rate -- Assuming a 3% increase
FROM 
    Smoker s
GROUP BY 
    s.Brands;

##Consumption Trend Prediction Based on Market Trend Perception

SELECT 
    s.Market_Trend,
    AVG(s.Consumption_per_Day) AS Current_Consumption,
    (AVG(s.Consumption_per_Day) * 1.06) AS Predicted_Consumption -- Assuming a 6% increase
FROM 
    Smoker s
GROUP BY 
    s.Market_Trend;

##Projected Customer Shift by Brand Based on Liked Aspects

SELECT 
    s.Liked_Aspect,
    s.Brands,
    COUNT(s.ID) AS Current_Customer_Count,
    (COUNT(s.ID) * 1.04) AS Predicted_Customer_Count -- Assuming a 4% increase
FROM 
    Smoker s
GROUP BY 
    s.Liked_Aspect, s.Brands;

