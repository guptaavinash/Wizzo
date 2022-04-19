CREATE TABLE [dbo].[tblRptDistributionDataForBeat] (
    [AreaNodeId]         INT           NULL,
    [AreaNodeType]       INT           NULL,
    [PrdNodeId]          INT           NULL,
    [PrdNodeType]        INT           NULL,
    [DataLvl]            VARCHAR (200) NULL,
    [LastYearProdStores] INT           NULL,
    [YTD_Distribution]   INT           NULL,
    [YTD_NewlyAdded]     INT           NULL,
    [MTD_Distribution]   INT           NULL,
    [MTD_NewlyAdded]     INT           NULL,
    [RptMonthYear]       INT           NULL,
    [TimeStampIns]       DATETIME      CONSTRAINT [DF_tblRptDistributionDataForBeat_TimeStampIns] DEFAULT (getdate()) NULL,
    [Ordr]               INT           NULL
);

