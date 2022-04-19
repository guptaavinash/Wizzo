CREATE TABLE [dbo].[tblTeleReasonSearchCriteriaList] (
    [TeleReasonSearchMapId] INT           IDENTITY (1, 1) NOT NULL,
    [TeleReasonId]          INT           NOT NULL,
    [SearchString]          VARCHAR (500) NULL,
    CONSTRAINT [PK_tblTeleReasonSearchCriteriaList] PRIMARY KEY CLUSTERED ([TeleReasonSearchMapId] ASC)
);

