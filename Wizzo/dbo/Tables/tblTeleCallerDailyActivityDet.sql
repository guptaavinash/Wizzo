CREATE TABLE [dbo].[tblTeleCallerDailyActivityDet] (
    [TCDailyActivityDetId] BIGINT   IDENTITY (1, 1) NOT NULL,
    [TCDailyId]            INT      NOT NULL,
    [StatusId]             INT      NOT NULL,
    [TimeStampIns]         DATETIME CONSTRAINT [DF_tblTeleCallerDailyActivityDet_TimeStampIns] DEFAULT (getdate()) NOT NULL,
    [BreakReasonId]        INT      NULL,
    CONSTRAINT [PK_tblTeleCallerDailyActivityDet] PRIMARY KEY CLUSTERED ([TCDailyActivityDetId] ASC)
);

