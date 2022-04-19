CREATE TABLE [dbo].[tblOrderDeliveryTimeDetail] (
    [OrderDetailDlvryTimeId] INT      IDENTITY (1, 1) NOT NULL,
    [OrderId]                INT      NOT NULL,
    [DlvryTimeType]          TINYINT  NOT NULL,
    [DlvryStartTime]         TIME (7) NOT NULL,
    [DlvryEndTime]           TIME (7) NOT NULL,
    CONSTRAINT [PK_tblOrderDeliveryTimeDetail_!] PRIMARY KEY CLUSTERED ([OrderDetailDlvryTimeId] ASC),
    CONSTRAINT [FK_tblOrderDeliveryTimeDetail_tblOrderMaster_1] FOREIGN KEY ([OrderId]) REFERENCES [dbo].[tblOrderMaster] ([OrderID]) ON DELETE CASCADE
);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'1:Between Time,2: Not Between Time', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblOrderDeliveryTimeDetail', @level2type = N'COLUMN', @level2name = N'DlvryTimeType';

