USE OnlineStoreDB;
GO
/* Add Status column if missing */
IF COL_LENGTH('dbo.Orders','Status') IS NULL
BEGIN
  ALTER TABLE dbo.Orders ADD Status NVARCHAR(20) NOT NULL CONSTRAINT DF_Orders_Status DEFAULT ('Open');
END;
GO

/* Index for common filters */
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name='IX_Orders_Status_OrderDate' AND object_id=OBJECT_ID('dbo.Orders'))
  CREATE INDEX IX_Orders_Status_OrderDate ON dbo.Orders(Status, OrderDate DESC);
GO
