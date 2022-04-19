CREATE TABLE [dbo].[tblPMstNodeTypes] (
    [NodeType]            SMALLINT       NOT NULL,
    [NodeTypeDesc]        NVARCHAR (100) NOT NULL,
    [Hierarchytable]      NVARCHAR (50)  NULL,
    [DetTable]            NVARCHAR (50)  NULL,
    [HierTypeID]          TINYINT        NULL,
    [Level]               TINYINT        NULL,
    [FrameID]             TINYINT        NULL,
    [PersonType]          INT            NULL,
    [FlgBusinessType]     INT            NULL,
    [Dettablenamedcolumn] VARCHAR (50)   NULL,
    [Deltableidcolumn]    VARCHAR (50)   NULL
);

