CREATE TABLE [dbo].[tblVersionDownload_Log] (
    [VersionID]       INT           NULL,
    [IMEINo]          VARCHAR (50)  NULL,
    [ApplicationType] INT           NULL,
    [Timestamp]       SMALLDATETIME CONSTRAINT [DF_tblVersionDownload_Log_Timestamp] DEFAULT (getdate()) NULL
);

