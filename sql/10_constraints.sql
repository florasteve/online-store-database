USE OnlineStoreDB;
GO
SET ANSI_NULLS ON;
SET QUOTED_IDENTIFIER ON;
GO

IF NOT EXISTS (SELECT 1 FROM sys.check_constraints WHERE name='CK_Orders_Status' AND parent_object_id=OBJECT_ID('dbo.Orders'))
  ALTER TABLE dbo.Orders ADD CONSTRAINT CK_Orders_Status CHECK (Status IN ('Open','Closed','Canceled'));
GO

IF NOT EXISTS (SELECT 1 FROM sys.check_constraints WHERE name='CK_Orders_TotalAmount' AND parent_object_id=OBJECT_ID('dbo.Orders'))
  ALTER TABLE dbo.Orders ADD CONSTRAINT CK_Orders_TotalAmount CHECK (TotalAmount >= 0);
GO

IF NOT EXISTS (SELECT 1 FROM sys.check_constraints WHERE name='CK_Customers_Email_Format' AND parent_object_id=OBJECT_ID('dbo.Customers'))
  ALTER TABLE dbo.Customers ADD CONSTRAINT CK_Customers_Email_Format CHECK (Email LIKE '%_@_%._%');
GO

IF NOT EXISTS (SELECT 1 FROM sys.check_constraints WHERE name='CK_Products_Name_NotBlank' AND parent_object_id=OBJECT_ID('dbo.Products'))
  ALTER TABLE dbo.Products ADD CONSTRAINT CK_Products_Name_NotBlank CHECK (LEN(LTRIM(RTRIM(Name))) > 0);
GO
