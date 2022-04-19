CREATE TABLE [dbo].[tblPurchaseReqLogDetail] (
    [PurchReqLogId] INT      IDENTITY (1, 1) NOT NULL,
    [PurchReqId]    INT      NOT NULL,
    [POCategoryId]  INT      NULL,
    [Statusid]      TINYINT  NOT NULL,
    [LoginId]       INT      NULL,
    [TimeStamps]    DATETIME NULL,
    CONSTRAINT [PK_tblPurchaseReqLogDetail] PRIMARY KEY CLUSTERED ([PurchReqLogId] ASC)
);

