USE OnlineStoreDB;
GO
IF SCHEMA_ID('OrderOpsTests') IS NULL
  EXEC tSQLt.NewTestClass @ClassName = N'OrderOpsTests';
GO
