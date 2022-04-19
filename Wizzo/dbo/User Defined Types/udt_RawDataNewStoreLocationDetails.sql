CREATE TYPE [dbo].[udt_RawDataNewStoreLocationDetails] AS TABLE (
    [StoreID]                               NVARCHAR (500) NULL,
    [VisitEndTS]                            NVARCHAR (500) NULL,
    [LocProvider]                           NVARCHAR (500) NULL,
    [Accuracy]                              NVARCHAR (500) NULL,
    [BateryLeftStatus]                      NVARCHAR (500) NULL,
    [flgLocationServicesOnOff]              NVARCHAR (500) NULL,
    [flgGPSOnOff]                           NVARCHAR (500) NULL,
    [flgNetworkOnOff]                       NVARCHAR (500) NULL,
    [flgFusedOnOff]                         NVARCHAR (500) NULL,
    [flgInternetOnOffWhileLocationTracking] NVARCHAR (500) NULL,
    [Sstat]                                 NVARCHAR (500) NULL);

