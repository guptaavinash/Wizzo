CREATE TABLE [dbo].[tblP3MSalesDetail] (
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


GO
CREATE NONCLUSTERED INDEX [IX_tblP3MSalesDetail]
    ON [dbo].[tblP3MSalesDetail]([RETAILING] ASC, [PrdNodeId] ASC, [InvDate] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_tblP3MSalesDetail_1]
    ON [dbo].[tblP3MSalesDetail]([StoreId] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_tblP3MSalesDetail_2]
    ON [dbo].[tblP3MSalesDetail]([InvDate] DESC);

