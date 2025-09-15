@echo off
setlocal
docker ps --filter "name=store-mssql"
echo.
docker exec -i store-mssql /opt/mssql-tools18/bin/sqlcmd -C -S localhost -U SA -P "YourStrong!Passw0rd" -d OnlineStoreDB -Q "SET NOCOUNT ON;
SELECT COUNT() AS Customers FROM dbo.Customers;
SELECT COUNT() AS Products FROM dbo.Products;
SELECT COUNT(*) AS Orders FROM dbo.Orders;
SELECT TOP 5 * FROM dbo.vwOrderSummaryWithStatus ORDER BY OrderID DESC;"
endlocal
