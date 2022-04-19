CREATE TABLE [dbo].[tblFinancialYear] (
    [FYID]        INT           IDENTITY (15, 1) NOT NULL,
    [FYStartDate] SMALLDATETIME NULL,
    [FYEndDate]   SMALLDATETIME NULL,
    [Fyear]       VARCHAR (50)  NULL,
    [YearSuffix]  VARCHAR (5)   NULL,
    CONSTRAINT [PK_tblFinancialYear] PRIMARY KEY CLUSTERED ([FYID] ASC)
);

