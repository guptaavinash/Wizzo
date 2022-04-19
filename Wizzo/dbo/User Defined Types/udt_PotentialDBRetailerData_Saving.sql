CREATE TYPE [dbo].[udt_PotentialDBRetailerData_Saving] AS TABLE (
    [RetailerCode]  VARCHAR (100) NULL,
    [RetailerName]  VARCHAR (200) NULL,
    [Address]       VARCHAR (500) NULL,
    [Comment]       VARCHAR (500) NULL,
    [ContactNumber] VARCHAR (500) NULL,
    [RetFeedback]   TINYINT       NULL);

