CREATE TABLE [dbo].[tblOrderDeliveryCustomerDetail] (
    [OrderDeliveryLocationId]       INT      IDENTITY (1, 1) NOT NULL,
    [OrderID]                       INT      NULL,
    [DeliveryLocationNodeId]        INT      NULL,
    [DeliveryLocationNodeType]      INT      NULL,
    [DeliveryContactPersonNodeId]   INT      NULL,
    [DeliveryContactPersonNodeType] INT      NULL,
    [LoginIDIns]                    INT      NULL,
    [LoginIDUpd]                    INT      NULL,
    [TimeStampIns]                  DATETIME NULL,
    [TimeStampUpd]                  DATETIME NULL,
    CONSTRAINT [PK_tblOrderDeliveryCustomerDetail] PRIMARY KEY CLUSTERED ([OrderDeliveryLocationId] ASC)
);

