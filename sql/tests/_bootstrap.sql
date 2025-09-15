USE OnlineStoreDB;
GO
EXEC sp_configure 'show advanced options', 1; RECONFIGURE;
EXEC sp_configure 'clr enabled', 1; RECONFIGURE;
ALTER DATABASE OnlineStoreDB SET TRUSTWORTHY ON;
EXEC sys.sp_changedbowner 'sa';
GO
