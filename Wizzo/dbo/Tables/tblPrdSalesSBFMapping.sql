CREATE TABLE [dbo].[tblPrdSalesSBFMapping] (
    [SalesSBFMapId] INT              IDENTITY (1, 1) NOT NULL,
    [SalesNodeid]   INT              NOT NULL,
    [SalesNodeType] INT              NOT NULL,
    [SBFNodeId]     INT              NOT NULL,
    [SBFNodeType]   INT              NOT NULL,
    [PrdNodeId]     INT              NOT NULL,
    [PrdNodeType]   INT              NOT NULL,
    [MRP]           NUMERIC (18, 2)  NOT NULL,
    [RLP]           NUMERIC (18, 10) NOT NULL,
    [PcsInBox]      INT              NOT NULL,
    [FromDate]      DATE             CONSTRAINT [DF_tblPrdSalesSBFMapping_FromDate] DEFAULT (getdate()) NOT NULL,
    [ToDate]        DATE             CONSTRAINT [DF_tblPrdSalesSBFMapping_ToDate] DEFAULT ('2050-12-31') NOT NULL,
    [FileSetIdIns]  INT              NOT NULL,
    [TimeStampIns]  DATETIME         NOT NULL,
    [FileSetIdUpd]  INT              NULL,
    [TimeStampUpd]  DATETIME         NULL,
    [flgNewStore]   BIT              DEFAULT ((0)) NOT NULL,
    [flgSearchList] BIT              DEFAULT ((0)) NOT NULL,
    CONSTRAINT [PK_tblPrdSalesSBFMapping] PRIMARY KEY CLUSTERED ([SalesSBFMapId] ASC)
);

