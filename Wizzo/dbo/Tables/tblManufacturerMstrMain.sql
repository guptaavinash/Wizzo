CREATE TABLE [dbo].[tblManufacturerMstrMain] (
    [ManufacturerID]   INT            IDENTITY (10, 10) NOT NULL,
    [ManufacturerName] NVARCHAR (500) NULL,
    [NodeType]         INT            DEFAULT ((40)) NOT NULL,
    [ManufacturerCode] VARCHAR (50)   NULL,
    CONSTRAINT [PK_tblManufacturerMstrMain] PRIMARY KEY CLUSTERED ([ManufacturerID] ASC)
);

