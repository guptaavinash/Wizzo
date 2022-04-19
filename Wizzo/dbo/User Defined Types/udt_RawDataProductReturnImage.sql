CREATE TYPE [dbo].[udt_RawDataProductReturnImage] AS TABLE (
    [StoreId]           NVARCHAR (500) NULL,
    [ProductId]         NVARCHAR (500) NULL,
    [QstIdAnsCntrlTyp]  NVARCHAR (500) NULL,
    [PhotoName]         NVARCHAR (500) NULL,
    [imagePath]         NVARCHAR (500) NULL,
    [ImageClicktime]    NVARCHAR (500) NULL,
    [ReasonForReturn]   NVARCHAR (500) NULL,
    [PhotoValidation]   NVARCHAR (500) NULL,
    [OrderIDPDA]        NVARCHAR (500) NULL,
    [TmpInvoiceCodePDA] NVARCHAR (500) NULL,
    [Sstat]             NVARCHAR (500) NULL);

