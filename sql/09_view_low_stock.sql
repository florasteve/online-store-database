USE OnlineStoreDB;
GO
SET ANSI_NULLS ON;
SET QUOTED_IDENTIFIER ON;
GO

/* Supporting index for quick scans by quantity */
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name='IX_Products_StockQuantity' AND object_id=OBJECT_ID('dbo.Products'))
  CREATE INDEX IX_Products_StockQuantity ON dbo.Products(StockQuantity ASC);
GO

/* NOTE: No ORDER BY in the view. Sort when querying/reporting. */
CREATE OR ALTER VIEW dbo.vwLowStock AS
  SELECT ProductID, Name, StockQuantity
  FROM dbo.Products
  WHERE StockQuantity < 10;
GO
