﻿CREATE TABLE [dbo].[tblClosedStoreVisitDetails] (
    [ClosedStoreVisitID] INT              IDENTITY (1, 1) NOT NULL,
    [StoreID]            INT              NOT NULL,
    [VisitID]            INT              NOT NULL,
    [ReasonId]           INT              NULL,
    [ReasonDescr]        VARCHAR (200)    NULL,
    [ActualLatitude]     DECIMAL (30, 27) NULL,
    [ActualLongitude]    DECIMAL (30, 27) NULL,
    [LocProvider]        VARCHAR (50)     NULL,
    [Accuracy]           VARCHAR (100)    NULL,
    [Imei]               VARCHAR (100)    NULL,
    [City]               VARCHAR (200)    NULL,
    [PinCode]            BIGINT           NULL,
    [State]              VARCHAR (200)    NULL,
    [Address]            VARCHAR (500)    NULL,
    [AllProviderData]    VARCHAR (500)    NULL,
    [GPSLatitude]        NUMERIC (18, 16) NULL,
    [GPSLongitude]       NUMERIC (18, 16) NULL,
    [GPSAccuracy]        VARCHAR (100)    NULL,
    [GPSAddress]         VARCHAR (500)    NULL,
    [NetworkLatitude]    NUMERIC (18, 16) NULL,
    [NetworkLongitude]   NUMERIC (18, 16) NULL,
    [NetworkAccuracy]    VARCHAR (100)    NULL,
    [NetworkAddress]     VARCHAR (500)    NULL,
    [FusedLatitude]      NUMERIC (18, 16) NULL,
    [FusedLongitude]     NUMERIC (18, 16) NULL,
    [FusedAccuracy]      VARCHAR (100)    NULL,
    [FusedAddress]       VARCHAR (500)    NULL,
    [TimeStampIns]       DATETIME         NOT NULL,
    [TimeStampUpd]       DATETIME         NULL,
    CONSTRAINT [PK_tblClosedStoreVisitDetails] PRIMARY KEY CLUSTERED ([ClosedStoreVisitID] ASC)
);

