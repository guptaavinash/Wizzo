CREATE TABLE [dbo].[tblSalesHierChannelMapping] (
    [SalesStructureNodID]   INT      NULL,
    [SalesStructureNodType] INT      NULL,
    [ChannelID]             INT      NULL,
    [FromDate]              DATE     CONSTRAINT [DF_tblSalesHierChannelMapping_FromDate] DEFAULT (getdate()) NULL,
    [ToDate]                DATE     CONSTRAINT [DF_tblSalesHierChannelMapping_ToDate] DEFAULT ('31-dec-2049') NULL,
    [LoginIDIns]            INT      NULL,
    [TimestampIns]          DATETIME CONSTRAINT [DF_tblSalesHierChannelMapping_TimestampIns] DEFAULT (getdate()) NULL,
    [LoginIDUpd]            INT      NULL,
    [TimestampUpd]          DATETIME NULL
);

