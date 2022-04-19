CREATE TABLE [dbo].[tblLocLvl3] (
    [NodeID]       INT            NOT NULL,
    [NodeType]     INT            NOT NULL,
    [Descr]        NVARCHAR (100) NULL,
    [IsActive]     TINYINT        NULL,
    [LoginIDIns]   INT            NULL,
    [LoginIDUpd]   INT            NULL,
    [TimeStampIns] DATETIME       NULL,
    [TimeStampUpd] DATETIME       NULL,
    [TelCode]      VARCHAR (10)   NULL,
    [LoginID]      INT            NULL
);

