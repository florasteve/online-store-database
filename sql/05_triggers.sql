USE OnlineStoreDB;
GO

/* Generic UpdatedAt triggers */
CREATE OR ALTER TRIGGER trg_Customers_UpdatedAt
ON dbo.Customers AFTER UPDATE AS
BEGIN
  SET NOCOUNT ON;
  UPDATE c SET UpdatedAt = SYSUTCDATETIME()
  FROM dbo.Customers c
  JOIN inserted i ON i.CustomerID = c.CustomerID;
END;
GO

CREATE OR ALTER TRIGGER trg_Products_UpdatedAt
ON dbo.Products AFTER UPDATE AS
BEGIN
  SET NOCOUNT ON;
  UPDATE p SET UpdatedAt = SYSUTCDATETIME()
  FROM dbo.Products p
  JOIN inserted i ON i.ProductID = p.ProductID;
END;
GO

CREATE OR ALTER TRIGGER trg_Orders_UpdatedAt
ON dbo.Orders AFTER UPDATE AS
BEGIN
  SET NOCOUNT ON;
  UPDATE o SET UpdatedAt = SYSUTCDATETIME()
  FROM dbo.Orders o
  JOIN inserted i ON i.OrderID = o.OrderID;
END;
GO

CREATE OR ALTER TRIGGER trg_OrderDetails_UpdatedAt
ON dbo.OrderDetails AFTER UPDATE AS
BEGIN
  SET NOCOUNT ON;
  UPDATE d SET UpdatedAt = SYSUTCDATETIME()
  FROM dbo.OrderDetails d
  JOIN inserted i ON i.OrderDetailID = d.OrderDetailID;
END;
GO
