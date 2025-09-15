USE OnlineStoreDB;
GO
SET ANSI_NULLS ON;
SET QUOTED_IDENTIFIER ON;
GO

CREATE OR ALTER VIEW dbo.vwOrderSummaryWithStatus AS
  SELECT
    o.OrderID, o.CustomerID, o.OrderDate, o.Status,
    o.TotalAmount,
    COUNT(od.OrderDetailID) AS LineCount
  FROM dbo.Orders o
  LEFT JOIN dbo.OrderDetails od ON od.OrderID = o.OrderID
  GROUP BY o.OrderID, o.CustomerID, o.OrderDate, o.Status, o.TotalAmount;
GO
