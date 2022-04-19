CREATE TABLE [dbo].[tblOrderDeliveryBillingCustomerMapping] (
    [OrderDeliveryLocationId] INT NOT NULL,
    [OrderBillingLocationId]  INT NOT NULL,
    [OrderID]                 INT NULL,
    CONSTRAINT [PK_tblOrderDeliveryBillingCustomerMapping] PRIMARY KEY CLUSTERED ([OrderDeliveryLocationId] ASC, [OrderBillingLocationId] ASC)
);

