CREATE TABLE [dbo].[tblPrdStoreProductPriceMstr] (
    [StoreId]        INT              NOT NULL,
    [PrdNodeId]      INT              NOT NULL,
    [PrdNodeType]    INT              NOT NULL,
    [RLP]            NUMERIC (18, 10) NOT NULL,
    [RLP_Case]       NUMERIC (18, 10) NULL,
    [TimeStampins]   DATETIME         DEFAULT (getdate()) NOT NULL,
    [ReqCapQtyInPcs] FLOAT (53)       NULL,
    [ActCapQtyInPcs] FLOAT (53)       NULL,
    [DbNodeId]       INT              NULL,
    [DbNodeType]     INT              NULL,
    [SpecialRateId]  INT              NULL,
    [FileSetId]      BIGINT           NULL
);

