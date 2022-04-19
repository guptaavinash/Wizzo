CREATE TABLE [dbo].[tblTeleSuperVisorSalesHierMap] (
    [TSVSalesMapId] INT IDENTITY (1, 1) NOT NULL,
    [TSVNodeId]     INT NOT NULL,
    [TSVNodeType]   INT NOT NULL,
    [SalesNodeId]   INT NOT NULL,
    [SalesNodeType] INT NOT NULL,
    CONSTRAINT [PK_tblTeleSuperVisorSalesHierMap] PRIMARY KEY CLUSTERED ([TSVSalesMapId] ASC)
);

