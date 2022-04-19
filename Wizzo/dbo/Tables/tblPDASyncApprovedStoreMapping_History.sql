﻿CREATE TABLE [dbo].[tblPDASyncApprovedStoreMapping_History] (
    [StoreIDDB]                             INT              NOT NULL,
    [RouteID]                               NVARCHAR (50)    NULL,
    [RouteNodeType]                         SMALLINT         NULL,
    [StoreID]                               NVARCHAR (100)   NULL,
    [OutletName]                            NVARCHAR (200)   NULL,
    [ActualLatitude]                        DECIMAL (30, 27) NULL,
    [ActualLongitude]                       DECIMAL (30, 27) NULL,
    [LocProvider]                           VARCHAR (50)     NULL,
    [Accuracy]                              VARCHAR (100)    NULL,
    [VisitStartTS]                          DATETIME         NULL,
    [VisitEndTS]                            DATETIME         NULL,
    [Imei]                                  VARCHAR (100)    NULL,
    [XMLFullDate]                           VARCHAR (100)    NULL,
    [XMLReceiveDate]                        DATETIME         NULL,
    [BatteryStatus]                         VARCHAR (10)     NULL,
    [CreateDate]                            DATETIME         NULL,
    [ModifyDate]                            DATETIME         NULL,
    [AppVersion]                            INT              NULL,
    [FlgActive]                             TINYINT          NULL,
    [RecordUpdated]                         INT              NULL,
    [OrgStoreId]                            INT              NULL,
    [DistributorID]                         INT              NULL,
    [DistributorType]                       SMALLINT         NULL,
    [DBNodeId]                              INT              NULL,
    [DBNodeType]                            INT              NULL,
    [flgStoreValidated]                     TINYINT          NULL,
    [flgValidationMode]                     TINYINT          NULL,
    [StoreMapAddress]                       VARCHAR (2000)   NULL,
    [City]                                  VARCHAR (200)    NULL,
    [PinCode]                               BIGINT           NULL,
    [State]                                 VARCHAR (200)    NULL,
    [Address]                               VARCHAR (500)    NULL,
    [Distance]                              NUMERIC (38, 6)  NULL,
    [AllProviderData]                       VARCHAR (300)    NULL,
    [GPSLatitude]                           NUMERIC (18, 16) NULL,
    [GPSLongitude]                          NUMERIC (18, 16) NULL,
    [GPSAccuracy]                           VARCHAR (100)    NULL,
    [GPSAddress]                            VARCHAR (500)    NULL,
    [NetworkLatitude]                       NUMERIC (18, 16) NULL,
    [NetworkLongitude]                      NUMERIC (18, 16) NULL,
    [NetworkAccuracy]                       VARCHAR (100)    NULL,
    [NetworkAddress]                        VARCHAR (500)    NULL,
    [FusedLatitude]                         NUMERIC (18, 16) NULL,
    [FusedLongitude]                        NUMERIC (18, 16) NULL,
    [FusedAccuracy]                         VARCHAR (100)    NULL,
    [FusedAddress]                          VARCHAR (500)    NULL,
    [flgLocationServicesOnOff]              TINYINT          NULL,
    [flgGPSOnOff]                           TINYINT          NULL,
    [flgNetworkOnOff]                       TINYINT          NULL,
    [flgFusedOnOff]                         TINYINT          NULL,
    [flgInternetOnOffWhileLocationTracking] TINYINT          NULL,
    [flgRestart]                            TINYINT          NULL,
    [MapCity]                               VARCHAR (200)    NULL,
    [MapState]                              VARCHAR (200)    NULL,
    [MapPinCode]                            BIGINT           NULL,
    [CityID]                                INT              NULL,
    [StateID]                               INT              NULL
);
