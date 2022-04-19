CREATE TABLE [dbo].[tblTeleCallerListForDay] (
    [TeleCallingId]                  BIGINT          IDENTITY (1, 1) NOT NULL,
    [AttendDetId]                    INT             CONSTRAINT [DF_tblTeleCallerListForDay_AttendDetId] DEFAULT ((0)) NOT NULL,
    [StoreId]                        INT             NOT NULL,
    [Date]                           DATE            NOT NULL,
    [CallMade]                       DATETIME        NULL,
    [SONodeId]                       INT             NOT NULL,
    [SONodeType]                     INT             NOT NULL,
    [RouteNodeId]                    INT             NOT NULL,
    [RouteNodeType]                  INT             NOT NULL,
    [DistNodeId]                     INT             NOT NULL,
    [DistNodeType]                   INT             NOT NULL,
    [StoreCode]                      VARCHAR (50)    NULL,
    [StoreName]                      VARCHAR (500)   NULL,
    [ContactPerson]                  VARCHAR (100)   NULL,
    [ContactNo]                      VARCHAR (100)   NULL,
    [Channel]                        VARCHAR (100)   NULL,
    [SectorId]                       INT             CONSTRAINT [DF_tblTeleCallerListForDay_SectorId] DEFAULT ((1)) NOT NULL,
    [flgCallStatus]                  TINYINT         CONSTRAINT [DF_tblTeleCallerListForDay_flgCallStatus] DEFAULT ((0)) NOT NULL,
    [ScheduleCall]                   VARCHAR (50)    NULL,
    [ReasonId]                       INT             NULL,
    [CallAttempt]                    TINYINT         NULL,
    [TeleReasonId]                   INT             CONSTRAINT [DF_tblTeleCallerListForDay_TeleReasonId] DEFAULT ((1)) NOT NULL,
    [TCNodeId]                       INT             CONSTRAINT [DF_tblTeleCallerListForDay_TeleUserId] DEFAULT ((0)) NOT NULL,
    [TCNodeType]                     INT             CONSTRAINT [DF_tblTeleCallerListForDay_TCNodeType] DEFAULT ((220)) NOT NULL,
    [IsUsed]                         TINYINT         CONSTRAINT [DF_tblTeleCallerListForDay_IsUsed] DEFAULT ((0)) NOT NULL,
    [Priority]                       SMALLINT        NULL,
    [TotalSales]                     NUMERIC (18, 2) NULL,
    [NoOfInv]                        INT             NULL,
    [LastCallDate]                   DATETIME        NULL,
    [IsFinalDownloadSubmit]          BIT             CONSTRAINT [DF_tblTeleCallerListForDay_IsFinalDownloadSubmit] DEFAULT ((0)) NOT NULL,
    [IsDownloaded]                   BIT             CONSTRAINT [DF_tblTeleCallerListForDay_IsDownloaded] DEFAULT ((0)) NOT NULL,
    [OutStandingAmt]                 NUMERIC (18)    NULL,
    [OutStandingDate]                DATE            NULL,
    [InvNo]                          VARCHAR (50)    NULL,
    [InvDate]                        DATE            NULL,
    [LoginIdUpd]                     INT             NULL,
    [TimeSTampUpd]                   DATETIME        NULL,
    [OldTeleCallingId]               INT             NULL,
    [TimeStampIns]                   DATETIME        CONSTRAINT [DF__tblTeleCa__TimeS__73FA27A5] DEFAULT (getdate()) NOT NULL,
    [TCRouteCalendarId]              INT             NULL,
    [TCPlanCallsMapId]               INT             NULL,
    [LoginIdIns]                     INT             NULL,
    [ChannelId]                      INT             NULL,
    [RuleId]                         INT             NULL,
    [ScheduleDate]                   DATE            NULL,
    [CallStartDate]                  DATETIME        NULL,
    [Remarks]                        VARCHAR (500)   NULL,
    [LastOrderDate]                  DATE            NULL,
    [LastOrderValue]                 NUMERIC (18, 2) NULL,
    [OrderBy]                        VARCHAR (100)   NULL,
    [LastVisit]                      DATE            NULL,
    [LastVisitStatus]                VARCHAR (250)   NULL,
    [VisitedBy]                      VARCHAR (100)   NULL,
    [LastCall]                       DATE            NULL,
    [LastCallStatus]                 VARCHAR (250)   NULL,
    [LastCalledBY]                   VARCHAR (100)   NULL,
    [SubChannelId]                   INT             NULL,
    [SubChannel]                     VARCHAR (150)   NULL,
    [FrequencyId]                    TINYINT         NULL,
    [AlternateContactNo]             VARCHAR (50)    NULL,
    [RouteName]                      VARCHAR (100)   NULL,
    [FiveStarRuleId]                 TINYINT         NULL,
    [FiveStarNoOfGPTgt]              TINYINT         NULL,
    [FiveStarNoOfLSSTgt]             TINYINT         NULL,
    [FiveStarIndTgtDlvryVal]         NUMERIC (18, 2) NULL,
    [FiveStarProductivityTgt]        NUMERIC (18, 2) NULL,
    [TotOrderVal]                    NUMERIC (18, 2) NULL,
    [NoOfSKU]                        INT             NULL,
    [FiveStarNoOfGPAct]              TINYINT         NULL,
    [FiveStarNoOfLSSAct]             TINYINT         NULL,
    [FiveStarTotIndTgtDlvryVal]      NUMERIC (18, 2) NULL,
    [FiveStarAlrdyAchIndTgtDlvryVal] NUMERIC (18, 2) NULL,
    [NoOfStarsAch]                   TINYINT         NULL,
    [NoOfPendingVisits]              TINYINT         NULL,
    [TotInvVal]                      NUMERIC (18, 2) NULL,
    [FiveStarNoOfGPAchieved]         TINYINT         NULL,
    [FiveStarNoOfLSSAchieved]        TINYINT         NULL,
    [LanguageId]                     TINYINT         NOT NULL,
    [CallMarkTimeForBusyCall]        DATETIME        NULL,
    [SOName]                         VARCHAR (250)   NULL,
    [RouteGTMType]                   VARCHAR (50)    NULL,
    [LotId]                          TINYINT         NULL,
    [DSEComments]                    VARCHAR (500)   NULL,
    [ClusterType]                    VARCHAR (50)    NULL,
    [City]                           VARCHAR (150)   NULL,
    [DSEIssueIds]                    VARCHAR (100)   NULL,
    [StateId]                        INT             NULL,
    [ActCallAttempt]                 TINYINT         NULL,
    [IsDiscountApplicable]           TINYINT         NULL,
    [IsValidContactNo]               BIT             DEFAULT ((1)) NOT NULL,
    [PrcRegionId]                    INT             NULL,
    [DialerTypeId]                   TINYINT         CONSTRAINT [DF__tblTeleCa__Calli__75B852E5] DEFAULT ((1)) NOT NULL,
    [CloudmonitorUCID]               VARCHAR (100)   NULL,
    [flgCallConversionStatus]        TINYINT         NULL,
    [SOArea]                         VARCHAR (100)   NULL,
    [SOAreaNodeId]                   INT             NULL,
    [SOAreaNodeType]                 INT             NULL,
    CONSTRAINT [PK_tblTeleCallerListForDay] PRIMARY KEY CLUSTERED ([TeleCallingId] ASC)
);


GO
CREATE NONCLUSTERED INDEX [IX_tblTeleCallerListForDay]
    ON [dbo].[tblTeleCallerListForDay]([TCNodeId] ASC, [TCNodeType] ASC, [IsUsed] ASC, [Date] DESC);


GO
CREATE NONCLUSTERED INDEX [IX_tblTeleCallerListForDay_1]
    ON [dbo].[tblTeleCallerListForDay]([CallAttempt] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_tblTeleCallerListForDay_2]
    ON [dbo].[tblTeleCallerListForDay]([IsValidContactNo] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_tblTeleCallerListForDay_3]
    ON [dbo].[tblTeleCallerListForDay]([DistNodeId] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_tblTeleCallerListForDay_4]
    ON [dbo].[tblTeleCallerListForDay]([TCNodeId] ASC, [TCNodeType] ASC, [CallMade] ASC);

