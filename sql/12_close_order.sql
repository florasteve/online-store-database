USE OnlineStoreDB;
GO
SET ANSI_NULLS ON;
SET QUOTED_IDENTIFIER ON;
GO

/* CloseOrder: Open → Closed; recompute total and lock status */
CREATE OR ALTER PROCEDURE dbo.CloseOrder
  @OrderID INT
AS
BEGIN
  SET NOCOUNT ON;

  DECLARE @status NVARCHAR(20);
  SELECT @status = Status FROM dbo.Orders WHERE OrderID = @OrderID;

  IF @status IS NULL
    THROW 50020, 'Order not found.', 1;

  IF @status = 'Canceled'
    THROW 50021, 'Cannot close a canceled order.', 1;

  IF @status = 'Closed'
    RETURN; -- already closed

  IF NOT EXISTS (SELECT 1 FROM dbo.OrderDetails WHERE OrderID = @OrderID)
    THROW 50022, 'Cannot close an order with no line items.', 1;

  BEGIN TRY
    BEGIN TRAN;

    /* Recompute total defensively */
    UPDATE o
      SET TotalAmount = (SELECT SUM(Subtotal) FROM dbo.OrderDetails WHERE OrderID = @OrderID),
          Status = 'Closed',
          UpdatedAt = SYSUTCDATETIME()
    FROM dbo.Orders o
    WHERE o.OrderID = @OrderID;

    COMMIT TRAN;
  END TRY
  BEGIN CATCH
    IF @@TRANCOUNT > 0 ROLLBACK TRAN;
    THROW;
  END CATCH
END;
GO
