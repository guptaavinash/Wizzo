CREATE TYPE [dbo].[udt_OrderSchemePrdDiscountDet] AS TABLE (
    [OrderID]       INT            NULL,
    [PrdID]         INT            NULL,
    [SchemeSlabID]  INT            NULL,
    [BenefitTypeID] INT            NULL,
    [BenefitVal]    [dbo].[Amount] NOT NULL);

