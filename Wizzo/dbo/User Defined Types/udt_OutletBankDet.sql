CREATE TYPE [dbo].[udt_OutletBankDet] AS TABLE (
    [Bankname]      VARCHAR (500)  NULL,
    [BranchName]    VARCHAR (2000) NULL,
    [IFSCCode]      VARCHAR (50)   NULL,
    [MICRCode]      VARCHAR (50)   NULL,
    [NEFT/RTGSCode] VARCHAR (50)   NULL,
    [AccountNo]     VARCHAR (15)   NULL,
    [AccountName]   VARCHAR (500)  NULL);

