IF OBJECT_ID('dbo.Products','U') IS NOT NULL
AND COL_LENGTH('dbo.Products','Status') IS NOT NULL
AND NOT EXISTS (
  SELECT 1 FROM sys.check_constraints
  WHERE parent_object_id = OBJECT_ID('dbo.Products') AND name = 'CK_Products_Status'
)
BEGIN
  ALTER TABLE dbo.Products WITH CHECK
    ADD CONSTRAINT CK_Products_Status CHECK ([Status] IN ('Active','Discontinued'));
  ALTER TABLE dbo.Products CHECK CONSTRAINT CK_Products_Status;
END
