CREATE TABLE [dbo].[tblMstrPerson] (
    [NodeID]                 INT           IDENTITY (1, 1) NOT NULL,
    [Code]                   VARCHAR (50)  NOT NULL,
    [Descr]                  VARCHAR (50)  NOT NULL,
    [Designation]            VARCHAR (50)  NULL,
    [PersonEmailID]          VARCHAR (50)  NULL,
    [PersonPhone]            VARCHAR (15)  NULL,
    [NodeType]               INT           NOT NULL,
    [FromDate]               DATETIME      CONSTRAINT [DF_tblMstrPerson_FromDate] DEFAULT (getdate()) NOT NULL,
    [ToDate]                 DATETIME      CONSTRAINT [DF_tblMstrPerson_ToDate] DEFAULT ('31-dec-2099') NOT NULL,
    [FileSetIdIns]           BIGINT        NOT NULL,
    [LoginIDIns]             INT           NULL,
    [TimestampIns]           DATETIME      CONSTRAINT [DF_tblMstrPerson_TimestampIns] DEFAULT (getdate()) NOT NULL,
    [FileSetIdUpd]           BIGINT        NULL,
    [LoginIDUpd]             INT           NULL,
    [TimestampUpd]           DATETIME      NULL,
    [flgCompanyPerson]       TINYINT       CONSTRAINT [DF_tblMstrPerson_flgCompanyPerson] DEFAULT ((1)) NULL,
    [flgDeliveryBoy]         BIT           NULL,
    [flgDriver]              BIT           NULL,
    [flgRegistered]          TINYINT       CONSTRAINT [DF_tblMstrPerson_flgRegistered_1] DEFAULT ((0)) NULL,
    [DistNodeId]             INT           NULL,
    [DistNodeType]           INT           NULL,
    [flgWhatsAppReg]         TINYINT       CONSTRAINT [DF__tblMstrPe__flgWh__4050666D] DEFAULT ((0)) NOT NULL,
    [FCMTokenNo]             VARCHAR (200) NULL,
    [flgStoreValidationUser] TINYINT       NULL,
    [flgActive]              TINYINT       CONSTRAINT [DF__tblMstrPe__flgAc__70547F4A] DEFAULT ((1)) NOT NULL,
    [flgSFAUser]             TINYINT       NULL,
    CONSTRAINT [PK__tblMstrP__6BAE22431BC821DD] PRIMARY KEY CLUSTERED ([NodeID] ASC)
);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'1=Company Person,2=Distributor Person', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblMstrPerson', @level2type = N'COLUMN', @level2name = N'flgCompanyPerson';

