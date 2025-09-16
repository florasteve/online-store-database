IF OBJECT_ID('dbo.Categories', 'U') IS NULL
    BEGIN
        CREATE TABLE dbo.categories (
            categoryid INT IDENTITY (1, 1) PRIMARY KEY,
            name NVARCHAR(100) NOT NULL UNIQUE,
            isactive BIT NOT NULL CONSTRAINT df_categories_isactive DEFAULT (1)
        );
    END;

IF
    OBJECT_ID('dbo.Products', 'U') IS NOT NULL
    AND COL_LENGTH('dbo.Products', 'CategoryID') IS NULL
    BEGIN
        ALTER TABLE dbo.products ADD categoryid INT NULL;
        IF
            NOT EXISTS (
                SELECT 1 FROM dbo.categories
                WHERE name = 'Uncategorized'
            )
            INSERT INTO dbo.categories (name) VALUES ('Uncategorized');
        DECLARE @DefaultCategoryID INT = (
            SELECT TOP 1 categoryid FROM dbo.categories
            WHERE name = 'Uncategorized'
        );
        UPDATE dbo.products SET categoryid = ISNULL(categoryid, @DefaultCategoryID);
        ALTER TABLE dbo.products ALTER COLUMN categoryid INT NOT NULL;
        IF
            NOT EXISTS (
                SELECT 1 FROM sys.foreign_keys
                WHERE name = 'FK_Products_Categories'
            )
            ALTER TABLE dbo.products ADD CONSTRAINT fk_products_categories
            FOREIGN KEY (categoryid) REFERENCES dbo.categories (categoryid);
        IF
            NOT EXISTS (
                SELECT 1 FROM sys.indexes
                WHERE name = 'IX_Products_CategoryID' AND object_id = OBJECT_ID('dbo.Products')
            )
            CREATE INDEX ix_products_categoryid ON dbo.products (categoryid);
    END
