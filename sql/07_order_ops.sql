USE OnlineStoreDB;
GO
SET ANSI_NULLS ON;
SET QUOTED_IDENTIFIER ON;
GO

/* Cancel entire order: restock items, delete details, zero total, set Status */
CREATE OR ALTER PROCEDURE dbo.CancelOrder
  @OrderID INT
AS
BEGIN
  SET NOCOUNT ON;
  BEGIN TRY
    BEGIN TRAN;

    /* Restock all products from the order */
    UPDATE p
      SET p.StockQuantity = p.StockQuantity + od.Quantity
    FROM dbo.Products p
    JOIN dbo.OrderDetails od ON od.ProductID = p.ProductID
    WHERE od.OrderID = @OrderID;

    /* Remove details */
    DELETE FROM dbo.OrderDetails WHERE OrderID = @OrderID;

    /* Zero total + mark status */
    UPDATE dbo.Orders
      SET TotalAmount = 0, Status = 'Canceled', UpdatedAt = SYSUTCDATETIME()
    WHERE OrderID = @OrderID;

    COMMIT TRAN;
  END TRY
  BEGIN CATCH
    IF @@TRANCOUNT > 0 ROLLBACK TRAN;
    THROW;
  END CATCH
END;
GO

/* Return a single line item: restock qty, remove line, recompute total; mark order Closed if no lines remain */
CREATE OR ALTER PROCEDURE dbo.ReturnItem
  @OrderID INT,
  @OrderDetailID INT
AS
BEGIN
  SET NOCOUNT ON;
  BEGIN TRY
    BEGIN TRAN;

    DECLARE @pid INT, @qty INT;
    SELECT @pid = ProductID, @qty = Quantity
    FROM dbo.OrderDetails
    WHERE OrderDetailID = @OrderDetailID AND OrderID = @OrderID;

    IF @pid IS NULL
      THROW 50010, 'Order detail not found for this order.', 1;

    /* Restock */
    UPDATE dbo.Products
      SET StockQuantity = StockQuantity + @qty
    WHERE ProductID = @pid;

    /* Remove the line */
    DELETE FROM dbo.OrderDetails WHERE OrderDetailID = @OrderDetailID;

    /* Recompute total */
    UPDATE o
      SET TotalAmount = ISNULL((
        SELECT SUM(Subtotal) FROM dbo.OrderDetails WHERE OrderID = o.OrderID
      ), 0)
    FROM dbo.Orders o
    WHERE o.OrderID = @OrderID;

    /* If no lines remain, mark Closed */
    IF NOT EXISTS (SELECT 1 FROM dbo.OrderDetails WHERE OrderID = @OrderID)
      UPDATE dbo.Orders SET Status = 'Closed', UpdatedAt = SYSUTCDATETIME() WHERE OrderID = @OrderID;

    COMMIT TRAN;
  END TRY
  BEGIN CATCH
    IF @@TRANCOUNT > 0 ROLLBACK TRAN;
    THROW;
  END CATCH
END;
GO
