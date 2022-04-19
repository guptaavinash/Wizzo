CREATE TABLE [dbo].[tblLocationMaster] (
    [LocalAreaNodeID] INT           IDENTITY (1, 1) NOT NULL,
    [LocalArea]       VARCHAR (200) NOT NULL,
    [NodeType]        SMALLINT      CONSTRAINT [DF_tblLocationMaster_LocalAreaNodeType] DEFAULT ((740)) NOT NULL,
    [CityID]          INT           NULL
);

