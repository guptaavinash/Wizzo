CREATE TYPE [dbo].[udt_OrderSchemeDet] AS TABLE (
    [SchemeSlabID]        INT            NULL,
    [PrdID]               INT            NULL,
    [FreePrdID]           INT            NULL,
    [Qty]                 INT            NULL,
    [Discount]            [dbo].[Amount] NOT NULL,
    [CouponCodeId]        INT            NULL,
    [SchemeBenefitTypeID] INT            NULL);

