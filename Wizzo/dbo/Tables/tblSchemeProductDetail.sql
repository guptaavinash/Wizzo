CREATE TABLE [dbo].[tblSchemeProductDetail] (
    [SchemeId]    INT             NOT NULL,
    [PrdNodeId]   INT             NOT NULL,
    [PrdNodeType] INT             NOT NULL,
    [MRP]         NUMERIC (18, 6) NOT NULL,
    [FileSetId]   BIGINT          NULL
);

