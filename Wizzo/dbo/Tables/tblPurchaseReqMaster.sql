CREATE TABLE [dbo].[tblPurchaseReqMaster] (
    [PurchReqId]      INT            IDENTITY (1, 1) NOT NULL,
    [PurchReqNo]      VARCHAR (20)   NULL,
    [PurchReqInitTag] VARCHAR (3)    NULL,
    [PurchReqSeqNo]   INT            NULL,
    [ReqDate]         DATE           NOT NULL,
    [Expectedby]      DATE           NOT NULL,
    [StatusId]        TINYINT        CONSTRAINT [DF_tblPurchaseReqMaster_StatusId] DEFAULT ((0)) NOT NULL,
    [FYID]            INT            NOT NULL,
    [SalesNodeId]     INT            NOT NULL,
    [SalesNodeType]   INT            NOT NULL,
    [LoginIDIns]      INT            CONSTRAINT [DF_tblPurchaseReqMaster_LoginIDIns] DEFAULT ((0)) NULL,
    [TimestampIns]    DATETIME       CONSTRAINT [DF_tblPurchaseReqMaster_TimestampIns] DEFAULT (getdate()) NULL,
    [LoginIDUpd]      INT            NULL,
    [TimestampUpd]    DATETIME       NULL,
    [TotOrderValue]   [dbo].[Amount] NULL,
    [TotDiscValue]    [dbo].[Amount] NULL,
    [TotOrderWDisc]   [dbo].[Amount] NULL,
    [TotTaxAmt]       [dbo].[Amount] NULL,
    [NetAmt]          [dbo].[Amount] NULL,
    [Remarks]         VARCHAR (500)  NULL,
    [ReasonForChange] VARCHAR (500)  NULL,
    [flgSAPDataSent]  BIT            DEFAULT ((0)) NOT NULL,
    [TeleCallingId]   INT            NULL,
    [PaymentStageId]  TINYINT        NULL,
    [PaymentReceived] NUMERIC (18)   NULL,
    [PaymentDetail]   VARCHAR (500)  NULL,
    [AttachDoc]       VARCHAR (500)  NULL,
    CONSTRAINT [PK_tblPurchaseReqMaster] PRIMARY KEY CLUSTERED ([PurchReqId] ASC)
);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'1:Open, 2:Closed,3:Cancel', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblPurchaseReqMaster', @level2type = N'COLUMN', @level2name = N'StatusId';

