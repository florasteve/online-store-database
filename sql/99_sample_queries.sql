USE OnlineStoreDB;
GO

/* Last 30 days revenue by day */
SELECT CAST(OrderDate AS DATE) AS [Day], SUM(TotalAmount) AS Revenue
FROM dbo.Orders
WHERE OrderDate >= DATEADD(DAY, -30, SYSUTCDATETIME())
GROUP BY CAST(OrderDate AS DATE)
ORDER BY [Day] DESC;

/* Top customers */
SELECT TOP 10 c.CustomerID, c.Name, SUM(o.TotalAmount) AS Spend
FROM dbo.Customers c
JOIN dbo.Orders o ON o.CustomerID = c.CustomerID
GROUP BY c.CustomerID, c.Name
ORDER BY Spend DESC;

/* Low stock alerts */
SELECT ProductID, Name, StockQuantity
FROM dbo.Products
WHERE StockQuantity < 10
ORDER BY StockQuantity ASC;

/* Best sellers (view) */
SELECT * FROM dbo.vwBestSellers30D ORDER BY UnitsSold DESC;
