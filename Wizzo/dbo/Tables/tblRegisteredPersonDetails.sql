CREATE TABLE [dbo].[tblRegisteredPersonDetails] (
    [PersonNodeId]   INT           NULL,
    [PersonNodeType] INT           NULL,
    [FirstName]      VARCHAR (200) NULL,
    [LastName]       VARCHAR (200) NULL,
    [ContactNo]      VARCHAR (15)  NULL,
    [DOB]            DATE          NULL,
    [Gender]         VARCHAR (10)  NULL,
    [IsMarried]      TINYINT       NULL,
    [MarriageDate]   DATE          NULL,
    [Qualification]  VARCHAR (100) NULL,
    [EmailId]        VARCHAR (200) NULL,
    [BloodGroup]     VARCHAR (5)   NULL,
    [PhotoName]      VARCHAR (200) NULL,
    [SelfieName]     VARCHAR (200) NULL,
    [SignImgName]    VARCHAR (200) NULL,
    [TimeStampIns]   DATETIME      NULL,
    [TimeStampUpd]   DATETIME      NULL,
    [FileSetID]      INT           NULL,
    [DOJ]            DATE          NULL
);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'0:No, 1:yes', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblRegisteredPersonDetails', @level2type = N'COLUMN', @level2name = N'IsMarried';

