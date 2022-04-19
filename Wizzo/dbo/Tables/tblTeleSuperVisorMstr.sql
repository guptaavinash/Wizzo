CREATE TABLE [dbo].[tblTeleSuperVisorMstr] (
    [NodeId]       INT          IDENTITY (1, 1) NOT NULL,
    [NodeType]     INT          CONSTRAINT [DF_tblTeleSuperVisorMstr_NodeType] DEFAULT ((210)) NOT NULL,
    [SprVsrCode]   VARCHAR (50) NOT NULL,
    [flgActive]    TINYINT      CONSTRAINT [DF_tblTeleSuperVisorMstr_flgActive] DEFAULT ((1)) NOT NULL,
    [LoginIdIns]   INT          CONSTRAINT [DF_tblTeleSuperVisorMstr_LoginIdIns] DEFAULT ((0)) NOT NULL,
    [TimeStampIns] DATETIME     CONSTRAINT [DF_tblTeleSuperVisorMstr_TimeStampIns] DEFAULT (getdate()) NOT NULL,
    [LoginIdUpd]   INT          NULL,
    [TimeStampUpd] DATETIME     NULL,
    CONSTRAINT [PK_tblTeleSuperVisorMstr] PRIMARY KEY CLUSTERED ([NodeId] ASC)
);

