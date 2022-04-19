﻿CREATE TYPE [dbo].[udt_RawDataStoreList_ASM] AS TABLE (
    [IMEINumber]          NVARCHAR (500) NULL,
    [StoreID]             NVARCHAR (500) NULL,
    [StoreName]           NVARCHAR (500) NULL,
    [OwnerName]           NVARCHAR (500) NULL,
    [StoreContactNo]      NVARCHAR (500) NULL,
    [StoreAddress]        NVARCHAR (500) NULL,
    [StoreType]           NVARCHAR (500) NULL,
    [StoreLatitude]       NVARCHAR (500) NULL,
    [StoreLongitude]      NVARCHAR (500) NULL,
    [LastVisitDate]       NVARCHAR (500) NULL,
    [LastTransactionDate] NVARCHAR (500) NULL,
    [IsNewStore]          NVARCHAR (500) NULL,
    [PaymentStage]        NVARCHAR (500) NULL,
    [DBR]                 NVARCHAR (500) NULL,
    [StoreCity]           NVARCHAR (500) NULL,
    [StorePinCode]        NVARCHAR (500) NULL,
    [StoreState]          NVARCHAR (500) NULL,
    [flgRestart]          NVARCHAR (500) NULL,
    [AppVersion]          NVARCHAR (500) NULL,
    [StoreStateID]        NVARCHAR (500) NULL,
    [StoreCityID]         NVARCHAR (500) NULL,
    [flgOrderType]        NVARCHAR (500) NULL,
    [flgPTRPTCmarked]     NVARCHAR (500) NULL);

