CREATE TABLE [dbo].[tblSchemeCouponMaster] (
    [CouponID]          INT           IDENTITY (1, 1) NOT NULL,
    [SchemeCouponCode]  VARCHAR (50)  NOT NULL,
    [SchemeCouponDescr] VARCHAR (200) NULL,
    CONSTRAINT [PK_tblSchemeCouponMaster] PRIMARY KEY CLUSTERED ([CouponID] ASC)
);

