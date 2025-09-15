USE OnlineStoreDB;
GO

CREATE OR ALTER VIEW dbo.vwOrderSummary AS
  SELECT
    o.OrderID,
    o.CustomerID,
    o.OrderDate,
    o.TotalAmount,
    COUNT(od.OrderDetailID) AS LineCount
  FROM dbo.Orders o
  LEFT JOIN dbo.OrderDetails od ON od.OrderID = o.OrderID
  GROUP BY o.OrderID, o.CustomerID, o.OrderDate, o.TotalAmount;
GO

CREATE OR ALTER VIEW dbo.vwBestSellers30D AS
  SELECT TOP 20
    od.ProductID,
    p.Name,
    SUM(od.Quantity) AS UnitsSold,
    SUM(od.Subtotal) AS Revenue
  FROM dbo.OrderDetails od
  JOIN dbo.Orders o   ON o.OrderID = od.OrderID
  JOIN dbo.Products p ON p.ProductID = od.ProductID
  WHERE o.OrderDate >= DATEADD(DAY, -30, SYSUTCDATETIME())
  GROUP BY od.ProductID, p.Name
  ORDER BY UnitsSold DESC, Revenue DESC;
GO
