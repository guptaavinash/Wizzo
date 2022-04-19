CREATE TYPE [dbo].[udt_PotentialDBRetailerData_XMLSaving] AS TABLE (
    [DBNodeID]      INT           NOT NULL,
    [DBNodeType]    INT           NOT NULL,
    [RetailerCode]  VARCHAR (100) NULL,
    [RetailerName]  VARCHAR (200) NULL,
    [Address]       VARCHAR (500) NULL,
    [Comment]       VARCHAR (500) NULL,
    [ContactNumber] VARCHAR (500) NULL,
    [RetFeedback]   TINYINT       NULL);

