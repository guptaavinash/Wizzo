CREATE TABLE [dbo].[tblTeleCallerDeviceCallLogDetail] (
    [TeleCallDeviceLogId] INT           IDENTITY (1, 1) NOT NULL,
    [TeleCallingId]       INT           NULL,
    [StoreId]             INT           NULL,
    [PhoneNumber]         VARCHAR (100) NULL,
    [PartyName]           VARCHAR (200) NULL,
    [CallDuration]        INT           NULL,
    [CallTypeId]          SMALLINT      NULL,
    [CallTypeDescr]       VARCHAR (500) NULL,
    [CallStartDateTime]   DATETIME      NULL,
    [CallEndDateTime]     DATETIME      NULL,
    [SimSlot]             VARCHAR (50)  NULL,
    [SimDefaultNumber]    VARCHAR (50)  NULL,
    [CarrierName]         VARCHAR (50)  NULL,
    [PDACode]             VARCHAR (50)  NULL,
    [Sstat]               VARCHAR (50)  NULL,
    [DialingFrequency]    TINYINT       NULL,
    [RecordedFileName]    VARCHAR (100) NULL,
    CONSTRAINT [PK_tblTeleCallerDeviceCallLogDetail] PRIMARY KEY CLUSTERED ([TeleCallDeviceLogId] ASC)
);

