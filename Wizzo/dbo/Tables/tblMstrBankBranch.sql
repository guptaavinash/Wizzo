CREATE TABLE [dbo].[tblMstrBankBranch] (
    [BankBranchId]      INT           IDENTITY (1, 1) NOT NULL,
    [BankId]            INT           NOT NULL,
    [BankBranchName]    VARCHAR (100) NOT NULL,
    [IFSCCode]          VARCHAR (15)  NULL,
    [MICRCode]          VARCHAR (15)  NULL,
    [BankBranchAddress] VARCHAR (250) NULL,
    [CityId]            INT           NULL,
    [StateId]           INT           NULL,
    [CountryId]         INT           NULL,
    [flgActive]         BIT           NOT NULL,
    [LoginIdIns]        INT           NOT NULL,
    [TimeStampIns]      DATETIME      NOT NULL,
    [LoginIdUpd]        INT           NULL,
    [TimeStampUpd]      DATETIME      NULL
);

