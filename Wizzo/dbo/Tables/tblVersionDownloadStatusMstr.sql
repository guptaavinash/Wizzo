CREATE TABLE [dbo].[tblVersionDownloadStatusMstr] (
    [VersionID]             INT           NULL,
    [PDACode]               VARCHAR (50)  NULL,
    [VersionDownloadDate]   DATETIME      NULL,
    [VersionDownloadStatus] TINYINT       NULL,
    [ApplicationType]       INT           NULL,
    [Timestamp]             SMALLDATETIME NULL,
    [IMEINo_Sec]            VARCHAR (50)  NULL
);

