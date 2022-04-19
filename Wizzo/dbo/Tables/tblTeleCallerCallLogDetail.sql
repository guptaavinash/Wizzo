CREATE TABLE [dbo].[tblTeleCallerCallLogDetail] (
    [CallId]           BIGINT          IDENTITY (1, 1) NOT NULL,
    [TeleCallingId]    INT             NULL,
    [flgOrderSource]   TINYINT         NULL,
    [StartTime]        DATETIME        NOT NULL,
    [EndTime]          DATETIME        NULL,
    [flgCallStatus]    TINYINT         NULL,
    [ReasonId]         INT             NULL,
    [ScheduleCall]     VARCHAR (50)    NULL,
    [LoginIdIns]       INT             NULL,
    [TimeStampIns]     DATETIME        NULL,
    [PhoneNo]          VARCHAR (100)   NULL,
    [DSEComments]      VARCHAR (500)   NULL,
    [TotalOrderValue]  NUMERIC (18, 2) NULL,
    [NoOfSKU]          INT             NULL,
    [flgCallType]      TINYINT         NULL,
    [DialingFrequency] TINYINT         NULL
);

