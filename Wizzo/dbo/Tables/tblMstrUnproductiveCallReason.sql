CREATE TABLE [dbo].[tblMstrUnproductiveCallReason] (
    [UPCallReasonId] TINYINT       IDENTITY (1, 1) NOT NULL,
    [UPCallReason]   VARCHAR (100) NOT NULL,
    CONSTRAINT [PK_tblMstrUnproductiveCallReason] PRIMARY KEY CLUSTERED ([UPCallReasonId] ASC)
);

