CREATE TABLE [dbo].[tblSecUserRoleBasedPermissions] (
    [RoleSecID]  INT     NOT NULL,
    [UserId]     INT     NULL,
    [RoleID]     TINYINT NULL,
    [NodeID]     INT     NULL,
    [NodeType]   TINYINT NULL,
    [SecType]    TINYINT NULL,
    [HierTypeId] TINYINT NULL
);

