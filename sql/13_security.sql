USE master;
GO
IF
    NOT EXISTS (
        SELECT 1 FROM sys.sql_logins
        WHERE name = N'appuser'
    )
    CREATE LOGIN appuser WITH PASSWORD = 'App$trongPassw0rd!';
GO

USE onlinestoredb;
GO
IF
    NOT EXISTS (
        SELECT 1 FROM sys.database_principals
        WHERE name = N'appuser'
    )
    CREATE USER appuser FOR LOGIN appuser;
GO

-- EXECUTE on procs in dbo (adjust if you add other schemas)
GRANT EXECUTE ON SCHEMA::dbo TO appuser;
GO

-- Select on reporting views only (explicit, avoids table access)
GRANT SELECT ON OBJECT::dbo.vwordersummary TO appuser;
GRANT SELECT ON OBJECT::dbo.vwbestsellers30d TO appuser;
GRANT SELECT ON OBJECT::dbo.vwordersummarywithstatus TO appuser;
GRANT SELECT ON OBJECT::dbo.vwlowstock TO appuser;
GRANT SELECT ON OBJECT::dbo.vwcategorysales30d TO appuser;
GO
