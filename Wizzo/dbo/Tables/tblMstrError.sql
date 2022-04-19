CREATE TABLE [dbo].[tblMstrError] (
    [ErrorId]    INT           IDENTITY (1, 1) NOT NULL,
    [ErrorDescr] VARCHAR (100) NOT NULL,
    CONSTRAINT [PK_tblMstrError] PRIMARY KEY CLUSTERED ([ErrorId] ASC)
);

