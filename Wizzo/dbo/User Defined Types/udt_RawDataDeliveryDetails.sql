CREATE TYPE [dbo].[udt_RawDataDeliveryDetails] AS TABLE (
    [StoreID]        NVARCHAR (500) NULL,
    [VisitID]        NVARCHAR (500) NULL,
    [StoreVisitCode] NVARCHAR (500) NULL,
    [BillToAddress]  NVARCHAR (500) NULL,
    [ShipToAddress]  NVARCHAR (500) NULL,
    [Sstat]          NVARCHAR (500) NULL);

