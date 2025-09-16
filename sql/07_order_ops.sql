USE ONLINESTOREDB;
GO
SET ANSI_NULLS ON;
SET QUOTED_IDENTIFIER ON;
GO

/* Cancel entire order: restock items, delete details, zero total, set Status */
CREATE OR ALTER PROCEDURE DBO.CANCELORDER
    @OrderID INT
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        BEGIN TRAN;

        /* Restock all products from the order */
        UPDATE P
        SET P.STOCKQUANTITY = P.STOCKQUANTITY + OD.QUANTITY
        FROM DBO.PRODUCTS AS P
        INNER JOIN DBO.ORDERDETAILS AS OD ON P.PRODUCTID = OD.PRODUCTID
        WHERE OD.ORDERID = @OrderID;

        /* Remove details */
        DELETE FROM DBO.ORDERDETAILS
        WHERE ORDERID = @OrderID;

        /* Zero total + mark status */
        UPDATE DBO.ORDERS
        SET TOTALAMOUNT = 0, STATUS = 'Canceled', UPDATEDAT = SYSUTCDATETIME()
        WHERE ORDERID = @OrderID;

        COMMIT TRAN;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRAN;
        THROW;
    END CATCH
END;
GO

/* Return a single line item: restock qty, remove line, recompute total; mark order Closed if no lines remain */
CREATE OR ALTER PROCEDURE DBO.RETURNITEM
    @OrderID INT,
    @OrderDetailID INT
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        BEGIN TRAN;

        DECLARE @pid INT, @qty INT;
        SELECT
            @pid = PRODUCTID,
            @qty = QUANTITY
        FROM DBO.ORDERDETAILS
        WHERE ORDERDETAILID = @OrderDetailID AND ORDERID = @OrderID;

        IF @pid IS NULL
            THROW 50010, 'Order detail not found for this order.', 1;

        /* Restock */
        UPDATE DBO.PRODUCTS
        SET STOCKQUANTITY = STOCKQUANTITY + @qty
        WHERE PRODUCTID = @pid;

        /* Remove the line */
        DELETE FROM DBO.ORDERDETAILS
        WHERE ORDERDETAILID = @OrderDetailID;

        /* Recompute total */
        UPDATE O
        SET
            TOTALAMOUNT = ISNULL((
                SELECT SUM(ORDERDETAILS.SUBTOTAL) FROM DBO.ORDERDETAILS
                WHERE ORDERDETAILS.ORDERID = O.ORDERID
            ), 0)
        FROM DBO.ORDERS AS O
        WHERE O.ORDERID = @OrderID;

        /* If no lines remain, mark Closed */
        IF
            NOT EXISTS (
                SELECT 1 FROM DBO.ORDERDETAILS
                WHERE ORDERID = @OrderID
            )
            UPDATE DBO.ORDERS SET STATUS = 'Closed', UPDATEDAT = SYSUTCDATETIME()
            WHERE ORDERID = @OrderID;

        COMMIT TRAN;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRAN;
        THROW;
    END CATCH
END;
GO
