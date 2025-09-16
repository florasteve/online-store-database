USE ONLINESTOREDB;
GO
IF SCHEMA_ID('OrderOpsTests') IS NULL
    EXEC TSQLT.NEWTESTCLASS @ClassName = N'OrderOpsTests';
GO
CREATE OR ALTER PROCEDURE ORDEROPSTESTS.[test_CancelOrder_zeros_total_restock_and_deletes_details]
AS
BEGIN
    -- Arrange
    EXEC TSQLT.FAKETABLE @TableName = N'dbo.Orders';
    EXEC TSQLT.FAKETABLE @TableName = N'dbo.OrderDetails';
    EXEC TSQLT.FAKETABLE @TableName = N'dbo.Products';

    INSERT DBO.PRODUCTS (PRODUCTID, NAME, PRICE, STOCKQUANTITY, CREATEDAT, UPDATEDAT)
    VALUES (2, N'Cable', 8.99, 10, SYSUTCDATETIME(), SYSUTCDATETIME());

    INSERT DBO.ORDERS (ORDERID, CUSTOMERID, ORDERDATE, STATUS, TOTALAMOUNT, CREATEDAT, UPDATEDAT)
    VALUES (101, 1, SYSUTCDATETIME(), N'Open', 17.98, SYSUTCDATETIME(), SYSUTCDATETIME());

    INSERT DBO.ORDERDETAILS (ORDERDETAILID, ORDERID, PRODUCTID, QUANTITY, UNITPRICE, SUBTOTAL, CREATEDAT, UPDATEDAT)
    VALUES (201, 101, 2, 2, 8.99, 17.98, SYSUTCDATETIME(), SYSUTCDATETIME());

    -- Act
    EXEC DBO.CANCELORDER @OrderID = 101;

    -- Assert: total is zero & status Canceled
    DECLARE @total decimal(
        10, 2) = (
        SELECT TOTALAMOUNT FROM DBO.ORDERS
        WHERE ORDERID = 101
    );
    DECLARE @status nvarchar(
        20) = (
        SELECT STATUS FROM DBO.ORDERS
        WHERE ORDERID = 101
    );
    EXEC TSQLT.ASSERTEQUALSDECIMAL @Expected = 0.00, @Actual = @total, @Message = N'Total should be 0 after cancel';
    EXEC TSQLT.ASSERTEQUALSSTRING @Expected = N'Canceled', @Actual = @status, @Message = N'Status should be Canceled';

    -- Assert: details removed
    DECLARE @details int = (
        SELECT COUNT(*) FROM DBO.ORDERDETAILS
        WHERE ORDERID = 101
    );
    EXEC TSQLT.ASSERTEQUALS @Expected = 0, @Actual = @details, @Message = N'OrderDetails should be deleted';

    -- Assert: restocked from 10 to 12
    DECLARE @stock int = (
        SELECT STOCKQUANTITY FROM DBO.PRODUCTS
        WHERE PRODUCTID = 2
    );
    EXEC TSQLT.ASSERTEQUALS @Expected = 12, @Actual = @stock, @Message = N'Products should be restocked';
END;
GO
