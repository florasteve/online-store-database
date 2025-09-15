USE OnlineStoreDB;
GO

SET ANSI_NULLS ON;
SET QUOTED_IDENTIFIER ON;
GO

/* Create an order */
CREATE OR ALTER PROCEDURE dbo.CreateOrder
  @CustomerID INT,
  @OrderID INT OUTPUT
AS
BEGIN
  SET NOCOUNT ON;
  INSERT INTO dbo.Orders(CustomerID) VALUES (@CustomerID);
  SET @OrderID = SCOPE_IDENTITY();
END;
GO

/* Add a line item (validates stock, updates totals & decrements stock) */
CREATE OR ALTER PROCEDURE dbo.AddOrderItem
  @OrderID INT,
  @ProductID INT,
  @Quantity INT
AS
BEGIN
  SET NOCOUNT ON;

  DECLARE @unit DECIMAL(10,2), @available INT;

  SELECT @unit = Price, @available = StockQuantity
  FROM dbo.Products WHERE ProductID = @ProductID;

  IF @unit IS NULL
    THROW 50001, 'Product not found.', 1;

  IF @available < @Quantity
    THROW 50002, 'Insufficient stock.', 1;

  INSERT INTO dbo.OrderDetails(OrderID, ProductID, Quantity, UnitPrice)
  VALUES (@OrderID, @ProductID, @Quantity, @unit);

  /* Update order total */
  UPDATE o
    SET TotalAmount = (
      SELECT SUM(Subtotal) FROM dbo.OrderDetails WHERE OrderID = o.OrderID
    )
  FROM dbo.Orders o
  WHERE o.OrderID = @OrderID;

  /* Decrement stock */
  UPDATE dbo.Products
    SET StockQuantity = StockQuantity - @Quantity
  WHERE ProductID = @ProductID;
END;
GO
