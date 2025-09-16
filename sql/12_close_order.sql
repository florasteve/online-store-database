USE ONLINESTOREDB;
GO
SET ANSI_NULLS ON;
SET QUOTED_IDENTIFIER ON;
GO

/* CloseOrder: Open → Closed; recompute total and lock status */
CREATE OR ALTER PROCEDURE DBO.CLOSEORDER
    @OrderID INT
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @status NVARCHAR(20);
    SELECT @status = STATUS FROM DBO.ORDERS
    WHERE ORDERID = @OrderID;

    IF @status IS NULL
        THROW 50020, 'Order not found.', 1;

    IF @status = 'Canceled'
        THROW 50021, 'Cannot close a canceled order.', 1;

    IF @status = 'Closed'
        RETURN; -- already closed

    IF
        NOT EXISTS (
            SELECT 1 FROM DBO.ORDERDETAILS
            WHERE ORDERID = @OrderID
        )
        THROW 50022, 'Cannot close an order with no line items.', 1;

    BEGIN TRY
        BEGIN TRAN;

        /* Recompute total defensively */
        UPDATE O
        SET
            TOTALAMOUNT = (
                SELECT SUM(SUBTOTAL) FROM DBO.ORDERDETAILS
                WHERE ORDERID = @OrderID
            ),
            STATUS = 'Closed',
            UPDATEDAT = SYSUTCDATETIME()
        FROM DBO.ORDERS AS O
        WHERE O.ORDERID = @OrderID;

        COMMIT TRAN;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRAN;
        THROW;
    END CATCH
END;
GO
