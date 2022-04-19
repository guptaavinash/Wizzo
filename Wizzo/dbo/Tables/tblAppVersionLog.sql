CREATE TABLE [dbo].[tblAppVersionLog] (
    [AppVersionLogID] INT          IDENTITY (1, 1) NOT NULL,
    [PDACode]         VARCHAR (50) NOT NULL,
    [AppVersionID]    INT          NOT NULL,
    [Date]            DATETIME     NOT NULL
);

