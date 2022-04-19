CREATE TABLE [dbo].[tblTeleCallerCallDetail] (
    [CallId]         BIGINT       IDENTITY (1, 1) NOT NULL,
    [TeleCallingId]  INT          NULL,
    [flgOrderSource] TINYINT      NULL,
    [CallType]       TINYINT      NULL,
    [CallDateTime]   DATETIME     NULL,
    [ReasonId]       INT          NULL,
    [ScheduleCall]   VARCHAR (50) NULL
);

