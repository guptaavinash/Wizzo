CREATE TABLE [dbo].[tblManagerDetailsForIndVisit] (
    [Id]                  INT           IDENTITY (1, 1) NOT NULL,
    [DeviceId]            INT           NULL,
    [VisitDate]           DATE          NULL,
    [SalesPersonNodeId]   INT           NULL,
    [SalesPersonNodeType] INT           NULL,
    [ManagerNodeId]       INT           NULL,
    [ManagerNodeType]     INT           NULL,
    [ManagerName]         VARCHAR (200) NULL,
    [TimeStampIn]         DATETIME      NULL,
    [TimeStampUpd]        DATETIME      NULL,
    CONSTRAINT [PK_tblManagerDetailsForIndVisit] PRIMARY KEY CLUSTERED ([Id] ASC)
);

