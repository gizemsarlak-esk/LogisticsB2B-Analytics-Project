
-- starter_queries.sql
-- EDA (Keşifçi Veri Analizi) ve iş soruları

USE SalesProcurementDB;
GO

-- Tablolarda satır sayıları
SELECT 'Customers' AS T, COUNT(*) AS Rows FROM dbo.Customers
UNION ALL SELECT 'Suppliers', COUNT(*) FROM dbo.Suppliers
UNION ALL SELECT 'Campaigns', COUNT(*) FROM dbo.Campaigns
UNION ALL SELECT 'Sales', COUNT(*) FROM dbo.Sales
UNION ALL SELECT 'Procurement', COUNT(*) FROM dbo.Procurement;

-- NULL kontrolü
SELECT SUM(CASE WHEN CampaignID IS NULL THEN 1 ELSE 0 END) AS NullCampaigns FROM dbo.Sales;

-- Segment dağılımı
SELECT Segment, COUNT(*) FROM dbo.Customers GROUP BY Segment;

-- Aylık satış özeti
SELECT SaleYear, SaleMonth, SUM(TotalPrice) AS Revenue
FROM dbo.vw_SalesFact
GROUP BY SaleYear, SaleMonth ORDER BY SaleYear, SaleMonth;

-- Kampanya etkisi
SELECT CASE WHEN CampaignID IS NULL THEN 'NoCampaign' ELSE 'Campaign' END AS CampaignFlag,
       AVG(TotalPrice) AS AvgBasket
FROM dbo.Sales GROUP BY CASE WHEN CampaignID IS NULL THEN 'NoCampaign' ELSE 'Campaign' END;

-- Tedarikçi zamanında teslim
SELECT SupplierID, SupplierName, AVG(CAST(OnTimeFlag AS FLOAT)) AS OnTimeRate
FROM dbo.vw_ProcurementPerf GROUP BY SupplierID, SupplierName;

-- RFM örneği
;WITH LastPurchase AS (
  SELECT CustomerID, MAX(SaleDate) AS LastSaleDate FROM dbo.Sales GROUP BY CustomerID
)
SELECT c.CustomerID, c.CustomerName,
       DATEDIFF(DAY, lp.LastSaleDate, (SELECT MAX(SaleDate) FROM dbo.Sales)) AS RecencyDays,
       COUNT(s.SaleID) AS Frequency, SUM(s.TotalPrice) AS Monetary
FROM dbo.Customers c
LEFT JOIN dbo.Sales s ON s.CustomerID=c.CustomerID
LEFT JOIN LastPurchase lp ON lp.CustomerID=c.CustomerID
GROUP BY c.CustomerID, c.CustomerName, lp.LastSaleDate;
