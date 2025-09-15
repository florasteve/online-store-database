USE OnlineStoreDB;
GO
IF SCHEMA_ID('OrderOpsTests') IS NULL
  EXEC tSQLt.NewTestClass @ClassName = N'OrderOpsTests';
GO
CREATE OR ALTER PROCEDURE OrderOpsTests.[test_CancelOrder_zeros_total_restock_and_deletes_details]
AS
BEGIN
  -- Arrange
  EXEC tSQLt.FakeTable @TableName = N'dbo.Orders';
  EXEC tSQLt.FakeTable @TableName = N'dbo.OrderDetails';
  EXEC tSQLt.FakeTable @TableName = N'dbo.Products';

  INSERT dbo.Products(ProductID, Name, Price, StockQuantity, CreatedAt, UpdatedAt)
  VALUES (2, N'Cable', 8.99, 10, SYSUTCDATETIME(), SYSUTCDATETIME());

  INSERT dbo.Orders(OrderID, CustomerID, OrderDate, Status, TotalAmount, CreatedAt, UpdatedAt)
  VALUES (101, 1, SYSUTCDATETIME(), N'Open', 17.98, SYSUTCDATETIME(), SYSUTCDATETIME());

  INSERT dbo.OrderDetails(OrderDetailID, OrderID, ProductID, Quantity, UnitPrice, Subtotal, CreatedAt, UpdatedAt)
  VALUES (201, 101, 2, 2, 8.99, 17.98, SYSUTCDATETIME(), SYSUTCDATETIME());

  -- Act
  EXEC dbo.CancelOrder @OrderID = 101;

  -- Assert: total is zero & status Canceled
  DECLARE @total decimal(10,2) = (SELECT TotalAmount FROM dbo.Orders WHERE OrderID = 101);
  DECLARE @status nvarchar(20) = (SELECT Status FROM dbo.Orders WHERE OrderID = 101);
  EXEC tSQLt.AssertEqualsDecimal @Expected = 0.00, @Actual = @total, @Message = N'Total should be 0 after cancel';
  EXEC tSQLt.AssertEqualsString  @Expected = N'Canceled', @Actual = @status, @Message = N'Status should be Canceled';

  -- Assert: details removed
  DECLARE @details int = (SELECT COUNT(*) FROM dbo.OrderDetails WHERE OrderID = 101);
  EXEC tSQLt.AssertEquals @Expected = 0, @Actual = @details, @Message = N'OrderDetails should be deleted';

  -- Assert: restocked from 10 to 12
  DECLARE @stock int = (SELECT StockQuantity FROM dbo.Products WHERE ProductID = 2);
  EXEC tSQLt.AssertEquals @Expected = 12, @Actual = @stock, @Message = N'Products should be restocked';
END;
GO
