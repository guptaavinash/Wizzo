CREATE TABLE [dbo].[tblMasterFlags] (
    [flgDistributorCheckIn]               TINYINT NOT NULL,
    [flgDBRStockInApp]                    TINYINT NOT NULL,
    [flgDBRStockEdit]                     TINYINT NOT NULL,
    [flgDBRStockCalculate]                TINYINT NOT NULL,
    [flgDBRStockControl]                  TINYINT NOT NULL,
    [flgCollRequired]                     TINYINT NOT NULL,
    [flgCollReqOrdr]                      TINYINT NOT NULL,
    [flgCollTab]                          TINYINT NOT NULL,
    [flgCollDefControl]                   TINYINT NOT NULL,
    [flgCashDiscount]                     TINYINT CONSTRAINT [DF_tblMasterFlags_flgCashDiscount] DEFAULT ((0)) NOT NULL,
    [flgCollControlRule]                  TINYINT NOT NULL,
    [flgSchemeAvailable]                  TINYINT NOT NULL,
    [flgSchemeAllowEntry]                 TINYINT NOT NULL,
    [flgSchemeAllowEdit]                  TINYINT NOT NULL,
    [flgQuotationIsAvailable]             TINYINT NOT NULL,
    [flgExecutionIsAvailable]             TINYINT NOT NULL,
    [flgExecutionPhotoCompulsory]         TINYINT NOT NULL,
    [flgTargetShowatStart]                TINYINT NOT NULL,
    [flgIncentiveShowatStart]             TINYINT NOT NULL,
    [flgInvoicePrint]                     TINYINT NOT NULL,
    [flgShowPOSM]                         TINYINT NOT NULL,
    [flgVisitStartOutstandingDetails]     TINYINT NOT NULL,
    [flgVisitStartSchemeDetails]          TINYINT NOT NULL,
    [flgStoreDetailsEdit]                 TINYINT NOT NULL,
    [flgShowDeliveryAddressButtonOnOrder] TINYINT NOT NULL,
    [flgShowManagerOnStoreList]           TINYINT NOT NULL,
    [flgRptTargetVsAchived]               TINYINT NOT NULL,
    [SalesNodeID]                         INT     NOT NULL,
    [SalesNodetype]                       INT     NOT NULL,
    [WorkingTypeID]                       INT     CONSTRAINT [DF_tblMasterFlags_WorkingTypeID] DEFAULT ((0)) NOT NULL,
    [flgVanStockInApp]                    TINYINT NOT NULL,
    [flgVanStockEdit]                     TINYINT NOT NULL,
    [flgVanStockCalculate]                TINYINT NOT NULL,
    [flgVanStockControl]                  TINYINT NOT NULL,
    [flgStockRefillReq]                   TINYINT NOT NULL,
    [flgDayEnd]                           TINYINT NOT NULL,
    [flgStockUnloadAtCycleEnd]            TINYINT NOT NULL,
    [flgStockUnloadAtDayEnd]              TINYINT NOT NULL,
    [flgCollReqATCycleEnd]                TINYINT NOT NULL,
    [flgCollReqATDayEnd]                  TINYINT NOT NULL,
    [flgDayEndSummary]                    TINYINT NOT NULL,
    [flgStoreCheckInApplicable]           TINYINT NOT NULL,
    [flgStoreCheckInPhotoCompulsory]      TINYINT NOT NULL,
    [flgDBRStockCanSkipFillInDayStart]    TINYINT NULL
);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'0=Start With Any Location,1=Start with Warehouse/Distributor Location.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblMasterFlags', @level2type = N'COLUMN', @level2name = N'flgDistributorCheckIn';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'1=Distributor Stock is Required.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblMasterFlags', @level2type = N'COLUMN', @level2name = N'flgDBRStockInApp';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'1=Form is Required to Update/Fill the Distributor Stock.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblMasterFlags', @level2type = N'COLUMN', @level2name = N'flgDBRStockEdit';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'0=No Update Required,1=Update Based On Self Orders.,2=Refresh Stock from Db On every Sync.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblMasterFlags', @level2type = N'COLUMN', @level2name = N'flgDBRStockCalculate';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'1=Sales Rep Can OverBook Orders.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblMasterFlags', @level2type = N'COLUMN', @level2name = N'flgDBRStockControl';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'1=Collection can be done via App.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblMasterFlags', @level2type = N'COLUMN', @level2name = N'flgCollRequired';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'1=Whether Collection is part of the Order or Call Process.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblMasterFlags', @level2type = N'COLUMN', @level2name = N'flgCollReqOrdr';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'1=New Form for the Collections Only.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblMasterFlags', @level2type = N'COLUMN', @level2name = N'flgCollTab';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'0=No Control,1=No Credit,Full Amount Need to be Collected,2=Previous Amount to be Collected.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblMasterFlags', @level2type = N'COLUMN', @level2name = N'flgCollDefControl';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'1=Default Rule Only,2=Retailer Terms ,Default if no Terms.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblMasterFlags', @level2type = N'COLUMN', @level2name = N'flgCollControlRule';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'1=Scheme Defines at backend and calculated on PDA.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblMasterFlags', @level2type = N'COLUMN', @level2name = N'flgSchemeAvailable';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'0=No Scheme Entry Allowed.(If flgSchemeAvailable is also 0, freeQty and Discount will not show).
1=Textbox for freeQty/Discount for Data Entry.(If flgSchemeAvailable=1 this cannot be selected).
', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblMasterFlags', @level2type = N'COLUMN', @level2name = N'flgSchemeAllowEntry';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'If flgSchemeAvailable=1 Only
0=No Edit of Scheme calcualted.
1=Allow Edit.(Later Development)', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblMasterFlags', @level2type = N'COLUMN', @level2name = N'flgSchemeAllowEdit';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'1=Sales Quotation is available at backend.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblMasterFlags', @level2type = N'COLUMN', @level2name = N'flgQuotationIsAvailable';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Execution is available on PDA.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblMasterFlags', @level2type = N'COLUMN', @level2name = N'flgExecutionIsAvailable';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'0=Photo is Optional.
1=User must take photo of each Invoice.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblMasterFlags', @level2type = N'COLUMN', @level2name = N'flgExecutionPhotoCompulsory';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'1=Target page need to display on PDA at Day Start.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblMasterFlags', @level2type = N'COLUMN', @level2name = N'flgTargetShowatStart';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'1=Incentive Page Need to Display at Day Start.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblMasterFlags', @level2type = N'COLUMN', @level2name = N'flgIncentiveShowatStart';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Print Button Is Needed.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblMasterFlags', @level2type = N'COLUMN', @level2name = N'flgInvoicePrint';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'OutStanding Details Need to Display at Visit Summary Page', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblMasterFlags', @level2type = N'COLUMN', @level2name = N'flgVisitStartOutstandingDetails';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Scheme Details Need to Display at Visit Summary Page', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblMasterFlags', @level2type = N'COLUMN', @level2name = N'flgVisitStartSchemeDetails';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Store Details can be Edited in App.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblMasterFlags', @level2type = N'COLUMN', @level2name = N'flgStoreDetailsEdit';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'1= Delivery Address Button to be shown.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblMasterFlags', @level2type = N'COLUMN', @level2name = N'flgShowDeliveryAddressButtonOnOrder';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'1=Manager List to be Displayed for joint Visit.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblMasterFlags', @level2type = N'COLUMN', @level2name = N'flgShowManagerOnStoreList';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'1=Target Vs Achieved Report will be displayed.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblMasterFlags', @level2type = N'COLUMN', @level2name = N'flgRptTargetVsAchived';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'1=Van Sales,2=Pre Order', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblMasterFlags', @level2type = N'COLUMN', @level2name = N'WorkingTypeID';

