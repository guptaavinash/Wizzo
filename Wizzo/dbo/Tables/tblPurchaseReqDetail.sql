﻿CREATE TABLE [dbo].[tblPurchaseReqDetail] (
    [PurchReqDetId]        INT              IDENTITY (1, 1) NOT NULL,
    [PurchReqId]           INT              NOT NULL,
    [PrdId]                INT              NULL,
    [UOMID]                INT              NULL,
    [Qty]                  INT              NULL,
    [FreeQty]              INT              NULL,
    [Rate]                 DECIMAL (18, 10) NULL,
    [LineOrderVal]         [dbo].[Amount]   NULL,
    [DiscPer]              [dbo].[Amount]   NULL,
    [DiscAmt]              [dbo].[Amount]   NULL,
    [LineOrderValWDisc]    [dbo].[Amount]   NULL,
    [TaxPer]               [dbo].[Amount]   NULL,
    [TaxAmt]               [dbo].[Amount]   NULL,
    [NetAmt]               [dbo].[Amount]   NULL,
    [PlantDepotId]         INT              NULL,
    [StatusId]             TINYINT          NULL,
    [POCategoryId]         TINYINT          NULL,
    [LoginIDUpd]           INT              NULL,
    [TimestampUpd]         DATETIME         NULL,
    [ReasonForChange]      VARCHAR (500)    NULL,
    [flgSAPDataSent]       TINYINT          CONSTRAINT [DF__tblPurcha__flgSA__2181C68A] DEFAULT ((0)) NOT NULL,
    [DataSentTime]         DATETIME         NULL,
    [PriSchemeDetId]       INT              NULL,
    [ActDiscPer]           [dbo].[Amount]   NULL,
    [ActDisc]              [dbo].[Amount]   NULL,
    [ActLineOrderValWDisc] [dbo].[Amount]   NULL,
    [ActTaxAmt]            [dbo].[Amount]   NULL,
    [ActNetAmt]            [dbo].[Amount]   NULL,
    [ActFreeQty]           INT              NULL,
    [CPriSchemeId]         INT              NULL,
    [CreditLimit]          NUMERIC (18, 2)  NULL,
    [ActTCSAmt]            NUMERIC (18, 4)  DEFAULT ((0)) NULL,
    [TCSPerc]              NUMERIC (6, 3)   DEFAULT ((0)) NOT NULL,
    CONSTRAINT [PK_tblPurchaseReqDetail] PRIMARY KEY CLUSTERED ([PurchReqDetId] ASC),
    CONSTRAINT [FK_tblPurchaseReqDetail_tblPurchaseReqMaster] FOREIGN KEY ([PurchReqId]) REFERENCES [dbo].[tblPurchaseReqMaster] ([PurchReqId]) ON DELETE CASCADE ON UPDATE CASCADE
);

