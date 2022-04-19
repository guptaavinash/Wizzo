CREATE TABLE [dbo].[tblOrderDeliveryTimeDetail_Log] (
    [OrderLogID]             INT      NULL,
    [OrderDetailDlvryTimeId] INT      NOT NULL,
    [OrderDetailDeliveryID]  INT      NOT NULL,
    [DlvryTimeType]          TINYINT  NOT NULL,
    [DlvryStartTime]         TIME (7) NOT NULL,
    [DlvryEndTime]           TIME (7) NOT NULL
);

