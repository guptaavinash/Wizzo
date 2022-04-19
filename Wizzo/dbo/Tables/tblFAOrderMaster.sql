CREATE TABLE [dbo].[tblFAOrderMaster] (
    [FAOrdId]       INT             IDENTITY (1, 1) NOT NULL,
    [FAOrderNo]     VARCHAR (50)    NOT NULL,
    [FAOrderDate]   DATE            NOT NULL,
    [StoreId]       INT             NOT NULL,
    [NetOrderValue] NUMERIC (18, 2) NOT NULL,
    [TimeStampIns]  DATETIME        NULL,
    CONSTRAINT [PK_tblFAOrderMaster] PRIMARY KEY CLUSTERED ([FAOrdId] ASC)
);

