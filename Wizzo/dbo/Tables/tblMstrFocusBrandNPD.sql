CREATE TABLE [dbo].[tblMstrFocusBrandNPD] (
    [FBNPDMapId]    INT     IDENTITY (1, 1) NOT NULL,
    [SalesNodeId]   INT     NOT NULL,
    [SalesNodeType] INT     NOT NULL,
    [PrdNodeId]     INT     NOT NULL,
    [PrdNodeType]   INT     NOT NULL,
    [flgFB]         TINYINT CONSTRAINT [DF_tblMstrFocusBrandNPD_flgFB] DEFAULT ((0)) NOT NULL,
    [flgNPD]        TINYINT CONSTRAINT [DF_tblMstrFocusBrandNPD_flgNPD] DEFAULT ((0)) NOT NULL,
    CONSTRAINT [PK_tblMstrFocusBrandNPD] PRIMARY KEY CLUSTERED ([FBNPDMapId] ASC)
);

