CREATE TABLE [dbo].[tblVanStockMaster] (
    [VanLoadUnLoadCycID] INT           IDENTITY (1, 1) NOT NULL,
    [VanID]              INT           NULL,
    [TransDate]          DATE          NULL,
    [TransTime]          TIME (7)      NULL,
    [LoginIDIns]         INT           NULL,
    [LoginIDUpd]         INT           NULL,
    [SalesAreaNodeID]    INT           NULL,
    [SalesAreaNodeType]  INT           NULL,
    [SalesManNodeId]     INT           NULL,
    [SalesManNodeType]   INT           NULL,
    [flgPhoneSync]       TINYINT       NULL,
    [StatusId]           TINYINT       CONSTRAINT [DF_tblVanStockMaster_StatusId] DEFAULT ((1)) NULL,
    [ConfirmationTime]   SMALLDATETIME NULL,
    [TransTimeupd]       TIME (7)      NULL,
    [StockLoadTime]      SMALLDATETIME NULL,
    [StockUnloadTime]    SMALLDATETIME NULL,
    [SalesNodeID]        INT           NULL,
    [SalesNodeType]      SMALLINT      NULL,
    CONSTRAINT [PK_tblVanStockMaster] PRIMARY KEY CLUSTERED ([VanLoadUnLoadCycID] ASC)
);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'1=Not Confirmed,2=Confirmed,3=Stock Requested,4=Stock Out Requested', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblVanStockMaster', @level2type = N'COLUMN', @level2name = N'StatusId';

