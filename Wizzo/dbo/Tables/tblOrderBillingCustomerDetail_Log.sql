CREATE TABLE [dbo].[tblOrderBillingCustomerDetail_Log] (
    [OrderLogID]              INT      NULL,
    [OrderBillingLocationId]  INT      NOT NULL,
    [OrderID]                 INT      NULL,
    [BillingLocationNodeId]   INT      NULL,
    [BillingLocationNodeType] INT      NULL,
    [BillingDeptNodeId]       INT      NULL,
    [BillingDeptNodeType]     INT      NULL,
    [LoginIDIns]              INT      NULL,
    [LoginIDUpd]              INT      NULL,
    [TimeStampIns]            DATETIME NULL,
    [TimeStampUpd]            DATETIME NULL
);

