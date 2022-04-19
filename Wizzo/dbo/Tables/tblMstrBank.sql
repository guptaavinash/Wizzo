CREATE TABLE [dbo].[tblMstrBank] (
    [BankId]       INT           IDENTITY (1, 1) NOT NULL,
    [BankName]     VARCHAR (100) NULL,
    [LoginIdIns]   INT           NULL,
    [TimeStampIns] DATETIME      NULL,
    [LoginIdUpd]   INT           NULL,
    [TimeStampUpd] DATETIME      NULL
);

