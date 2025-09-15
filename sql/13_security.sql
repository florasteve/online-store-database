:setvar APPUSER_PASSWORD "App$trongPassw0rd!"
USE master;
GO
IF NOT EXISTS (SELECT 1 FROM sys.sql_logins WHERE name = N'appuser')
  CREATE LOGIN appuser WITH PASSWORD = '$(APPUSER_PASSWORD)';
GO

USE OnlineStoreDB;
GO
IF NOT EXISTS (SELECT 1 FROM sys.database_principals WHERE name = N'appuser')
  CREATE USER appuser FOR LOGIN appuser;
GO

-- EXECUTE on procs in dbo (adjust if you add other schemas)
GRANT EXECUTE ON SCHEMA::dbo TO appuser;
GO

-- Select on reporting views only (explicit, avoids table access)
GRANT SELECT ON OBJECT::dbo.vwOrderSummary TO appuser;
GRANT SELECT ON OBJECT::dbo.vwBestSellers30D TO appuser;
GRANT SELECT ON OBJECT::dbo.vwOrderSummaryWithStatus TO appuser;
GRANT SELECT ON OBJECT::dbo.vwLowStock TO appuser;
GRANT SELECT ON OBJECT::dbo.vwCategorySales30D TO appuser;
GO
