CREATE TABLE [dbo].[tblReasonDetailForNoVisit] (
    [Id]             INT            IDENTITY (1, 1) NOT NULL,
    [PersonNodeId]   INT            NULL,
    [PersonNodeType] INT            NULL,
    [VisitDate]      DATE           NULL,
    [ReasonId]       INT            NULL,
    [ReasonText]     VARCHAR (1000) NULL,
    [TimeStampIns]   DATETIME       NULL
);

