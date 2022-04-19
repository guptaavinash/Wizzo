﻿CREATE TABLE [dbo].[tblPDASyncApprovedStoreMapping] (
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
    [FlgActive]                             TINYINT          CONSTRAINT [DF_tblPDASyncApprovedStoreMapping_FlgActive] DEFAULT ((1)) NULL,
    [RecordUpdated]                         INT              NULL,
    [OrgStoreId]                            INT              NULL,
    [DistributorID]                         INT              NULL,
    [DistributorType]                       SMALLINT         NULL,
    [DBNodeId]                              INT              NULL,
    [DBNodeType]                            INT              NULL,
    [flgStoreValidated]                     TINYINT          CONSTRAINT [DF_tblPDASyncApprovedStoreMapping_flgStoreValidated] DEFAULT ((0)) NULL,
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
    [StateID]                               INT              NULL,
    CONSTRAINT [PK_tblPDASyncApprovedStoreMapping] PRIMARY KEY CLUSTERED ([StoreIDDB] ASC),
    CONSTRAINT [FK_tblPDASyncApprovedStoreMapping_tblPDASyncStoreMappingMstr] FOREIGN KEY ([StoreIDDB]) REFERENCES [dbo].[tblPDASyncStoreMappingMstr] ([StoreIDDB]) ON DELETE CASCADE ON UPDATE CASCADE
);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'0=Not Validated,1=Validated,2=Rejected,3=Remap', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblPDASyncApprovedStoreMapping', @level2type = N'COLUMN', @level2name = N'flgStoreValidated';

