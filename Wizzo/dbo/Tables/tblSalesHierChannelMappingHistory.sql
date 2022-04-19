CREATE TABLE [dbo].[tblSalesHierChannelMappingHistory] (
    [SalesStructureNodID]   INT      NULL,
    [SalesStructureNodType] INT      NULL,
    [ChannelID]             INT      NULL,
    [FromDate]              DATE     NULL,
    [ToDate]                DATE     NULL,
    [LoginIDIns]            INT      NULL,
    [TimestampIns]          DATETIME NULL,
    [LoginIDUpd]            INT      NULL,
    [TimestampUpd]          DATETIME NULL,
    [DateMoved]             DATETIME NULL
);

