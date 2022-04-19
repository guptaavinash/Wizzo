CREATE TABLE [dbo].[tblTeleReasonMstr] (
    [TeleReasonId]      INT           IDENTITY (1, 1) NOT NULL,
    [TeleReason]        VARCHAR (500) NULL,
    [flgConsiderO2Data] BIT           CONSTRAINT [DF_tblTeleReasonMstr_flgConsider] DEFAULT ((0)) NOT NULL,
    [flgRptFilter]      BIT           CONSTRAINT [DF_tblTeleReasonMstr_flgRptFilter] DEFAULT ((0)) NOT NULL,
    CONSTRAINT [PK_tblTeleReasonMstr] PRIMARY KEY CLUSTERED ([TeleReasonId] ASC)
);

