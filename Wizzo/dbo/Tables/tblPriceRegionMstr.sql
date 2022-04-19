CREATE TABLE [dbo].[tblPriceRegionMstr] (
    [PrcRgnNodeId]   INT           IDENTITY (1, 1) NOT NULL,
    [PrcRegion]      VARCHAR (250) NOT NULL,
    [PrcRgnNodeType] INT           CONSTRAINT [DF_tblPriceRegionMstr_PrcRgnNodeType] DEFAULT ((700)) NOT NULL,
    [TimeStampIns]   DATETIME      CONSTRAINT [DF_tblPriceRegionMstr_TimeStampIns] DEFAULT (getdate()) NOT NULL,
    [StateID]        INT           NULL,
    CONSTRAINT [PK_tblPriceRegionMstr] PRIMARY KEY CLUSTERED ([PrcRgnNodeId] ASC)
);

