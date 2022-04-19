﻿CREATE TABLE [dbo].[tblTCOrderMaster] (
    [OrderID]                 INT             IDENTITY (1, 1) NOT NULL,
    [OrderCode]               VARCHAR (50)    NULL,
    [VisitID]                 INT             NULL,
    [OrderDate]               DATE            NOT NULL,
    [SalesPersonID]           INT             NOT NULL,
    [SalesPersonType]         TINYINT         NOT NULL,
    [RouteNodeId]             INT             NULL,
    [RouteNodeType]           INT             NULL,
    [StoreID]                 INT             NOT NULL,
    [TotalDeliveryBy]         DATE            CONSTRAINT [DF__tblOrderM__Total__190BB0C3] DEFAULT (getdate()) NULL,
    [Remarks]                 VARCHAR (100)   NULL,
    [TotLineOrderVal]         NUMERIC (18, 2) NULL,
    [TotLineLevelDisc]        NUMERIC (18, 2) NULL,
    [TotOrderVal]             NUMERIC (18, 2) NOT NULL,
    [TotDiscVal]              NUMERIC (18, 2) NULL,
    [TotOrderValWDisc]        NUMERIC (18, 2) NULL,
    [TotTaxVal]               NUMERIC (18, 2) NULL,
    [NetOrderValue]           NUMERIC (18, 2) NOT NULL,
    [CustomerPONo]            VARCHAR (30)    NULL,
    [CustomerPODate]          DATE            NULL,
    [flgInvoiceOnDelivery]    TINYINT         NOT NULL,
    [flgCollectionOnDelivery] TINYINT         NOT NULL,
    [FreightRuleID]           TINYINT         NOT NULL,
    [CollectionRuleID]        TINYINT         NOT NULL,
    [DlvryRuleID]             TINYINT         NULL,
    [InvRuleID]               TINYINT         NULL,
    [InsRuleID]               TINYINT         NULL,
    [TaxRuleID]               TINYINT         NULL,
    [OrderStatusID]           TINYINT         NULL,
    [OrderSourceID]           TINYINT         NOT NULL,
    [flgOrderClosed]          TINYINT         CONSTRAINT [DF_tblOrderMaster_flgOrderClosed] DEFAULT ((0)) NOT NULL,
    [LoginIDIns]              INT             CONSTRAINT [DF__tblOrderM__Login__1AF3F935] DEFAULT ((0)) NULL,
    [TimestampIns]            DATETIME        CONSTRAINT [DF__tblOrderM__Times__1BE81D6E] DEFAULT (getdate()) NULL,
    [LoginIDUpd]              INT             NULL,
    [TimestampUpd]            DATETIME        NULL,
    [FYID]                    INT             NULL,
    [OrderConfirmationDate]   SMALLDATETIME   NULL,
    [OrderCompletionDate]     SMALLDATETIME   NULL,
    [strSchemeBenefit]        VARCHAR (MAX)   NULL,
    [OrderInitTag]            VARCHAR (3)     NULL,
    [OrderSeqNo]              INT             NULL,
    [SalesNodeId]             INT             NULL,
    [SalesNodeType]           INT             NULL,
    [ActAddDisc]              NUMERIC (18, 2) NULL,
    [OrderLogId]              INT             NULL,
    [flgOffline]              TINYINT         NULL,
    [OrdPrcsId]               TINYINT         CONSTRAINT [DF__tblOrderM__OrdPr__2A6B46EF] DEFAULT ((0)) NOT NULL,
    [flgInvoicePrinted]       TINYINT         CONSTRAINT [DF__tblOrderM__flgIn__2B5F6B28] DEFAULT ((0)) NOT NULL,
    [ReasonId]                INT             CONSTRAINT [DF__tblOrderM__Reaso__2C538F61] DEFAULT ((0)) NOT NULL,
    [ReasonText]              VARCHAR (500)   NULL,
    [OrderPDAID]              VARCHAR (100)   NULL,
    [TotOtherCharges]         NUMERIC (18, 2) CONSTRAINT [DF__tblOrderM__TotOt__2D47B39A] DEFAULT ((0)) NOT NULL,
    [TeleCallingId]           INT             NULL,
    [DistNodeId]              INT             NOT NULL,
    [DistNodeType]            INT             NOT NULL,
    [CycleId]                 INT             NOT NULL,
    [flgSent]                 INT             CONSTRAINT [DF_tblOrderMaster_flgSent] DEFAULT ((0)) NOT NULL,
    [flgOrderSource]          TINYINT         NULL,
    [TotMRPValue]             NUMERIC (18, 2) NULL,
    [GPValue]                 SMALLINT        CONSTRAINT [DF__tblOrderM__GPVal__56B3DD81] DEFAULT ((0)) NOT NULL,
    [FocBndAlrAch]            TINYINT         CONSTRAINT [DF__tblOrderM__FocBn__57A801BA] DEFAULT ((0)) NOT NULL,
    [FocBndNowAch]            TINYINT         CONSTRAINT [DF__tblOrderM__FocBn__589C25F3] DEFAULT ((0)) NOT NULL,
    [FocBndSBFOrd]            INT             CONSTRAINT [DF__tblOrderM__FocBn__59904A2C] DEFAULT ((0)) NOT NULL,
    [FocBndSBFQtyOrd]         INT             CONSTRAINT [DF__tblOrderM__FocBn__5A846E65] DEFAULT ((0)) NOT NULL,
    [FocBndSBFValueOrd]       NUMERIC (18, 2) CONSTRAINT [DF__tblOrderM__FocBn__5B78929E] DEFAULT ((0)) NOT NULL,
    [SBDSBFOrd]               INT             CONSTRAINT [DF__tblOrderM__SBDSB__5C6CB6D7] DEFAULT ((0)) NOT NULL,
    [SBDTotalGap]             INT             CONSTRAINT [DF__tblOrderM__SBDTo__5D60DB10] DEFAULT ((0)) NOT NULL,
    [GPValueSupplied]         SMALLINT        NULL,
    CONSTRAINT [PK__tblOrder__C3905BAF17236851] PRIMARY KEY CLUSTERED ([OrderID] ASC)
);


GO
CREATE NONCLUSTERED INDEX [IX_tblTCOrderMaster]
    ON [dbo].[tblTCOrderMaster]([OrderID] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_tblTCOrderMaster_1]
    ON [dbo].[tblTCOrderMaster]([flgOrderSource] ASC, [TeleCallingId] DESC);

