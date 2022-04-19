CREATE TABLE [dbo].[tblFAOrderDetail] (
    [FAOrdDetId]    INT             IDENTITY (1, 1) NOT NULL,
    [FAOrdId]       INT             NOT NULL,
    [PrdId]         INT             NOT NULL,
    [Qty]           INT             NOT NULL,
    [Rate]          NUMERIC (18, 2) NOT NULL,
    [NetOrderValue] NUMERIC (18, 2) NOT NULL,
    CONSTRAINT [PK_tblFAOrderDetail] PRIMARY KEY CLUSTERED ([FAOrdDetId] ASC)
);

