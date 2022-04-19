CREATE TABLE [dbo].[tblSecMenuHierarchy] (
    [MnID]            SMALLINT       IDENTITY (1, 1) NOT NULL,
    [MenuDescription] NVARCHAR (350) NULL,
    [MnParentID]      SMALLINT       NULL,
    [SSClass]         VARCHAR (50)   NULL,
    [ImageName]       VARCHAR (50)   NULL,
    [OrderNum]        SMALLINT       NULL,
    [flgMenuActive]   TINYINT        NULL,
    CONSTRAINT [PK_tblSecMenuHierarchy] PRIMARY KEY CLUSTERED ([MnID] ASC)
);

