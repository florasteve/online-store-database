@echo off
setlocal
if not exist "data\reports" mkdir "data\reports"
set "OUT=data\reports\low_stock_report.csv"
echo ProductID,Name,StockQuantity> "%OUT%"
docker exec -i store-mssql /opt/mssql-tools18/bin/sqlcmd ^
  -C -S localhost -U SA -P "YourStrong!Passw0rd" -d OnlineStoreDB ^
  -h -1 -W -s , ^
  -Q "SET NOCOUNT ON; SELECT ProductID, Name, StockQuantity FROM dbo.vwLowStock ORDER BY StockQuantity ASC, Name ASC;" >> "%OUT%"
echo Wrote %OUT%
endlocal
