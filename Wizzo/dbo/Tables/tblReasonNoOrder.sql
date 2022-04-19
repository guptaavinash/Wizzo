CREATE TABLE [dbo].[tblReasonNoOrder] (
    [NoOrderReasonID] INT           IDENTITY (1, 1) NOT NULL,
    [NoOrderReason]   VARCHAR (200) NOT NULL,
    [flgActive]       TINYINT       CONSTRAINT [DF_tblReasonNoOrder_flgActive] DEFAULT ((1)) NOT NULL
);

