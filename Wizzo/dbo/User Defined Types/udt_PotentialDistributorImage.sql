CREATE TYPE [dbo].[udt_PotentialDistributorImage] AS TABLE (
    [NodeID]    INT          NOT NULL,
    [NodeType]  INT          NOT NULL,
    [ImageType] TINYINT      NULL,
    [ImageName] VARCHAR (20) NULL);

