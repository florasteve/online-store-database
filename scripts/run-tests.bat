@echo off
setlocal
set "SA_PASSWORD=YourStrong!Passw0rd"

if not exist "sql\tests\_tSQLt\tSQLt.class.sql" (
  echo Missing: sql\tests\_tSQLt\tSQLt.class.sql. Download from https://tsqlt.org/ and re-run.
  exit /b 1
)

docker exec -i store-mssql /opt/mssql-tools18/bin/sqlcmd -C -S localhost -U SA -P "%SA_PASSWORD%" -Q "EXEC sp_configure 'clr enabled',1; RECONFIGURE;"
docker exec -i store-mssql /opt/mssql-tools18/bin/sqlcmd -C -S localhost -U SA -P "%SA_PASSWORD%" -d OnlineStoreDB -i "/var/opt/sql/tests/_tSQLt/tSQLt.class.sql"
docker exec -i store-mssql /opt/mssql-tools18/bin/sqlcmd -C -S localhost -U SA -P "%SA_PASSWORD%" -d OnlineStoreDB -i "/var/opt/sql/tests/_bootstrap.sql"
docker exec -i store-mssql /opt/mssql-tools18/bin/sqlcmd -C -S localhost -U SA -P "%SA_PASSWORD%" -d OnlineStoreDB -i "/var/opt/sql/tests/10_OrderOps_Tests.sql"
docker exec -i store-mssql /opt/mssql-tools18/bin/sqlcmd -C -S localhost -U SA -P "%SA_PASSWORD%" -d OnlineStoreDB -Q "EXEC tSQLt.RunAll;"
endlocal
