CREATE TABLE [dbo].[tblLanguageMaster] (
    [LngID]      INT           IDENTITY (1, 1) NOT NULL,
    [Language]   VARCHAR (200) NOT NULL,
    [NodeType]   SMALLINT      NOT NULL,
    [IsPriority] TINYINT       CONSTRAINT [DF_tblLanguageMaster_IsPriority] DEFAULT ((0)) NOT NULL
);

