CREATE TABLE [dbo].[tblVersionDownloadStatusMstrHistory] (
    [VersionID]             INT           NULL,
    [PDACode]               VARCHAR (50)  NULL,
    [VersionDownloadDate]   DATETIME      NULL,
    [VersionDownloadStatus] NCHAR (10)    NULL,
    [ApplicationType]       INT           NULL,
    [Timestamp]             SMALLDATETIME NULL,
    [IMEINo_Sec]            VARCHAR (50)  NULL
);

