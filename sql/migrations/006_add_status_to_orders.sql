IF COL_LENGTH('dbo.Orders','Status') IS NULL
BEGIN
  ALTER TABLE dbo.Orders
    ADD Status NVARCHAR(20) NOT NULL
      CONSTRAINT DF_Orders_Status DEFAULT ('Pending');
  ALTER TABLE dbo.Orders
    ADD CONSTRAINT CK_Orders_Status
      CHECK (Status IN ('Pending','Paid','Shipped','Delivered','Canceled','Returned'));
END
