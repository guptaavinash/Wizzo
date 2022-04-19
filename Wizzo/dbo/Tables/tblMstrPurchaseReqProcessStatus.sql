CREATE TABLE [dbo].[tblMstrPurchaseReqProcessStatus] (
    [POProcessStatusId] TINYINT       NOT NULL,
    [POProcessStatus]   VARCHAR (100) NOT NULL,
    [ASMStatus]         VARCHAR (100) NULL,
    CONSTRAINT [PK_tblMstrPurchaseReqProcessStatus] PRIMARY KEY CLUSTERED ([POProcessStatusId] ASC)
);

