USE OnlineStoreDB;
GO
IF SCHEMA_ID('OrderOpsTests') IS NULL
  EXEC tSQLt.NewTestClass @ClassName = N'OrderOpsTests';
GO
CREATE OR ALTER PROCEDURE OrderOpsTests.[test_CloseOrder_sets_status_Closed]
AS
BEGIN
  -- Arrange
  EXEC tSQLt.FakeTable @TableName = N'dbo.Orders';
  EXEC tSQLt.FakeTable @TableName = N'dbo.OrderDetails';
  EXEC tSQLt.FakeTable @TableName = N'dbo.Products';

  INSERT dbo.Products(ProductID, Name, Price, StockQuantity, CreatedAt, UpdatedAt)
  VALUES (1, N'Widget', 10.00, 100, SYSUTCDATETIME(), SYSUTCDATETIME());

  INSERT dbo.Orders(OrderID, CustomerID, OrderDate, Status, TotalAmount, CreatedAt, UpdatedAt)
  VALUES (100, 1, SYSUTCDATETIME(), N'Open', 20.00, SYSUTCDATETIME(), SYSUTCDATETIME());

  INSERT dbo.OrderDetails(OrderDetailID, OrderID, ProductID, Quantity, UnitPrice, Subtotal, CreatedAt, UpdatedAt)
  VALUES (200, 100, 1, 2, 10.00, 20.00, SYSUTCDATETIME(), SYSUTCDATETIME());

  -- Act
  EXEC dbo.CloseOrder @OrderID = 100;

  -- Assert
  DECLARE @actual nvarchar(20) = (SELECT Status FROM dbo.Orders WHERE OrderID = 100);
  EXEC tSQLt.AssertEqualsString @Expected = N'Closed', @Actual = @actual, @Message = N'Status should be Closed';
END;
GO
