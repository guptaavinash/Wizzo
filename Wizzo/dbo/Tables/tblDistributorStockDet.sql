CREATE TABLE [dbo].[tblDistributorStockDet] (
    [DistStockID]      INT           IDENTITY (1, 1) NOT NULL,
    [CustomerNodeID]   INT           NULL,
    [CustomerNodeType] SMALLINT      NULL,
    [ProductNodeID]    INT           NULL,
    [ProductNodeType]  SMALLINT      NULL,
    [StockDate]        DATE          NULL,
    [StockQty]         INT           NULL,
    [timestamp]        SMALLDATETIME CONSTRAINT [DF_tblDistributorStockDet_timestamp] DEFAULT (getdate()) NULL,
    [PersonNodeid]     INT           NULL,
    [PersonNodeType]   SMALLINT      NULL,
    [FreeQty]          INT           NULL,
    [SampleQty]        INT           NULL,
    [ExpiredQty]       INT           NULL,
    [flgpackType]      TINYINT       CONSTRAINT [DF_tblDistributorStockDet_flgpackType_1] DEFAULT ((1)) NULL,
    [UOMID]            INT           NULL,
    CONSTRAINT [PK_tblDistributorStockDet] PRIMARY KEY CLUSTERED ([DistStockID] ASC)
);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'1=Pieces,2=Cases', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblDistributorStockDet', @level2type = N'COLUMN', @level2name = N'flgpackType';

