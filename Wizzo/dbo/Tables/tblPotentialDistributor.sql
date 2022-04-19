CREATE TABLE [dbo].[tblPotentialDistributor] (
    [NodeID]                            INT              IDENTITY (1, 1) NOT NULL,
    [NodeType]                          SMALLINT         CONSTRAINT [DF_tblPotentialDistributor_NodeType] DEFAULT ((180)) NOT NULL,
    [DBRCode]                           VARCHAR (100)    NOT NULL,
    [Lat Code]                          NUMERIC (27, 24) NOT NULL,
    [Long Code]                         NUMERIC (27, 24) NOT NULL,
    [Descr]                             VARCHAR (100)    NOT NULL,
    [Contact Person Name]               VARCHAR (200)    NOT NULL,
    [Contact Person Mobile Number]      BIGINT           NOT NULL,
    [Contact Person EMailID]            VARCHAR (100)    NULL,
    [Telephone No]                      VARCHAR (20)     NULL,
    [AreaCovered]                       VARCHAR (200)    NULL,
    [No Of Retailers Covered]           INT              NULL,
    [Godown Area(sq/ft)]                INT              NULL,
    [Monthly TurnOver]                  INT              NULL,
    [VehicleType]                       INT              NULL,
    [No Of Vehicles]                    INT              NULL,
    [OrderTATinDays]                    INT              NULL,
    [CompanyProductInvestment(Lacs)]    INT              NULL,
    [RetailerCreditLimit]               INT              NULL,
    [BusinessSince]                     INT              NULL,
    [DistributorReady]                  TINYINT          CONSTRAINT [DF_tblPotentialDistributor_DistributorReady] DEFAULT ((0)) NULL,
    [NextFollowupDate]                  DATE             NULL,
    [DBREmployee_Dispatch]              INT              NULL,
    [DBREmployee_Billing]               INT              NULL,
    [DBREmployee_SalesStaff]            INT              NULL,
    [Address]                           VARCHAR (500)    NOT NULL,
    [Pincode]                           BIGINT           NOT NULL,
    [City]                              VARCHAR (100)    NOT NULL,
    [District]                          VARCHAR (100)    NULL,
    [State]                             VARCHAR (100)    NOT NULL,
    [IsOldDistributorReplaced]          TINYINT          CONSTRAINT [DF_tblPotentialDistributor_IsOldDistributorReplaced] DEFAULT ((0)) NULL,
    [IsOldDistributorDFinalPaymentDone] TINYINT          NULL,
    [flgDistributor/SS]                 TINYINT          NULL,
    [IsNewLocation]                     TINYINT          CONSTRAINT [DF_tblPotentialDistributor_IsNewLocation] DEFAULT ((0)) NULL,
    [flgTownDistributor/SubD]           TINYINT          CONSTRAINT [DF_tblPotentialDistributor_flgTownDistributor/SubD] DEFAULT ((0)) NULL,
    [Address_Godown]                    VARCHAR (500)    NULL,
    [Pincode_Godown]                    BIGINT           NULL,
    [City_Godown]                       VARCHAR (100)    NULL,
    [District_Godown]                   VARCHAR (100)    NULL,
    [State_Godown]                      VARCHAR (100)    NULL,
    [flgProprietor/Partner]             TINYINT          CONSTRAINT [DF_tblPotentialDistributor_flgProprietor/Partner] DEFAULT ((0)) NULL,
    [BankAccountNumber]                 VARCHAR (20)     NULL,
    [IFSCCode]                          VARCHAR (20)     NULL,
    [BankAddress]                       VARCHAR (500)    NULL,
    [ExpectedBusiness(In Tons)]         INT              NULL,
    [ReqGodownSpace(Sq/ft)]             INT              NULL,
    [AgreedGodownSpace(Sq/ft)]          INT              NULL,
    [AgreedInvestment(Lacs)]            INT              NULL,
    [IdealROI]                          INT              NULL,
    [ExpectedROI]                       INT              NULL,
    [IsCheckGiven]                      TINYINT          CONSTRAINT [DF_tblPotentialDistributor_IsCheckGiven] DEFAULT ((0)) NULL,
    [ChequeNumber]                      VARCHAR (20)     NULL,
    [IsGSTDetailsSubmitted]             TINYINT          CONSTRAINT [DF_tblPotentialDistributor_IsGSTDetailsSubmitted] DEFAULT ((0)) NULL,
    [GSTNumber]                         VARCHAR (20)     NULL,
    [IsProprietorPanSubmited]           TINYINT          NULL,
    [ProprietorPanNumber]               VARCHAR (20)     NULL,
    [IsPartnerDeedSubmitted]            TINYINT          NULL,
    [PartnerDeednumber]                 VARCHAR (20)     NULL,
    [IsPartner1PanSubmitted]            TINYINT          NULL,
    [PanNumber_Partner1]                VARCHAR (20)     NULL,
    [IsPartner2PanSubmitted]            TINYINT          NULL,
    [PanNumber_Partner2]                VARCHAR (20)     NULL,
    [flgFinalSubmit]                    TINYINT          CONSTRAINT [DF_tblPotentialDistributor_flgFinalSubmit] DEFAULT ((0)) NOT NULL,
    [flgAppointed]                      TINYINT          CONSTRAINT [DF_tblPotentialDistributor_flgApproved] DEFAULT ((0)) NULL,
    [flgInActive]                       TINYINT          CONSTRAINT [DF_tblPotentialDistributor_flgInActive] DEFAULT ((0)) NULL,
    [EntryPersonNodeID]                 INT              NOT NULL,
    [EntryPersonNodeType]               SMALLINT         NOT NULL,
    [CreatedDate]                       DATETIME         NULL,
    [OldDistributorID]                  INT              NULL,
    [flgAtLocation]                     TINYINT          CONSTRAINT [DF_tblPotentialDistributor_flgAtLocation] DEFAULT ((0)) NULL,
    [IsFirmPanSubmitted]                TINYINT          NULL,
    [PanNumber_Firm]                    VARCHAR (20)     NULL,
    CONSTRAINT [PK_tblPotentialDistributor] PRIMARY KEY CLUSTERED ([NodeID] ASC)
);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'1-Yes,2=No,3=May be', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblPotentialDistributor', @level2type = N'COLUMN', @level2name = N'DistributorReady';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'1=Distributor Replaced with Old', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblPotentialDistributor', @level2type = N'COLUMN', @level2name = N'IsOldDistributorReplaced';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'1=Payment Done', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblPotentialDistributor', @level2type = N'COLUMN', @level2name = N'IsOldDistributorDFinalPaymentDone';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'1=Distributor , 2=Super Stockist', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblPotentialDistributor', @level2type = N'COLUMN', @level2name = N'flgDistributor/SS';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'1=New Location,0=Old Location', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblPotentialDistributor', @level2type = N'COLUMN', @level2name = N'IsNewLocation';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'1=Distributor,2=SubD', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblPotentialDistributor', @level2type = N'COLUMN', @level2name = N'flgTownDistributor/SubD';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'1=Proprietor ,2=Partner', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblPotentialDistributor', @level2type = N'COLUMN', @level2name = N'flgProprietor/Partner';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'0=Save,1=Final Submit', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblPotentialDistributor', @level2type = N'COLUMN', @level2name = N'flgFinalSubmit';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'1= Distributor Appointed', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblPotentialDistributor', @level2type = N'COLUMN', @level2name = N'flgAppointed';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'1=InActive,0=Active', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblPotentialDistributor', @level2type = N'COLUMN', @level2name = N'flgInActive';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'1=Office,2=Godown,3=Other', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblPotentialDistributor', @level2type = N'COLUMN', @level2name = N'flgAtLocation';

