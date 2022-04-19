CREATE TABLE [dbo].[tblExtractMaster] (
    [ExtractId]    INT           IDENTITY (1, 1) NOT NULL,
    [ExtractName]  VARCHAR (150) NOT NULL,
    [LastId]       VARCHAR (50)  NULL,
    [TimeStampUpd] DATETIME      NULL
);

