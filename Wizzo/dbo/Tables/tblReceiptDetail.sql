CREATE TABLE [dbo].[tblReceiptDetail] (
    [RcptDetId]        INT            IDENTITY (1, 1) NOT NULL,
    [RcptId]           INT            NOT NULL,
    [AdvChqId]         INT            CONSTRAINT [DF_tblReceiptDetail_AdvChqId] DEFAULT ((0)) NOT NULL,
    [InstrumentModeId] TINYINT        NOT NULL,
    [TrnRefNo]         VARCHAR (30)   NULL,
    [TrnDate]          DATE           NULL,
    [RcptAmt]          [dbo].[Amount] CONSTRAINT [DF_tblReceiptDetail_RcptAmt] DEFAULT ((0)) NOT NULL,
    [BankId]           INT            NULL,
    [BankBranchId]     INT            NULL,
    [BankAdd]          VARCHAR (500)  NULL,
    [Remarks]          VARCHAR (500)  NULL,
    [AttachFilePath]   VARCHAR (100)  NULL,
    [flgCleared]       TINYINT        CONSTRAINT [DF_tblReceiptDetail_flgCleared] DEFAULT ((1)) NOT NULL,
    CONSTRAINT [PK_tblReceiptDetail] PRIMARY KEY CLUSTERED ([RcptDetId] ASC),
    CONSTRAINT [FK_tblReceiptDetail_tblReceiptMaster] FOREIGN KEY ([RcptId]) REFERENCES [dbo].[tblReceiptMaster] ([RcptId]) ON DELETE CASCADE ON UPDATE CASCADE
);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'0:Pending,1:Cleared,2:Bounce', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblReceiptDetail', @level2type = N'COLUMN', @level2name = N'flgCleared';

