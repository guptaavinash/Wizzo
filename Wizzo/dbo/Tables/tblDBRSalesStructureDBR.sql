CREATE TABLE [dbo].[tblDBRSalesStructureDBR] (
    [NodeID]                            INT              IDENTITY (1, 1) NOT NULL,
    [Descr]                             VARCHAR (100)    NULL,
    [DistributorCode]                   VARCHAR (50)     NULL,
    [NodeType]                          INT              CONSTRAINT [DF_tblDBRSalesStructureDBR_NodeType] DEFAULT ((150)) NOT NULL,
    [IsActive]                          BIT              CONSTRAINT [DF_tblDBRSalesStructureDBR_IsActive] DEFAULT ((1)) NOT NULL,
    [Flag]                              VARCHAR (5)      NULL,
    [StateCode]                         VARCHAR (50)     NULL,
    [StateName]                         VARCHAR (150)    NULL,
    [City]                              VARCHAR (100)    NULL,
    [ISRCode]                           VARCHAR (50)     NULL,
    [ISRNAME]                           VARCHAR (250)    NULL,
    [HQCode]                            VARCHAR (30)     NULL,
    [FileSetIDIns]                      BIGINT           CONSTRAINT [DF_tblDBRSalesStructureDBR_FileSetIDIns] DEFAULT ((0)) NOT NULL,
    [TimestampIns]                      DATETIME         CONSTRAINT [DF_tblDBRSalesStructureDBR_TimestampIns] DEFAULT (getdate()) NOT NULL,
    [FileSetIDUpd]                      INT              NULL,
    [TimestampUpd]                      DATETIME         NULL,
    [flgLive]                           TINYINT          DEFAULT ((0)) NOT NULL,
    [NoOfDlvryDays]                     TINYINT          NULL,
    [Address1]                          VARCHAR (500)    NULL,
    [Address2]                          VARCHAR (500)    NULL,
    [Phone]                             VARCHAR (50)     NULL,
    [ContactPerson]                     VARCHAR (200)    NULL,
    [EmailId]                           VARCHAR (100)    NULL,
    [StateId]                           INT              NULL,
    [Region]                            VARCHAR (50)     NULL,
    [PinCode]                           VARCHAR (50)     NULL,
    [DlvryWeeklyOffDay]                 TINYINT          CONSTRAINT [DF_tblDBRSalesStructureDBR_DlvryWeeklyOffDay] DEFAULT ((7)) NOT NULL,
    [OfficeWeeklyOffDay]                TINYINT          CONSTRAINT [DF_tblDBRSalesStructureDBR_OfficeWeeklyOffDay] DEFAULT ((7)) NOT NULL,
    [PhoneNo]                           VARCHAR (50)     NULL,
    [FSSAINo]                           VARCHAR (50)     NULL,
    [GSTNo]                             VARCHAR (50)     NULL,
    [CSTTinNo]                          VARCHAR (50)     NULL,
    [DLNo]                              VARCHAR (50)     NULL,
    [InvoiceTermCondition]              VARCHAR (4000)   NULL,
    [IsSuperStockiest]                  BIT              CONSTRAINT [DF_tblDBRSalesStructureDBR_IsSuperStockiest] DEFAULT ((0)) NOT NULL,
    [CityId]                            INT              NULL,
    [CountryId]                         INT              NULL,
    [Email]                             VARCHAR (50)     NULL,
    [BankAcNo]                          VARCHAR (50)     NULL,
    [BankId]                            INT              NULL,
    [IFSCCode]                          VARCHAR (50)     NULL,
    [MicrCode]                          VARCHAR (20)     NULL,
    [BankAdd]                           VARCHAR (250)    NULL,
    [FirstName]                         VARCHAR (200)    NULL,
    [LastName]                          VARCHAR (200)    NULL,
    [DOB]                               DATE             NULL,
    [PrcRegionId]                       INT              NULL,
    [LatCode]                           NUMERIC (27, 24) NULL,
    [LongCode]                          NUMERIC (27, 24) NULL,
    [MobileNo]                          BIGINT           NULL,
    [AreaCovered]                       VARCHAR (200)    NULL,
    [NoOFRetailersCovered]              INT              NULL,
    [GodownArea]                        INT              NULL,
    [MonthlyTurnOver]                   INT              NULL,
    [VehicleTypeID]                     INT              NULL,
    [NoOFVehicles]                      INT              NULL,
    [OrderTATinDays]                    INT              NULL,
    [CompanyProductInvestment]          INT              NULL,
    [RetailerCreditLimit]               INT              NULL,
    [BusinessSince]                     INT              NULL,
    [DistributorReady]                  TINYINT          NULL,
    [NextFollowupDate]                  DATE             NULL,
    [NoEmployee_Dispatch]               INT              NULL,
    [NoEmployee_Billing]                INT              NULL,
    [NoEmployee_SalesStaff]             INT              NULL,
    [IsOldDistributorReplaced]          TINYINT          NULL,
    [IsOldDistributorDFinalPaymentDone] TINYINT          NULL,
    [flgDistributorSS]                  TINYINT          NULL,
    [IsNewLocation]                     TINYINT          NULL,
    [flgTownDistributorSubD]            TINYINT          NULL,
    [Address_Godown]                    VARCHAR (200)    NULL,
    [Pincode_Godown]                    BIGINT           NULL,
    [City_Godown]                       VARCHAR (200)    NULL,
    [District_Godown]                   VARCHAR (200)    NULL,
    [State_Godown]                      VARCHAR (200)    NULL,
    [flgProprietorPartner]              TINYINT          NULL,
    [ExpectedBusiness]                  INT              NULL,
    [ReqGodownSpace]                    INT              NULL,
    [AgreedGodownSpace]                 VARCHAR (100)    NULL,
    [AgreedInvestment]                  INT              NULL,
    [IdealROI]                          INT              NULL,
    [ExpectedROI]                       INT              NULL,
    [IsCheckGiven]                      TINYINT          NULL,
    [ChequeNumber]                      VARCHAR (20)     NULL,
    [IsGSTDetailsSubmitted]             TINYINT          NULL,
    [GSTNumber]                         VARCHAR (20)     NULL,
    [IsProprietorPanSubmited]           TINYINT          NULL,
    [ProprietorPanNumber]               VARCHAR (20)     NULL,
    [IsPartnerDeedSubmitted]            TINYINT          NULL,
    [PartnerDeednumber]                 VARCHAR (20)     NULL,
    [IsPartner1PanSubmitted]            TINYINT          NULL,
    [PanNumber_Partner1]                VARCHAR (20)     NULL,
    [IsPartner2PanSubmitted]            TINYINT          NULL,
    [PanNumber_Partner2]                VARCHAR (20)     NULL,
    [IsFirmPanSubmitted]                TINYINT          NULL,
    [PanNumber_Firm]                    VARCHAR (20)     NULL,
    [flgAtLocation]                     TINYINT          NULL,
    CONSTRAINT [PK_tblDBRSalesStructureDBR] PRIMARY KEY CLUSTERED ([NodeID] ASC)
);


GO
CREATE NONCLUSTERED INDEX [IX_tblDBRSalesStructureDBR]
    ON [dbo].[tblDBRSalesStructureDBR]([NodeID] ASC, [NodeType] ASC);

