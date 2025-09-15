USE OnlineStoreDB;
GO
SET ANSI_NULLS ON;
SET QUOTED_IDENTIFIER ON;
GO

/* 1) Categories table */
IF OBJECT_ID(N'dbo.Categories', N'U') IS NULL
BEGIN
  CREATE TABLE dbo.Categories(
    CategoryID   INT IDENTITY(1,1) PRIMARY KEY,
    Name         NVARCHAR(100) NOT NULL UNIQUE,
    Description  NVARCHAR(255) NULL,
    CreatedAt    DATETIME2(0) NOT NULL CONSTRAINT DF_Categories_CreatedAt DEFAULT SYSUTCDATETIME(),
    UpdatedAt    DATETIME2(0) NOT NULL CONSTRAINT DF_Categories_UpdatedAt DEFAULT SYSUTCDATETIME()
  );
END;
GO

/* 2) Products.CategoryID (1→many) */
IF COL_LENGTH('dbo.Products','CategoryID') IS NULL
BEGIN
  ALTER TABLE dbo.Products ADD CategoryID INT NULL;
  ALTER TABLE dbo.Products WITH CHECK
    ADD CONSTRAINT FK_Products_Categories FOREIGN KEY (CategoryID)
      REFERENCES dbo.Categories(CategoryID);
  IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name='IX_Products_CategoryID' AND object_id=OBJECT_ID('dbo.Products'))
    CREATE INDEX IX_Products_CategoryID ON dbo.Products(CategoryID);
END;
GO

/* 3) Seed some common categories (idempotent) */
MERGE dbo.Categories AS tgt
USING (VALUES
  (N'Accessories',   N'Peripherals and small add-ons'),
  (N'Electronics',   N'Audio and core devices'),
  (N'Cables',        N'Connectivity and wires'),
  (N'Uncategorized', N'Default bucket')
) AS src(Name, Description)
ON tgt.Name = src.Name
WHEN NOT MATCHED THEN
  INSERT(Name, Description) VALUES(src.Name, src.Description);
GO

/* 4) Map existing products heuristically (only if NULL) */
UPDATE p SET CategoryID = c.CategoryID
FROM dbo.Products p
JOIN dbo.Categories c ON
  (c.Name = N'Accessories'   AND (p.Name LIKE N'%Mouse%' OR p.Name LIKE N'%Keyboard%' OR p.Name LIKE N'%Stand%'))
  OR (c.Name = N'Electronics' AND  p.Name LIKE N'%Headphone%')
  OR (c.Name = N'Cables'      AND  p.Name LIKE N'%Cable%')
WHERE p.CategoryID IS NULL;
GO

/* Any remaining NULLs → Uncategorized */
UPDATE p SET CategoryID = c.CategoryID
FROM dbo.Products p
CROSS JOIN dbo.Categories c
WHERE p.CategoryID IS NULL AND c.Name = N'Uncategorized';
GO

/* 5) Category Sales (last 30 days) — no ORDER BY inside the view */
CREATE OR ALTER VIEW dbo.vwCategorySales30D AS
SELECT
  c.CategoryID,
  c.Name AS CategoryName,
  COUNT(DISTINCT o.OrderID) AS Orders,
  SUM(od.Quantity)          AS Units,
  SUM(od.Subtotal)          AS Revenue
FROM dbo.OrderDetails od
JOIN dbo.Orders   o ON o.OrderID   = od.OrderID
JOIN dbo.Products p ON p.ProductID = od.ProductID
JOIN dbo.Categories c ON c.CategoryID = p.CategoryID
WHERE o.OrderDate >= DATEADD(DAY, -30, SYSUTCDATETIME())
GROUP BY c.CategoryID, c.Name;
GO
