USE ONLINESTOREDB;
GO

SET ANSI_NULLS ON;
SET QUOTED_IDENTIFIER ON;
GO

/* Create an order */
CREATE OR ALTER PROCEDURE DBO.CREATEORDER
    @CustomerID INT,
    @OrderID INT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    INSERT INTO DBO.ORDERS (CUSTOMERID) VALUES (@CustomerID);
    SET @OrderID = SCOPE_IDENTITY();
END;
GO

/* Add a line item (validates stock, updates totals & decrements stock) */
CREATE OR ALTER PROCEDURE DBO.ADDORDERITEM
    @OrderID INT,
    @ProductID INT,
    @Quantity INT
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @unit DECIMAL(10, 2), @available INT;

    SELECT
        @unit = PRICE,
        @available = STOCKQUANTITY
    FROM DBO.PRODUCTS
    WHERE PRODUCTID = @ProductID;

    IF @unit IS NULL
        THROW 50001, 'Product not found.', 1;

    IF @available < @Quantity
        THROW 50002, 'Insufficient stock.', 1;

    INSERT INTO DBO.ORDERDETAILS (ORDERID, PRODUCTID, QUANTITY, UNITPRICE)
    VALUES (@OrderID, @ProductID, @Quantity, @unit);

    /* Update order total */
    UPDATE O
    SET
        TOTALAMOUNT = (
            SELECT SUM(ORDERDETAILS.SUBTOTAL) FROM DBO.ORDERDETAILS
            WHERE ORDERDETAILS.ORDERID = O.ORDERID
        )
    FROM DBO.ORDERS AS O
    WHERE O.ORDERID = @OrderID;

    /* Decrement stock */
    UPDATE DBO.PRODUCTS
    SET STOCKQUANTITY = STOCKQUANTITY - @Quantity
    WHERE PRODUCTID = @ProductID;
END;
GO
