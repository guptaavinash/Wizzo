CREATE TABLE [dbo].[tblOrderDeliveryCustomerDetail_Log] (
    [OrderLogID]                    INT      NULL,
    [OrderDeliveryLocationId]       INT      NOT NULL,
    [OrderID]                       INT      NULL,
    [DeliveryLocationNodeId]        INT      NULL,
    [DeliveryLocationNodeType]      INT      NULL,
    [DeliveryContactPersonNodeId]   INT      NULL,
    [DeliveryContactPersonNodeType] INT      NULL,
    [LoginIDIns]                    INT      NULL,
    [LoginIDUpd]                    INT      NULL,
    [TimeStampIns]                  DATETIME NULL,
    [TimeStampUpd]                  DATETIME NULL
);

