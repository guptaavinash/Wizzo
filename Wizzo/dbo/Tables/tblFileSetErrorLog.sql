CREATE TABLE [dbo].[tblFileSetErrorLog] (
    [FileSetId]      INT            NOT NULL,
    [ErrorNumber]    INT            NULL,
    [ErrorSeverity]  INT            NULL,
    [ErrorState]     INT            NULL,
    [ErrorProcedure] VARCHAR (150)  NULL,
    [ErrorLine]      INT            NULL,
    [ErrorMessage]   NVARCHAR (MAX) NULL,
    [TimeStamps]     DATETIME       DEFAULT (getdate()) NULL,
    [FileSetName]    VARCHAR (150)  NULL
);

