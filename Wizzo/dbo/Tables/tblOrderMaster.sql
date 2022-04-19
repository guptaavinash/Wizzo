CREATE TABLE [dbo].[tblOrderMaster] (
    [OrderID]                 INT            IDENTITY (1, 1) NOT NULL,
    [OrderCode]               VARCHAR (30)   NULL,
    [VisitID]                 INT            NOT NULL,
    [OrderDate]               DATE           NOT NULL,
    [SalesPersonID]           INT            NOT NULL,
    [SalesPersonType]         TINYINT        NOT NULL,
    [RouteNodeId]             INT            NULL,
    [RouteNodeType]           INT            NULL,
    [StoreID]                 INT            NOT NULL,
    [TotalDeliveryBy]         DATE           NULL,
    [Remarks]                 VARCHAR (100)  NULL,
    [TotLineOrderVal]         [dbo].[Amount] NULL,
    [TotLineLevelDisc]        [dbo].[Amount] NULL,
    [TotOrderVal]             [dbo].[Amount] NOT NULL,
    [TotDiscVal]              [dbo].[Amount] NULL,
    [TotOrderValWDisc]        [dbo].[Amount] NULL,
    [TotTaxVal]               [dbo].[Amount] NULL,
    [NetOrderValue]           [dbo].[Amount] NOT NULL,
    [CustomerPONo]            VARCHAR (30)   NULL,
    [CustomerPODate]          DATE           NULL,
    [flgInvoiceOnDelivery]    TINYINT        NOT NULL,
    [flgCollectionOnDelivery] TINYINT        NOT NULL,
    [FreightRuleID]           TINYINT        NOT NULL,
    [CollectionRuleID]        TINYINT        NOT NULL,
    [DlvryRuleID]             TINYINT        NULL,
    [InvRuleID]               TINYINT        NULL,
    [InsRuleID]               TINYINT        NULL,
    [TaxRuleID]               TINYINT        NULL,
    [OrderStatusID]           TINYINT        NULL,
    [OrderSourceID]           TINYINT        NOT NULL,
    [flgOrderClosed]          TINYINT        NOT NULL,
    [LoginIDIns]              INT            CONSTRAINT [DF__tblOrderM__Login] DEFAULT ((0)) NULL,
    [TimestampIns]            DATETIME       CONSTRAINT [DF__tblOrderM__Times] DEFAULT (getdate()) NULL,
    [LoginIDUpd]              INT            NULL,
    [TimestampUpd]            DATETIME       NULL,
    [FYID]                    INT            NULL,
    [OrderConfirmationDate]   SMALLDATETIME  NULL,
    [OrderCompletionDate]     SMALLDATETIME  NULL,
    [strSchemeBenefit]        VARCHAR (MAX)  NULL,
    [OrderInitTag]            VARCHAR (3)    NULL,
    [OrderSeqNo]              INT            NULL,
    [SalesNodeId]             INT            NULL,
    [SalesNodeType]           INT            NULL,
    [ActAddDisc]              [dbo].[Amount] NULL,
    [OrderLogId]              INT            NULL,
    [flgOffline]              TINYINT        NULL,
    [OrdPrcsId]               TINYINT        CONSTRAINT [DF__tblOrderM__OrdPr__381A47C8] DEFAULT ((0)) NOT NULL,
    [flgInvoicePrinted]       TINYINT        CONSTRAINT [DF__tblOrderM__flgIn__390E6C01] DEFAULT ((0)) NOT NULL,
    [ReasonId]                INT            CONSTRAINT [DF__tblOrderM__Reaso__3A02903A] DEFAULT ((0)) NOT NULL,
    [ReasonText]              VARCHAR (500)  NULL,
    [OrderPDAID]              VARCHAR (100)  NULL,
    [TotOtherCharges]         [dbo].[Amount] CONSTRAINT [DF__tblOrderM__TotOt__3AF6B473] DEFAULT ((0)) NOT NULL,
    [EntryPersonNodeId]       INT            NULL,
    [EntryPersonNodetype]     SMALLINT       NULL,
    [VanDocNumber]            VARCHAR (20)   NULL,
    [VanDocType]              VARCHAR (5)    NULL,
    [VanLoadUnLoadCycID]      INT            NULL,
    [VanNodeID]               INT            NULL,
    [VanNodeType]             SMALLINT       NULL,
    [VisitDetID]              INT            NULL,
    [CancelRemarks]           VARCHAR (200)  NULL,
    [CancelReasonID]          INT            NULL,
    [EnteredInvNumber]        VARCHAR (200)  NULL,
    [EnteredInvDate]          DATE           NULL,
    [flgTeleOrder]            TINYINT        CONSTRAINT [DF_tblOrderMaster_flgTeleOrder] DEFAULT ((0)) NULL,
    [TelecallID]              INT            NULL,
    [SourceId]                INT            CONSTRAINT [DF__tblOrderM__Sourc__480696CE] DEFAULT ((2)) NOT NULL,
    [FileSetID]               INT            NULL,
    CONSTRAINT [PK__tblOrder] PRIMARY KEY CLUSTERED ([OrderID] ASC)
);


GO
CREATE NONCLUSTERED INDEX [IX_tblOrderMaster]
    ON [dbo].[tblOrderMaster]([OrderDate] DESC);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'0=No,1=Yes', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblOrderMaster', @level2type = N'COLUMN', @level2name = N'flgInvoiceOnDelivery';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'0=No,1=Yes', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblOrderMaster', @level2type = N'COLUMN', @level2name = N'flgCollectionOnDelivery';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'0=Insurance not included,1=Insurance included', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblOrderMaster', @level2type = N'COLUMN', @level2name = N'InsRuleID';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'0=Open,1=Completed,2=Cancelled', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblOrderMaster', @level2type = N'COLUMN', @level2name = N'flgOrderClosed';

