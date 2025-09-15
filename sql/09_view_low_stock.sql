USE OnlineStoreDB;
GO
SET ANSI_NULLS ON;
SET QUOTED_IDENTIFIER ON;
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name='IX_Products_StockQuantity' AND object_id=OBJECT_ID('dbo.Products'))
  CREATE INDEX IX_Products_StockQuantity ON dbo.Products(StockQuantity ASC);
GO

CREATE OR ALTER VIEW dbo.vwLowStock AS
  SELECT ProductID, Name, StockQuantity
  FROM dbo.Products
  WHERE StockQuantity < 10
  ORDER BY StockQuantity ASC, Name ASC;
GO
