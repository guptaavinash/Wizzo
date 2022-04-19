CREATE TABLE [dbo].[tblSecMenuHierarchyRoles] (
    [ID]         INT          IDENTITY (1, 1) NOT NULL,
    [MnId]       SMALLINT     NULL,
    [RoleID]     TINYINT      NULL,
    [ManageType] VARCHAR (50) NULL,
    CONSTRAINT [PK_tblSecMenuHierarchyRoles] PRIMARY KEY CLUSTERED ([ID] ASC)
);

