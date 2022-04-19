CREATE TABLE [dbo].[tblVisitMaster] (
    [VisitID]                               INT              IDENTITY (1, 1) NOT NULL,
    [RouteID]                               INT              NOT NULL,
    [RouteVisitID]                          INT              NULL,
    [StoreID]                               INT              NOT NULL,
    [VisitLatitude]                         DECIMAL (27, 24) NULL,
    [VisitLongitude]                        DECIMAL (27, 24) NULL,
    [VisitDate]                             DATE             NOT NULL,
    [SalesPersonID]                         INT              NOT NULL,
    [SalesPersonType]                       TINYINT          NOT NULL,
    [DeviceVisitStartTS]                    TIME (7)         NULL,
    [DeviceVisitEndTS]                      TIME (7)         NULL,
    [FlgOnRoute]                            TINYINT          CONSTRAINT [DF__tblVisitM__FlgOn__20ACD28B] DEFAULT ((1)) NOT NULL,
    [flgOutletNextDay]                      TINYINT          CONSTRAINT [DF__tblVisitM__flgOu__21A0F6C4] DEFAULT ((0)) NOT NULL,
    [flgOutletClose]                        TINYINT          CONSTRAINT [DF__tblVisitM__flgOu__22951AFD] DEFAULT ((0)) NOT NULL,
    [BatteryLeftStatus]                     INT              NOT NULL,
    [LocationProvider]                      VARCHAR (200)    NULL,
    [Accuracy]                              VARCHAR (200)    NOT NULL,
    [TIMESTAMP]                             DATETIME         CONSTRAINT [DF__tblVisitM__TIMES__23893F36] DEFAULT (getdate()) NOT NULL,
    [flgColler]                             TINYINT          NULL,
    [flg24By7]                              TINYINT          NULL,
    [RouteType]                             TINYINT          NULL,
    [flgSubmitSalesQuoteOnly]               TINYINT          CONSTRAINT [DF_tblVisitMaster_flgSubmitSalesQuoteOnly] DEFAULT ((0)) NULL,
    [flgVisitSubmitType]                    TINYINT          CONSTRAINT [DF_tblVisitMaster_flgVisitSubmitType] DEFAULT ((0)) NULL,
    [flgCollectionStatus]                   TINYINT          NULL,
    [VanID]                                 INT              NULL,
    [VANDailyClosureId]                     INT              NULL,
    [VANCycClosureId]                       INT              NULL,
    [EntryPersonNodeID]                     INT              NOT NULL,
    [EntryPersonNodeType]                   SMALLINT         NOT NULL,
    [StoreVisitCode]                        VARCHAR (150)    NULL,
    [AllProviderData]                       VARCHAR (500)    NULL,
    [GPSLatitude]                           NUMERIC (27, 24) NULL,
    [GPSLongitude]                          NUMERIC (27, 24) NULL,
    [GPSAccuracy]                           VARCHAR (100)    NULL,
    [GPSAddress]                            VARCHAR (500)    NULL,
    [NetworkLatitude]                       NUMERIC (27, 24) NULL,
    [NetworkLongitude]                      NUMERIC (27, 24) NULL,
    [NetworkAccuracy]                       VARCHAR (100)    NULL,
    [NetworkAddress]                        VARCHAR (500)    NULL,
    [FusedLatitude]                         NUMERIC (27, 24) NULL,
    [FusedLongitude]                        NUMERIC (27, 24) NULL,
    [FusedAccuracy]                         VARCHAR (100)    NULL,
    [FusedAddress]                          VARCHAR (500)    NULL,
    [flgLocationServicesOnOff]              TINYINT          NULL,
    [flgGPSOnOff]                           TINYINT          NULL,
    [flgNetworkOnOff]                       TINYINT          NULL,
    [flgFusedOnOff]                         TINYINT          NULL,
    [flgInternetOnOffWhileLocationTracking] TINYINT          NULL,
    [flgRestart]                            TINYINT          NULL,
    [Address]                               VARCHAR (500)    NULL,
    [Distance]                              NUMERIC (38, 6)  NULL,
    [flgTelephonicCall]                     TINYINT          CONSTRAINT [DF_tblVisitMaster_flgTelephonicCall] DEFAULT ((0)) NULL,
    [SourceId]                              TINYINT          CONSTRAINT [DF__tblVisitM__Sourc__1A959D30] DEFAULT ((2)) NOT NULL,
    [NoOrderReasonID]                       INT              NULL,
    [NoOrderReasonDescr]                    VARCHAR (200)    NULL,
    [TeleCallingID]                         INT              NULL,
    [flgOrderCancel]                        TINYINT          NULL,
    [VisitComments]                         VARCHAR (500)    NULL,
    [flgIsPicAllowed]                       TINYINT          NULL,
    [NoPicReason]                           VARCHAR (500)    NULL,
    [FileSetID]                             BIGINT           NULL,
    [IsGeoValidated]                        TINYINT          NULL,
    [flgIsinJointVisit]                     TINYINT          NULL,
    [JointVisitID]                          INT              NULL,
    [VisitMonthYear]                        AS               (datepart(year,[VisitDate])*(100)+datepart(month,[VisitDate])),
    CONSTRAINT [PK__tblVisit__4D3AA1BE1EC48A19] PRIMARY KEY CLUSTERED ([VisitID] ASC)
);


GO
CREATE NONCLUSTERED INDEX [IX_tblVisitMaster]
    ON [dbo].[tblVisitMaster]([VisitDate] DESC);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'0=No Sales Quote,1=Sales Quote Only', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblVisitMaster', @level2type = N'COLUMN', @level2name = N'flgSubmitSalesQuoteOnly';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'0=Regular Submit from Order Screen,1=Submit from outside the order screen.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblVisitMaster', @level2type = N'COLUMN', @level2name = N'flgVisitSubmitType';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'1=MTAS Visit,2=Physical Visit,3=Incoming Telephonic  Order', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblVisitMaster', @level2type = N'COLUMN', @level2name = N'SourceId';

