CREATE TABLE [dbo].[tblCompanySalesStructureCoverage] (
    [NodeID]        INT           IDENTITY (1, 1) NOT NULL,
    [Descr]         VARCHAR (100) NULL,
    [NodeType]      INT           CONSTRAINT [DF_tblCompanySalesStructureCoverage_NodeType] DEFAULT ((130)) NOT NULL,
    [IsActive]      BIT           CONSTRAINT [DF_tblCompanySalesStructureCoverage_IsActive] DEFAULT ((1)) NOT NULL,
    [SOERPID]       VARCHAR (50)  NULL,
    [ACPFullName]   VARCHAR (200) NULL,
    [LoginIDIns]    INT           CONSTRAINT [DF_tblCompanySalesStructureCoverage_LoginIDIns] DEFAULT ((1)) NOT NULL,
    [TimestampIns]  DATETIME      CONSTRAINT [DF_tblCompanySalesStructureCoverage_TimestampIns] DEFAULT (getdate()) NOT NULL,
    [LoginIDUpd]    INT           NULL,
    [TimestampUpd]  DATETIME      NULL,
    [WorkingTypeId] TINYINT       NULL,
    CONSTRAINT [PK_tblCompanySalesStructureCoverage] PRIMARY KEY CLUSTERED ([NodeID] ASC),
    CONSTRAINT [IX_tblCompanySalesStructureCoverage] UNIQUE NONCLUSTERED ([Descr] ASC, [SOERPID] ASC)
);

