IF COL_LENGTH('dbo.Orders', 'Status') IS NULL
    BEGIN
        ALTER TABLE dbo.orders
        ADD status NVARCHAR(20) NOT NULL
        CONSTRAINT df_orders_status DEFAULT ('Pending');
        ALTER TABLE dbo.orders
        ADD CONSTRAINT ck_orders_status
        CHECK (status IN ('Pending', 'Paid', 'Shipped', 'Delivered', 'Canceled', 'Returned'));
    END
