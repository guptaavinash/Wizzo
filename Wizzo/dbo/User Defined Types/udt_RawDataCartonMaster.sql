CREATE TYPE [dbo].[udt_RawDataCartonMaster] AS TABLE (
    [StoreID]          VARCHAR (200) NULL,
    [Invoicenumber]    VARCHAR (200) NULL,
    [CartonID]         VARCHAR (200) NULL,
    [CategoryID]       VARCHAR (10)  NULL,
    [UOMType]          VARCHAR (30)  NULL,
    [NoOfCarton]       SMALLINT      NULL,
    [TotalExpectedQty] INT           NULL,
    [TotalActualQty]   INT           NULL,
    [CartonDiscount]   VARCHAR (100) NULL);

