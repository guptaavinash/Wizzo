CREATE TABLE [dbo].[tblSecMapUserRoles] (
    [UserRoleMapID] INT IDENTITY (1, 1) NOT NULL,
    [UserID]        INT NOT NULL,
    [RoleId]        INT NOT NULL,
    [UserNodeId]    INT NULL,
    [UserNodeType]  INT NULL
);

