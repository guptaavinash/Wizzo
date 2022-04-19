CREATE TYPE [dbo].[udt_OrderScheme] AS TABLE (
    [PrdID]                   INT             NULL,
    [SchemeSlabID]            INT             NULL,
    [SchemeSlabSubBucketType] INT             NULL,
    [BenefitSubBucketType]    INT             NULL,
    [FreePrdID]               INT             NULL,
    [BenefitSubBucketVal]     NUMERIC (18, 4) NOT NULL,
    [BenefitAssignedVal]      NUMERIC (18, 4) NOT NULL,
    [BenefitDiscountApp]      NUMERIC (18, 4) NOT NULL,
    [BenefitCouponCode]       VARCHAR (20)    NULL,
    [flgDiscOnTotAmt]         TINYINT         NOT NULL,
    [IsApply]                 TINYINT         NOT NULL);

