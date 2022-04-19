CREATE TYPE [dbo].[udt_RawDataInvoiceExecution] AS TABLE (
    [TransDate]          NVARCHAR (500) NULL,
    [OrderID]            NVARCHAR (500) NULL,
    [strData]            NVARCHAR (500) NULL,
    [AdditionalDiscount] NVARCHAR (500) NULL,
    [flgCancel]          NVARCHAR (500) NULL,
    [CancelRemark]       NVARCHAR (500) NULL,
    [CancelReasonId]     NVARCHAR (500) NULL,
    [InvNumber]          NVARCHAR (500) NULL,
    [InvDate]            NVARCHAR (500) NULL);

