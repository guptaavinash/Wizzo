﻿CREATE TYPE [dbo].[udt_RawDataInvoiceHeader] AS TABLE (
    [StoreVisitCode]                   NVARCHAR (500) NULL,
    [VisitID]                          NVARCHAR (500) NULL,
    [InvoiceNumber]                    NVARCHAR (500) NULL,
    [TmpInvoiceCodePDA]                NVARCHAR (500) NULL,
    [StoreID]                          NVARCHAR (500) NULL,
    [InvoiceDate]                      NVARCHAR (500) NULL,
    [TotalBeforeTaxDis]                NVARCHAR (500) NULL,
    [TaxAmt]                           NVARCHAR (500) NULL,
    [TotalDis]                         NVARCHAR (500) NULL,
    [InvoiceVal]                       NVARCHAR (500) NULL,
    [FreeTotal]                        NVARCHAR (500) NULL,
    [InvAfterDis]                      NVARCHAR (500) NULL,
    [AddDis]                           NVARCHAR (500) NULL,
    [NoCoupon]                         NVARCHAR (500) NULL,
    [TotalCoupunAmount]                NVARCHAR (500) NULL,
    [TransDate]                        NVARCHAR (500) NULL,
    [FlgInvoiceType]                   NVARCHAR (500) NULL,
    [flgWholeSellApplicable]           NVARCHAR (500) NULL,
    [flgProcessedInvoice]              NVARCHAR (500) NULL,
    [CycleID]                          NVARCHAR (500) NULL,
    [RouteNodeTypeflgDrctslsIndrctSls] NVARCHAR (500) NULL,
    [RouteNodeID]                      NVARCHAR (500) NULL,
    [RouteNodeType]                    NVARCHAR (500) NULL,
    [Remark]                           NVARCHAR (500) NULL,
    [TeleCallingId]                    NVARCHAR (500) NULL,
    [flgOrderCancel]                   NVARCHAR (500) NULL);
