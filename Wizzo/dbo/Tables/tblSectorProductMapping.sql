CREATE TABLE [dbo].[tblSectorProductMapping] (
    [SectorPrdMapId] INT IDENTITY (1, 1) NOT NULL,
    [SectorId]       INT NOT NULL,
    [PrdNodeId]      INT NOT NULL,
    [PrdNodeType]    INT NOT NULL,
    CONSTRAINT [PK_tblSectorProductMapping] PRIMARY KEY CLUSTERED ([SectorPrdMapId] ASC)
);

