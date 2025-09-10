
-- create_schema.sql
-- SQL şeması: tablolar, PK/FK, indexler, view'lar

IF DB_ID(N'SalesProcurementDB') IS NULL
    CREATE DATABASE SalesProcurementDB;
GO
USE SalesProcurementDB;
GO

IF OBJECT_ID('dbo.Sales', 'U') IS NOT NULL DROP TABLE dbo.Sales;
IF OBJECT_ID('dbo.Procurement', 'U') IS NOT NULL DROP TABLE dbo.Procurement;
IF OBJECT_ID('dbo.Campaigns', 'U') IS NOT NULL DROP TABLE dbo.Campaigns;
IF OBJECT_ID('dbo.Customers', 'U') IS NOT NULL DROP TABLE dbo.Customers;
IF OBJECT_ID('dbo.Suppliers', 'U') IS NOT NULL DROP TABLE dbo.Suppliers;
GO

CREATE TABLE dbo.Customers (
    CustomerID INT PRIMARY KEY,
    CustomerName NVARCHAR(120) NOT NULL,
    Segment NVARCHAR(30) NOT NULL,
    Country NVARCHAR(50) NOT NULL,
    JoinDate DATE NOT NULL
);

CREATE TABLE dbo.Suppliers (
    SupplierID INT PRIMARY KEY,
    SupplierName NVARCHAR(120) NOT NULL,
    Country NVARCHAR(50) NOT NULL,
    OnTimeDeliveryRate DECIMAL(5,2) NOT NULL,
    QualityScore DECIMAL(5,2) NOT NULL
);

CREATE TABLE dbo.Campaigns (
    CampaignID INT PRIMARY KEY,
    CampaignName NVARCHAR(120) NOT NULL,
    CampaignType NVARCHAR(30) NOT NULL,
    DiscountPercent INT NOT NULL,
    StartDate DATE NOT NULL,
    EndDate DATE NOT NULL
);

CREATE TABLE dbo.Sales (
    SaleID INT PRIMARY KEY,
    CustomerID INT NOT NULL,
    ProductID INT NOT NULL,
    Quantity INT NOT NULL,
    UnitPrice DECIMAL(10,2) NOT NULL,
    SaleDate DATETIME2 NOT NULL,
    CampaignID INT NULL,
    TotalPrice DECIMAL(12,2) NOT NULL,
    CONSTRAINT FK_Sales_Customers FOREIGN KEY(CustomerID) REFERENCES dbo.Customers(CustomerID),
    CONSTRAINT FK_Sales_Campaigns FOREIGN KEY(CampaignID) REFERENCES dbo.Campaigns(CampaignID)
);

CREATE TABLE dbo.Procurement (
    ProcurementID INT PRIMARY KEY,
    SupplierID INT NOT NULL,
    ProductID INT NOT NULL,
    Quantity INT NOT NULL,
    UnitCost DECIMAL(10,2) NOT NULL,
    OrderDate DATE NOT NULL,
    DeliveryDays INT NOT NULL,
    TotalCost DECIMAL(12,2) NOT NULL,
    CONSTRAINT FK_Procurement_Suppliers FOREIGN KEY(SupplierID) REFERENCES dbo.Suppliers(SupplierID)
);

CREATE OR ALTER VIEW dbo.vw_SalesFact AS
SELECT s.SaleID, s.CustomerID, c.CustomerName, c.Segment, c.Country AS CustomerCountry,
       s.ProductID, s.Quantity, s.UnitPrice, s.TotalPrice, s.SaleDate,
       YEAR(s.SaleDate) AS SaleYear, MONTH(s.SaleDate) AS SaleMonth,
       s.CampaignID, ca.CampaignType, ca.DiscountPercent
FROM dbo.Sales s
JOIN dbo.Customers c ON c.CustomerID = s.CustomerID
LEFT JOIN dbo.Campaigns ca ON ca.CampaignID = s.CampaignID;

CREATE OR ALTER VIEW dbo.vw_ProcurementPerf AS
SELECT p.ProcurementID, p.SupplierID, s.SupplierName, s.Country AS SupplierCountry,
       p.ProductID, p.Quantity, p.UnitCost, p.TotalCost, p.OrderDate, p.DeliveryDays,
       CASE WHEN p.DeliveryDays <= 7 THEN 1 ELSE 0 END AS OnTimeFlag
FROM dbo.Procurement p
JOIN dbo.Suppliers s ON s.SupplierID = p.SupplierID;
