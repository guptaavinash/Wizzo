CREATE TABLE [dbo].[tblP3MSalesDetailn] (
    [DistNodeId]     INT             NOT NULL,
    [DistNodeType]   INT             NOT NULL,
    [DSENodeId]      INT             NULL,
    [DSENodeType]    INT             NULL,
    [StoreId]        INT             NOT NULL,
    [PrdNodeId]      INT             NOT NULL,
    [PrdNodeType]    INT             NOT NULL,
    [InvId]          INT             NULL,
    [InvNo]          VARCHAR (50)    NULL,
    [InvDate]        DATE            NOT NULL,
    [Qty]            INT             NULL,
    [NetValue]       NUMERIC (18, 6) NULL,
    [NetVolume]      NUMERIC (18, 6) NULL,
    [TaxAmt]         NUMERIC (18, 6) NULL,
    [RETAILING]      NUMERIC (18, 6) NULL,
    [mrp]            NUMERIC (18, 6) NULL,
    [flgOrderSource] TINYINT         DEFAULT ((1)) NOT NULL
);

