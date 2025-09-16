IF OBJECT_ID('dbo.Categories','U') IS NULL
BEGIN
  CREATE TABLE dbo.Categories(
    CategoryID INT IDENTITY(1,1) PRIMARY KEY,
    Name NVARCHAR(100) NOT NULL UNIQUE,
    IsActive BIT NOT NULL CONSTRAINT DF_Categories_IsActive DEFAULT(1)
  );
END;

IF OBJECT_ID('dbo.Products','U') IS NOT NULL
AND COL_LENGTH('dbo.Products','CategoryID') IS NULL
BEGIN
  ALTER TABLE dbo.Products ADD CategoryID INT NULL;
  IF NOT EXISTS (SELECT 1 FROM dbo.Categories WHERE Name='Uncategorized')
    INSERT INTO dbo.Categories(Name) VALUES ('Uncategorized');
  DECLARE @DefaultCategoryID INT = (SELECT TOP 1 CategoryID FROM dbo.Categories WHERE Name='Uncategorized');
  UPDATE dbo.Products SET CategoryID = ISNULL(CategoryID, @DefaultCategoryID);
  ALTER TABLE dbo.Products ALTER COLUMN CategoryID INT NOT NULL;
  IF NOT EXISTS (
    SELECT 1 FROM sys.foreign_keys WHERE name='FK_Products_Categories'
  )
    ALTER TABLE dbo.Products ADD CONSTRAINT FK_Products_Categories
      FOREIGN KEY(CategoryID) REFERENCES dbo.Categories(CategoryID);
  IF NOT EXISTS (
    SELECT 1 FROM sys.indexes WHERE name='IX_Products_CategoryID' AND object_id=OBJECT_ID('dbo.Products')
  )
    CREATE INDEX IX_Products_CategoryID ON dbo.Products(CategoryID);
END
