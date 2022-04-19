CREATE TABLE [dbo].[tblPrdDistributorProductPriceMstr] (
    [DistNodeId]    INT              NOT NULL,
    [DistNodeType]  INT              NOT NULL,
    [PrdNodeId]     INT              NOT NULL,
    [PrdNodeType]   INT              NOT NULL,
    [MRP]           NUMERIC (18, 2)  NOT NULL,
    [RLP]           NUMERIC (18, 10) NOT NULL,
    [PcsInBox]      INT              NOT NULL,
    [flgNewStore]   BIT              DEFAULT ((1)) NOT NULL,
    [flgSearchList] BIT              DEFAULT ((1)) NOT NULL,
    [Volume]        NUMERIC (18, 6)  NULL,
    [VolUomId]      TINYINT          NULL
);

