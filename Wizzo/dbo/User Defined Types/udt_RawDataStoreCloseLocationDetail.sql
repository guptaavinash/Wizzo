﻿CREATE TYPE [dbo].[udt_RawDataStoreCloseLocationDetail] AS TABLE (
    [StoreID]            NVARCHAR (500) NULL,
    [VisitID]            NVARCHAR (500) NULL,
    [StoreVisitCode]     NVARCHAR (500) NULL,
    [Lattitude]          NVARCHAR (500) NULL,
    [Longitude]          NVARCHAR (500) NULL,
    [Accuracy]           NVARCHAR (500) NULL,
    [Address]            NVARCHAR (500) NULL,
    [City]               NVARCHAR (500) NULL,
    [Pincode]            NVARCHAR (500) NULL,
    [State]              NVARCHAR (500) NULL,
    [fnAccurateProvider] NVARCHAR (500) NULL,
    [GpsLat]             NVARCHAR (500) NULL,
    [GpsLong]            NVARCHAR (500) NULL,
    [GpsAccuracy]        NVARCHAR (500) NULL,
    [GpsAddress]         NVARCHAR (500) NULL,
    [NetwLat]            NVARCHAR (500) NULL,
    [NetwLong]           NVARCHAR (500) NULL,
    [NetwAccuracy]       NVARCHAR (500) NULL,
    [NetwAddress]        NVARCHAR (500) NULL,
    [FusedLat]           NVARCHAR (500) NULL,
    [FusedLong]          NVARCHAR (500) NULL,
    [FusedAccuracy]      NVARCHAR (500) NULL,
    [FusedAddress]       NVARCHAR (500) NULL);
