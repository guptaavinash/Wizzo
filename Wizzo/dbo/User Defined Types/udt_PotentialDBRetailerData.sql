CREATE TYPE [dbo].[udt_PotentialDBRetailerData] AS TABLE (
    [NewRetailerCode] VARCHAR (100) NULL,
    [RetailerName]    VARCHAR (200) NULL,
    [RetailerAddress] VARCHAR (500) NULL,
    [Comment]         VARCHAR (500) NULL,
    [flgFeedback]     TINYINT       NULL);

