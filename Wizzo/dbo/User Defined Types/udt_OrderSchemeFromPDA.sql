CREATE TYPE [dbo].[udt_OrderSchemeFromPDA] AS TABLE (
    [StoreID]                  INT            NULL,
    [PrdID]                    INT            NULL,
    [SchemeSlabID]             INT            NULL,
    [SchemeSlabBuckID]         INT            NULL,
    [SchemeSalbSubBucketValue] [dbo].[Amount] NOT NULL,
    [SchemeSubBucketValType]   INT            NULL,
    [SchemeSlabSubBucketType]  INT            NULL,
    [BenefitRowID]             INT            NULL,
    [BenefitSubBucketType]     INT            NULL,
    [FreePrdID]                INT            NULL,
    [BenefitSubBucketVal]      [dbo].[Amount] NOT NULL,
    [BenefitMaxVal]            [dbo].[Amount] NOT NULL,
    [BenefitAssignedVal]       [dbo].[Amount] NOT NULL,
    [BenefitAssignedValType]   INT            NULL,
    [BenefitDiscountApp]       [dbo].[Amount] NOT NULL,
    [BenefitCouponCode]        VARCHAR (20)   NULL);

