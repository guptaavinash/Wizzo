CREATE TYPE [dbo].[udt_OrderSchemeDiscount] AS TABLE (
    [SchemeSlabID]        INT            NULL,
    [PrdID]               INT            NULL,
    [SchemePrdID]         INT            NULL,
    [BenefitVal]          [dbo].[Amount] NULL,
    [SchemeBenefitTypeID] INT            NULL);

