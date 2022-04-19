CREATE TABLE [dbo].[tblPrdMstrSKULvl] (
    [NodeID]                INT              IDENTITY (1, 1) NOT NULL,
    [SKUCode]               VARCHAR (50)     NULL,
    [Descr]                 VARCHAR (500)    NOT NULL,
    [NodeType]              INT              CONSTRAINT [DF_tblMstrPrdSKU_NodeType] DEFAULT ((30)) NOT NULL,
    [flgDCode]              TINYINT          NULL,
    [LoginIDIns]            INT              CONSTRAINT [DF_tblPrdMstrSKULvl_LoginIDIns] DEFAULT ((1)) NOT NULL,
    [TimestampIns]          DATETIME         CONSTRAINT [DF_tblPrdMstrSKULvl_TimestampIns] DEFAULT (getdate()) NOT NULL,
    [LoginIDUpd]            INT              NULL,
    [TimestampUpd]          DATETIME         NULL,
    [CostToRetailer]        DECIMAL (18, 2)  NULL,
    [IsActive]              TINYINT          CONSTRAINT [DF__tblMstrPr__IsAct__3B2BBE9D] DEFAULT ((1)) NOT NULL,
    [ShortDescr]            VARCHAR (200)    NULL,
    [UOMValue]              INT              NULL,
    [UOMType]               VARCHAR (50)     NULL,
    [IsCombiPack]           TINYINT          NULL,
    [UOMID]                 INT              NULL,
    [MRP]                   DECIMAL (18, 2)  NULL,
    [Tax]                   DECIMAL (18, 2)  NOT NULL,
    [BrandID]               INT              NOT NULL,
    [ManufacturerID]        INT              NOT NULL,
    [PrdClassificationID]   INT              NULL,
    [Grammage]              DECIMAL (18, 3)  NULL,
    [RetMarginPer]          DECIMAL (18, 2)  CONSTRAINT [DF_tblPrdMstrSKULvl_RetMarginPer] DEFAULT ((0)) NOT NULL,
    [RetVatAmount]          DECIMAL (18, 2)  NULL,
    [StandardRate]          DECIMAL (18, 10) NULL,
    [StandardRateBeforeTax] DECIMAL (18, 10) NULL,
    [StandardTax]           AS               ([standardrate]-[standardratebeforetax]),
    [ProductSeq]            INT              NULL,
    [flgSeq]                INT              CONSTRAINT [DF_tblPrdMstrSKULvl_flgSeq] DEFAULT ((0)) NOT NULL,
    [DistMarginPer]         DECIMAL (18, 2)  CONSTRAINT [DF__tblPrdMst__DistM__5DF5D7ED] DEFAULT ((0)) NOT NULL,
    [StandardRateForDist]   DECIMAL (18, 2)  NULL,
    [SSMarginPer]           DECIMAL (18, 2)  NULL,
    [StandardRateForSS]     DECIMAL (18, 2)  NULL,
    [PcsInBox]              INT              NULL,
    [WarehouseId]           INT              NULL,
    [PrdGroupID]            INT              NULL,
    [SupplierID]            INT              NULL,
    [PriceTypeId]           TINYINT          CONSTRAINT [DF_tblPrdMstrSKULvl_PriceTypeId] DEFAULT ((1)) NOT NULL,
    [PriceValue]            NUMERIC (18, 2)  NULL,
    [SUBDMarginPer]         DECIMAL (18, 2)  NULL,
    [ApplicableFor]         VARCHAR (20)     NULL,
    [HSNCode]               VARCHAR (50)     NULL,
    [flgPriceAva]           TINYINT          CONSTRAINT [DF_tblPrdMstrSKULvl_flgPriceAva_1] DEFAULT ((1)) NOT NULL,
    [BusinessUnitId]        INT              NULL,
    [IsSample]              TINYINT          NULL,
    [IsTrial]               TINYINT          NULL,
    [WeightCategoryID]      INT              NULL,
    [Grammage_Act]          NUMERIC (18, 2)  NULL,
    [VariantId]             INT              NULL,
    [ConsumerOfferId]       INT              NULL,
    [CropId]                INT              NULL,
    [PrdTypeId]             INT              NULL,
    [PrdBrandId]            INT              NULL,
    [PrdWeightCategoryId]   INT              NULL,
    [ConsumerPackId]        INT              NULL,
    [PhotoName]             VARCHAR (100)    NULL,
    [flgFBPrd]              TINYINT          NULL,
    [OldSKUCode]            VARCHAR (50)     NULL,
    [OldSKUName]            VARCHAR (250)    NULL,
    [SapPrdTypeId]          INT              NULL,
    [SapPrdBrandId]         INT              NULL,
    [SapPrdStageId]         INT              NULL,
    [SapPrdRBPSgmntId]      INT              NULL,
    [SapPrdSubSgmntId]      INT              NULL,
    [SapPrdSubBrndId]       INT              NULL,
    [SapPrdPckTypeId]       INT              NULL,
    [SapPrdStndPckSzeId]    INT              NULL,
    [SapPrdPckSzeId]        INT              NULL,
    [SapPrdNewCrpId]        INT              NULL,
    [SapPrdPromoId]         INT              NULL,
    [flgSaleType]           TINYINT          CONSTRAINT [DF__tblPrdMst__flgSa__454A25B4] DEFAULT ((1)) NOT NULL,
    [SectorId]              TINYINT          CONSTRAINT [DF__tblPrdMst__Secto__463E49ED] DEFAULT ((1)) NOT NULL,
    CONSTRAINT [PK__tblMstrP__6BAE22430E6E26BF] PRIMARY KEY CLUSTERED ([NodeID] ASC)
);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Franchisee Margin Per', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblPrdMstrSKULvl', @level2type = N'COLUMN', @level2name = N'DistMarginPer';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'1:From MRP,2:From Franchisee Landed Price,3:From RLP', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblPrdMstrSKULvl', @level2type = N'COLUMN', @level2name = N'PriceTypeId';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Business Segment ID with Comma Seperator', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblPrdMstrSKULvl', @level2type = N'COLUMN', @level2name = N'ApplicableFor';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'0=Price is not available,1=Price available', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblPrdMstrSKULvl', @level2type = N'COLUMN', @level2name = N'flgPriceAva';

