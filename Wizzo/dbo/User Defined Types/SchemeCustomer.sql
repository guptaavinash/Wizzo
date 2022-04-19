CREATE TYPE [dbo].[SchemeCustomer] AS TABLE (
    [SchemeDetID]  INT     NULL,
    [CustomerID]   INT     NOT NULL,
    [CustomerType] INT     NOT NULL,
    [flgActive]    TINYINT NULL);

