CREATE TABLE [dbo].[tblTCOrderSBDGroupDetail] (
    [OrderSBDGroupId] INT  IDENTITY (1, 1) NOT NULL,
    [OrderId]         INT  NOT NULL,
    [OrderDate]       DATE NOT NULL,
    [OrderDetId]      INT  NOT NULL,
    [SBDGroupId]      INT  NOT NULL,
    CONSTRAINT [PK_tblOrderSBDGroupDetail] PRIMARY KEY CLUSTERED ([OrderSBDGroupId] ASC)
);

