
-- create_schema_fixed.sql
-- Düzeltme: CREATE VIEW ifadeleri ayrı batch'te (GO ile ayrıldı)

IF DB_ID(N'SalesProcurementDB') IS NULL
    CREATE DATABASE SalesProcurementDB;
GO

USE SalesProcurementDB;
GO

-- Güvenli tekrar çalıştırma için mevcut tabloları düşür (sıra önemli)
IF OBJECT_ID('dbo.Sales', 'U') IS NOT NULL DROP TABLE dbo.Sales;
IF OBJECT_ID('dbo.Procurement', 'U') IS NOT NULL DROP TABLE dbo.Procurement;
IF OBJECT_ID('dbo.Campaigns', 'U') IS NOT NULL DROP TABLE dbo.Campaigns;
IF OBJECT_ID('dbo.Customers', 'U') IS NOT NULL DROP TABLE dbo.Customers;
IF OBJECT_ID('dbo.Suppliers', 'U') IS NOT NULL DROP TABLE dbo.Suppliers;
GO

-- Customers
CREATE TABLE dbo.Customers (
    CustomerID       INT            NOT NULL PRIMARY KEY,
    CustomerName     NVARCHAR(120)  NOT NULL,
    Segment          NVARCHAR(30)   NOT NULL,
    Country          NVARCHAR(50)   NOT NULL,
    JoinDate         DATE           NOT NULL
);
GO

-- Suppliers
CREATE TABLE dbo.Suppliers (
    SupplierID           INT           NOT NULL PRIMARY KEY,
    SupplierName         NVARCHAR(120) NOT NULL,
    Country              NVARCHAR(50)  NOT NULL,
    OnTimeDeliveryRate   DECIMAL(5,2)  NOT NULL,
    QualityScore         DECIMAL(5,2)  NOT NULL
);
GO

-- Campaigns
CREATE TABLE dbo.Campaigns (
    CampaignID       INT           NOT NULL PRIMARY KEY,
    CampaignName     NVARCHAR(120) NOT NULL,
    CampaignType     NVARCHAR(30)  NOT NULL,
    DiscountPercent  INT           NOT NULL,
    StartDate        DATE          NOT NULL,
    EndDate          DATE          NOT NULL
);
GO

-- Sales
CREATE TABLE dbo.Sales (
    SaleID        INT            NOT NULL PRIMARY KEY,
    CustomerID    INT            NOT NULL,
    ProductID     INT            NOT NULL,
    Quantity      INT            NOT NULL,
    UnitPrice     DECIMAL(10,2)  NOT NULL,
    SaleDate      DATETIME2      NOT NULL,
    CampaignID    INT            NULL,
    TotalPrice    DECIMAL(12,2)  NOT NULL
);
GO

-- Procurement
CREATE TABLE dbo.Procurement (
    ProcurementID  INT            NOT NULL PRIMARY KEY,
    SupplierID     INT            NOT NULL,
    ProductID      INT            NOT NULL,
    Quantity       INT            NOT NULL,
    UnitCost       DECIMAL(10,2)  NOT NULL,
    OrderDate      DATE           NOT NULL,
    DeliveryDays   INT            NOT NULL,
    TotalCost      DECIMAL(12,2)  NOT NULL
);
GO

-- Foreign Keys
ALTER TABLE dbo.Sales
ADD CONSTRAINT FK_Sales_Customers
    FOREIGN KEY (CustomerID) REFERENCES dbo.Customers(CustomerID);
GO

ALTER TABLE dbo.Sales
ADD CONSTRAINT FK_Sales_Campaigns
    FOREIGN KEY (CampaignID) REFERENCES dbo.Campaigns(CampaignID)
    ON DELETE SET NULL;
GO

ALTER TABLE dbo.Procurement
ADD CONSTRAINT FK_Procurement_Suppliers
    FOREIGN KEY (SupplierID) REFERENCES dbo.Suppliers(SupplierID);
GO

-- Indexes
CREATE INDEX IX_Sales_Customer_SaleDate ON dbo.Sales (CustomerID, SaleDate);
CREATE INDEX IX_Sales_Campaign ON dbo.Sales (CampaignID);
CREATE INDEX IX_Sales_Product ON dbo.Sales (ProductID);
GO

CREATE INDEX IX_Proc_Supplier_OrderDate ON dbo.Procurement (SupplierID, OrderDate);
CREATE INDEX IX_Proc_Product ON dbo.Procurement (ProductID);
GO

-- Views (CREATE VIEW ayrı batch'te olmalı)
CREATE OR ALTER VIEW dbo.vw_SalesFact AS
SELECT
    s.SaleID,
    s.CustomerID,
    c.CustomerName,
    c.Segment,
    c.Country     AS CustomerCountry,
    s.ProductID,
    s.Quantity,
    s.UnitPrice,
    s.TotalPrice,
    s.SaleDate,
    YEAR(s.SaleDate)  AS SaleYear,
    MONTH(s.SaleDate) AS SaleMonth,
    s.CampaignID,
    ca.CampaignType,
    ca.DiscountPercent
FROM dbo.Sales s
JOIN dbo.Customers c ON c.CustomerID = s.CustomerID
LEFT JOIN dbo.Campaigns ca ON ca.CampaignID = s.CampaignID;
GO

CREATE OR ALTER VIEW dbo.vw_ProcurementPerf AS
SELECT
    p.ProcurementID,
    p.SupplierID,
    s.SupplierName,
    s.Country       AS SupplierCountry,
    p.ProductID,
    p.Quantity,
    p.UnitCost,
    p.TotalCost,
    p.OrderDate,
    p.DeliveryDays,
    CASE WHEN p.DeliveryDays <= 7 THEN 1 ELSE 0 END AS OnTimeFlag
FROM dbo.Procurement p
JOIN dbo.Suppliers s ON s.SupplierID = p.SupplierID;
GO
