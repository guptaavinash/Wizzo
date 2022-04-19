CREATE TABLE [dbo].[tblOrderBillingCustomerDetail] (
    [OrderBillingLocationId]  INT      IDENTITY (1, 1) NOT NULL,
    [OrderID]                 INT      NULL,
    [BillingLocationNodeId]   INT      NULL,
    [BillingLocationNodeType] INT      NULL,
    [BillingDeptNodeId]       INT      NULL,
    [BillingDeptNodeType]     INT      NULL,
    [LoginIDIns]              INT      NULL,
    [LoginIDUpd]              INT      NULL,
    [TimeStampIns]            DATETIME NULL,
    [TimeStampUpd]            DATETIME NULL,
    CONSTRAINT [PK_tblOrderBillingCustomerDetail] PRIMARY KEY CLUSTERED ([OrderBillingLocationId] ASC)
);

