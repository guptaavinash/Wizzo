CREATE TABLE [dbo].[tblVanMstr] (
    [NodeID]        INT           IDENTITY (1, 1) NOT NULL,
    [VanRegNumber]  VARCHAR (100) NULL,
    [Descr]         VARCHAR (100) NULL,
    [NodeType]      INT           CONSTRAINT [DF_tblVanMstr_NodeType] DEFAULT ((260)) NOT NULL,
    [IsActive]      BIT           CONSTRAINT [DF_tblVanMstr_IsActive] DEFAULT ((1)) NOT NULL,
    [VanUniqueID]   VARCHAR (10)  NOT NULL,
    [TimestampIns]  SMALLDATETIME CONSTRAINT [DF_tblVanMstr_TimestampIns] DEFAULT (getdate()) NULL,
    [TimestampUpd]  SMALLDATETIME NULL,
    [LoginIDIns]    INT           NULL,
    [LoginIDupd]    INT           NULL,
    [SalesNodeID]   INT           NULL,
    [SalesNodeType] SMALLINT      NULL,
    CONSTRAINT [PK_tblVanMstr] PRIMARY KEY CLUSTERED ([NodeID] ASC)
);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'1: For Remap; 0: To not', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblVanMstr';

