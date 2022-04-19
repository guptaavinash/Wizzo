CREATE TABLE [dbo].[tblDBRSalesStructureCoverage] (
    [NodeID]        INT           IDENTITY (1, 1) NOT NULL,
    [Descr]         VARCHAR (500) NULL,
    [NodeType]      INT           CONSTRAINT [DF_tblDBRSalesStructureCoverage_NodeType] DEFAULT ((160)) NOT NULL,
    [IsActive]      BIT           CONSTRAINT [DF_tblDBRSalesStructureCoverage_IsActive] DEFAULT ((1)) NOT NULL,
    [ACPFullName]   VARCHAR (200) NULL,
    [LoginIDIns]    INT           CONSTRAINT [DF_tblDBRSalesStructureCoverage_LoginIDIns] DEFAULT ((1)) NOT NULL,
    [TimestampIns]  DATETIME      CONSTRAINT [DF_tblDBRSalesStructureCoverage_TimestampIns] DEFAULT (getdate()) NOT NULL,
    [LoginIDUpd]    INT           NULL,
    [TimestampUpd]  DATETIME      NULL,
    [WorkingTypeId] INT           NULL,
    CONSTRAINT [PK_tblDBRSalesStructureCoverage] PRIMARY KEY CLUSTERED ([NodeID] ASC)
);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'1=Van Sale,2=Order booking', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblDBRSalesStructureCoverage', @level2type = N'COLUMN', @level2name = N'WorkingTypeId';

