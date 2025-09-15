IF OBJECT_ID('dbo.Products','U') IS NOT NULL
AND COL_LENGTH('dbo.Products','Status') IS NULL
BEGIN
  DECLARE @disable NVARCHAR(MAX) = (
    SELECT STRING_AGG('DISABLE TRIGGER ' + QUOTENAME(name) + ' ON dbo.Products;',' ')
    FROM sys.triggers WHERE parent_id = OBJECT_ID('dbo.Products')
  );
  IF @disable IS NOT NULL EXEC(@disable);

  ALTER TABLE dbo.Products
    ADD [Status] NVARCHAR(20) NOT NULL
      CONSTRAINT DF_Products_Status DEFAULT('Active') WITH VALUES;

  DECLARE @enable NVARCHAR(MAX) = (
    SELECT STRING_AGG('ENABLE TRIGGER ' + QUOTENAME(name) + ' ON dbo.Products;',' ')
    FROM sys.triggers WHERE parent_id = OBJECT_ID('dbo.Products')
  );
  IF @enable IS NOT NULL EXEC(@enable);
END
