CREATE TABLE [dbo].[tblCFRReasonCodeMstr] (
    [ReasonCodeID]        INT            NOT NULL,
    [REASNCODE_LVL1NAME]  NVARCHAR (100) NOT NULL,
    [REASNCODE_LVL2NAME]  NVARCHAR (100) NOT NULL,
    [REASNFOR]            TINYINT        CONSTRAINT [DF_tblCFRReasonCodeMstr_REASNFOR1] DEFAULT ((0)) NULL,
    [TIMESTAMP]           DATETIME       CONSTRAINT [DF_tblCFRReasonCodeMstr_TIMESTAMP1] DEFAULT (getdate()) NOT NULL,
    [flgBilledQtyReject]  BIT            DEFAULT ((0)) NOT NULL,
    [flgReturnsReject]    BIT            DEFAULT ((0)) NOT NULL,
    [flgPickupReject]     BIT            DEFAULT ((0)) NOT NULL,
    [flgFullOrder]        BIT            DEFAULT ((0)) NOT NULL,
    [flgIndividualItem]   BIT            DEFAULT ((0)) NOT NULL,
    [flgOtherTransaction] BIT            DEFAULT ((0)) NOT NULL,
    [flgOrderCancel]      BIT            NULL,
    CONSTRAINT [PK_tblCFRReasonCodeMstr1] PRIMARY KEY CLUSTERED ([ReasonCodeID] ASC)
);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'1: Order Confirmation,0: EveryWhere,2:During Pick List,3:During delivery of stock to customer', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblCFRReasonCodeMstr', @level2type = N'COLUMN', @level2name = N'REASNFOR';

