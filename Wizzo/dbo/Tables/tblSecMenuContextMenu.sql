CREATE TABLE [dbo].[tblSecMenuContextMenu] (
    [RowID]                 INT           IDENTITY (1, 1) NOT NULL,
    [NodeType]              INT           NOT NULL,
    [NodeTypeUnder]         SMALLINT      NOT NULL,
    [HierTypeID]            TINYINT       NOT NULL,
    [frmid]                 TINYINT       NULL,
    [Descr]                 VARCHAR (50)  NULL,
    [UpperLevelNameForEdit] VARCHAR (200) NULL,
    [flgBusinessType]       INT           NULL,
    [NodeIDBusinessType]    INT           NULL,
    [flgMap]                TINYINT       NULL,
    [flgChannel]            TINYINT       NULL,
    [flgPerson]             TINYINT       NULL,
    [flgRoute]              TINYINT       NULL,
    [flgMapType]            TINYINT       NULL,
    [flgCoverageArea]       TINYINT       NULL,
    [flgDistributor]        TINYINT       NULL,
    [flgMapDistributor]     TINYINT       NULL,
    [flgMapBrands]          TINYINT       CONSTRAINT [DF_tblSecMenuContextMenu_flgMapBrands] DEFAULT ((0)) NULL
);

