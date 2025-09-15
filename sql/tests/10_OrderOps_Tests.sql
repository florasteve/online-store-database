USE OnlineStoreDB;
GO
IF SCHEMA_ID('OrderOpsTests') IS NULL
  EXEC tSQLt.NewTestClass @ClassName = N'OrderOpsTests';
GO
CREATE OR ALTER PROCEDURE OrderOpsTests.[test_sanity_passes]
AS
BEGIN
  EXEC tSQLt.AssertEquals @Expected = 1, @Actual = 1, @Message = N'sanity';
END;
GO
