CREATE TABLE [dbo].[tblChannelWiseProductivityThreshold] (
    [ChnlThrsholdProdMapId] INT          IDENTITY (1, 1) NOT NULL,
    [ChannelId]             INT          NOT NULL,
    [ThresholdAmount]       NUMERIC (18) NOT NULL,
    [FromDate]              DATE         CONSTRAINT [DF_tblChannelWiseProductivityThreshold_FromDate] DEFAULT (getdate()) NOT NULL,
    [ToDate]                DATE         CONSTRAINT [DF_tblChannelWiseProductivityThreshold_ToDate] DEFAULT ('2050-12-31') NOT NULL,
    CONSTRAINT [PK_tblChannelWiseProductivityThreshold] PRIMARY KEY CLUSTERED ([ChnlThrsholdProdMapId] ASC)
);

