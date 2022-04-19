CREATE TYPE [dbo].[udt_RawDataCollectionData] AS TABLE (
    [StoreVisitCode]     NVARCHAR (500) NULL,
    [VisitID]            NVARCHAR (500) NULL,
    [StoreID]            NVARCHAR (500) NULL,
    [PaymentMode]        NVARCHAR (500) NULL,
    [PaymentModeID]      NVARCHAR (500) NULL,
    [Amount]             NVARCHAR (500) NULL,
    [RefNoChequeNoTrnNo] NVARCHAR (500) NULL,
    [Date]               NVARCHAR (500) NULL,
    [Bank]               NVARCHAR (500) NULL,
    [TmpInvoiceCodePDA]  NVARCHAR (500) NULL,
    [CollectionCode]     NVARCHAR (500) NULL);

