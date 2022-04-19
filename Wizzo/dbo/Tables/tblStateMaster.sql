CREATE TABLE [dbo].[tblStateMaster] (
    [NodeID]       INT            IDENTITY (1, 1) NOT NULL,
    [NodeType]     INT            NOT NULL,
    [Descr]        NVARCHAR (100) NULL,
    [IsActive]     TINYINT        NULL,
    [LoginIDIns]   INT            NULL,
    [LoginIDUpd]   INT            NULL,
    [TimeStampIns] DATETIME       NULL,
    [TimeStampUpd] DATETIME       NULL,
    [TelCode]      VARCHAR (10)   NULL,
    [LoginID]      INT            NULL,
    [GSTDescr]     VARCHAR (200)  NULL,
    [SAPStateCode] VARCHAR (2)    NULL,
    [GSTCode]      VARCHAR (2)    NULL,
    [LanguageId]   INT            NULL
);

