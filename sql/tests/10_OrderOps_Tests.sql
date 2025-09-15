USE OnlineStoreDB;
GO
IF NOT EXISTS (SELECT 1 FROM sys.schemas WHERE name = 'test_OrderOps')
  EXEC tSQLt.NewTestClass 'test_OrderOps';
GO
CREATE OR ALTER PROCEDURE test_OrderOps.[test CloseOrder closes and totals]
AS
BEGIN
  EXEC tSQLt.FakeTable 'dbo.Orders';
  EXEC tSQLt.FakeTable 'dbo.OrderDetails';

  INSERT dbo.Orders(OrderID, CustomerID, OrderDate, TotalAmount, CreatedAt, UpdatedAt, Status)
  VALUES (1, 1, SYSUTCDATETIME(), 0, SYSUTCDATETIME(), SYSUTCDATETIME(), 'Open');

  INSERT dbo.OrderDetails(OrderID, ProductID, Quantity, UnitPrice, CreatedAt, UpdatedAt)
  VALUES (1, 1, 2, 10.00, SYSUTCDATETIME(), SYSUTCDATETIME()); -- Subtotal=20

  EXEC dbo.CloseOrder @OrderID = 1;

  EXEC tSQLt.AssertEquals 'Closed', (SELECT Status FROM dbo.Orders WHERE OrderID=1);
  EXEC tSQLt.AssertEquals 20.00,    (SELECT TotalAmount FROM dbo.Orders WHERE OrderID=1);
END;
GO
