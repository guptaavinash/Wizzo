CREATE TABLE [dbo].[tblOlapProcessingLog] (
    [id]          INT      IDENTITY (1, 1) NOT NULL,
    [WeekEnding]  DATE     NULL,
    [TimeStampIn] DATETIME CONSTRAINT [DF_tblOlapProcessingLog_TimeStampIn] DEFAULT (getdate()) NULL,
    CONSTRAINT [PK_tblOlapProcessingLog] PRIMARY KEY CLUSTERED ([id] ASC)
);

