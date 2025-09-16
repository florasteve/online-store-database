IF NOT EXISTS (SELECT 1 FROM sys.schemas WHERE name='SchemaTests') EXEC tSQLt.NewTestClass 'SchemaTests';

GO
CREATE OR ALTER PROCEDURE SchemaTests.[test Orders has Status column]
AS
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS
    WHERE TABLE_SCHEMA='dbo' AND TABLE_NAME='Orders' AND COLUMN_NAME='Status'
  ) EXEC tSQLt.Fail 'dbo.Orders.Status missing';
END;
GO

CREATE OR ALTER PROCEDURE SchemaTests.[test Products has CategoryID column]
AS
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS
    WHERE TABLE_SCHEMA='dbo' AND TABLE_NAME='Products' AND COLUMN_NAME='CategoryID'
  ) EXEC tSQLt.Fail 'dbo.Products.CategoryID missing';
END;
GO
