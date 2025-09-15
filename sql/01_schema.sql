SET ANSI_NULLS ON;
SET QUOTED_IDENTIFIER ON;
GO

IF DB_ID('OnlineStoreDB') IS NULL
  CREATE DATABASE OnlineStoreDB;
GO
USE OnlineStoreDB;
GO

IF OBJECT_ID('dbo.OrderDetails','U') IS NOT NULL DROP TABLE dbo.OrderDetails;
IF OBJECT_ID('dbo.Orders','U')        IS NOT NULL DROP TABLE dbo.Orders;
IF OBJECT_ID('dbo.Products','U')      IS NOT NULL DROP TABLE dbo.Products;
IF OBJECT_ID('dbo.Customers','U')     IS NOT NULL DROP TABLE dbo.Customers;
GO

CREATE TABLE dbo.Customers(
  CustomerID     INT IDENTITY(1,1) PRIMARY KEY,
  Name           NVARCHAR(100) NOT NULL,
  Email          NVARCHAR(255) NOT NULL UNIQUE,
  Address        NVARCHAR(255) NULL,
  CreatedAt      DATETIME2(0)  NOT NULL CONSTRAINT DF_Customers_CreatedAt DEFAULT SYSUTCDATETIME(),
  UpdatedAt      DATETIME2(0)  NOT NULL CONSTRAINT DF_Customers_UpdatedAt DEFAULT SYSUTCDATETIME()
);
GO

CREATE TABLE dbo.Products(
  ProductID      INT IDENTITY(1,1) PRIMARY KEY,
  Name           NVARCHAR(150) NOT NULL,
  Price          DECIMAL(10,2) NOT NULL CHECK (Price >= 0),
  StockQuantity  INT NOT NULL CHECK (StockQuantity >= 0),
  CreatedAt      DATETIME2(0)  NOT NULL CONSTRAINT DF_Products_CreatedAt DEFAULT SYSUTCDATETIME(),
  UpdatedAt      DATETIME2(0)  NOT NULL CONSTRAINT DF_Products_UpdatedAt DEFAULT SYSUTCDATETIME()
);
GO

CREATE TABLE dbo.Orders(
  OrderID        INT IDENTITY(1,1) PRIMARY KEY,
  CustomerID     INT NOT NULL,
  OrderDate      DATETIME2(0) NOT NULL CONSTRAINT DF_Orders_OrderDate DEFAULT SYSUTCDATETIME(),
  TotalAmount    DECIMAL(12,2) NOT NULL CONSTRAINT DF_Orders_Total DEFAULT 0,
  CreatedAt      DATETIME2(0)  NOT NULL CONSTRAINT DF_Orders_CreatedAt DEFAULT SYSUTCDATETIME(),
  UpdatedAt      DATETIME2(0)  NOT NULL CONSTRAINT DF_Orders_UpdatedAt DEFAULT SYSUTCDATETIME(),
  CONSTRAINT FK_Orders_Customers FOREIGN KEY (CustomerID) REFERENCES dbo.Customers(CustomerID)
);
GO

CREATE TABLE dbo.OrderDetails(
  OrderDetailID  INT IDENTITY(1,1) PRIMARY KEY,
  OrderID        INT NOT NULL,
  ProductID      INT NOT NULL,
  Quantity       INT NOT NULL CHECK (Quantity > 0),
  UnitPrice      DECIMAL(10,2) NOT NULL CHECK (UnitPrice >= 0),
  Subtotal       AS (Quantity * UnitPrice) PERSISTED,
  CreatedAt      DATETIME2(0) NOT NULL CONSTRAINT DF_OrderDetails_CreatedAt DEFAULT SYSUTCDATETIME(),
  UpdatedAt      DATETIME2(0) NOT NULL CONSTRAINT DF_OrderDetails_UpdatedAt DEFAULT SYSUTCDATETIME(),
  CONSTRAINT FK_OrderDetails_Orders   FOREIGN KEY (OrderID)   REFERENCES dbo.Orders(OrderID),
  CONSTRAINT FK_OrderDetails_Products FOREIGN KEY (ProductID) REFERENCES dbo.Products(ProductID)
);
GO

CREATE INDEX IX_Orders_CustomerID_OrderDate ON dbo.Orders(CustomerID, OrderDate DESC);
CREATE INDEX IX_OrderDetails_OrderID ON dbo.OrderDetails(OrderID);
CREATE INDEX IX_OrderDetails_ProductID ON dbo.OrderDetails(ProductID);
CREATE INDEX IX_Products_Name ON dbo.Products(Name);
GO
