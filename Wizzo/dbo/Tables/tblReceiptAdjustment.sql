CREATE TABLE [dbo].[tblReceiptAdjustment] (
    [RcptId]         INT            NOT NULL,
    [RefType]        TINYINT        NOT NULL,
    [RefId]          INT            NOT NULL,
    [TotalInvamount] [dbo].[Amount] NULL,
    [AdjustedAmount] [dbo].[Amount] NULL,
    CONSTRAINT [PK_tblReceiptAdjustment] PRIMARY KEY CLUSTERED ([RcptId] ASC, [RefType] ASC, [RefId] ASC),
    CONSTRAINT [FK_tblReceiptAdjustment_tblReceiptMaster] FOREIGN KEY ([RcptId]) REFERENCES [dbo].[tblReceiptMaster] ([RcptId]) ON DELETE CASCADE ON UPDATE CASCADE
);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Invoice Id', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblReceiptAdjustment', @level2type = N'COLUMN', @level2name = N'RefId';

