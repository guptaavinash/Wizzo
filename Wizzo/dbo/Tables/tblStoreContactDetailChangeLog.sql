CREATE TABLE [dbo].[tblStoreContactDetailChangeLog] (
    [RtrCntcChngLogId]  INT          IDENTITY (1, 1) NOT NULL,
    [StoreId]           INT          NOT NULL,
    [OldContactNo]      VARCHAR (50) NOT NULL,
    [NewContactNo]      VARCHAR (50) NOT NULL,
    [OldIsCorrectNoflg] TINYINT      NOT NULL,
    [TimeStampIns]      DATETIME     CONSTRAINT [DF_tblStoreContactDetailChangeLog_TimeStampIns] DEFAULT ([dbo].[fnGetCurrentDateTime]()) NOT NULL,
    CONSTRAINT [PK_tblStoreContactDetailChangeLog] PRIMARY KEY CLUSTERED ([RtrCntcChngLogId] ASC)
);

