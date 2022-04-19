﻿CREATE TYPE [dbo].[udt_RawDataAttandanceDetails] AS TABLE (
    [AttandanceTime]                        NVARCHAR (500) NULL,
    [PersonNodeID]                          NVARCHAR (500) NULL,
    [PersonNodeType]                        NVARCHAR (500) NULL,
    [ReasonID]                              NVARCHAR (500) NULL,
    [ReasonDesc]                            NVARCHAR (500) NULL,
    [fnLati]                                NVARCHAR (500) NULL,
    [fnLongi]                               NVARCHAR (500) NULL,
    [fnAccuracy]                            NVARCHAR (500) NULL,
    [AllProvidersLocation]                  NVARCHAR (500) NULL,
    [fnAddress]                             NVARCHAR (500) NULL,
    [Pincode]                               NVARCHAR (500) NULL,
    [City]                                  NVARCHAR (500) NULL,
    [State]                                 NVARCHAR (500) NULL,
    [MapAddress]                            NVARCHAR (500) NULL,
    [MapPincode]                            NVARCHAR (500) NULL,
    [MapCity]                               NVARCHAR (500) NULL,
    [MapState]                              NVARCHAR (500) NULL,
    [Comment]                               NVARCHAR (500) NULL,
    [GPSLatitude]                           NVARCHAR (500) NULL,
    [GPSLongitude]                          NVARCHAR (500) NULL,
    [GPSAccuracy]                           NVARCHAR (500) NULL,
    [GPSAddress]                            NVARCHAR (500) NULL,
    [NetworkLatitude]                       NVARCHAR (500) NULL,
    [NetworkLongitude]                      NVARCHAR (500) NULL,
    [NetworkAccuracy]                       NVARCHAR (500) NULL,
    [NetworkAddress]                        NVARCHAR (500) NULL,
    [FusedLatitude]                         NVARCHAR (500) NULL,
    [FusedLongitude]                        NVARCHAR (500) NULL,
    [FusedAccuracy]                         NVARCHAR (500) NULL,
    [FusedAddress]                          NVARCHAR (500) NULL,
    [flgLocNotFound]                        NVARCHAR (500) NULL,
    [flgLocationServicesOnOff]              NVARCHAR (500) NULL,
    [flgGPSOnOff]                           NVARCHAR (500) NULL,
    [flgNetworkOnOff]                       NVARCHAR (500) NULL,
    [flgFusedOnOff]                         NVARCHAR (500) NULL,
    [flgInternetOnOffWhileLocationTracking] NVARCHAR (500) NULL,
    [BatteryStatus]                         NVARCHAR (500) NULL,
    [IsNetworkTimeRecorded]                 NVARCHAR (500) NULL,
    [OSVersion]                             NVARCHAR (500) NULL,
    [device]                                NVARCHAR (500) NULL,
    [BrandName]                             NVARCHAR (500) NULL,
    [Model]                                 NVARCHAR (500) NULL,
    [DeviceDatetime]                        NVARCHAR (500) NULL,
    [flgUserAgreement]                      NVARCHAR (500) NULL,
    [LeaveStartDate]                        NVARCHAR (500) NULL,
    [LeaveEndDate]                          NVARCHAR (500) NULL,
    [SelfieName]                            NVARCHAR (500) NULL,
    [SelfieURL]                             NVARCHAR (500) NULL);
