CREATE TABLE [dbo].[tblClosedStoreImageDetails] (
    [ClosedStoreVisitImageID] INT           IDENTITY (1, 1) NOT NULL,
    [ClosedStoreVisitID]      INT           NOT NULL,
    [PhotoName]               VARCHAR (200) NOT NULL,
    [ClickedDateTime]         DATETIME      NOT NULL,
    CONSTRAINT [PK_tblClosedStoreImageDetails] PRIMARY KEY CLUSTERED ([ClosedStoreVisitImageID] ASC)
);

