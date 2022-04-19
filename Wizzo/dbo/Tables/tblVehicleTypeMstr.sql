CREATE TABLE [dbo].[tblVehicleTypeMstr] (
    [VehicleTypeID] INT           IDENTITY (1, 1) NOT NULL,
    [VehicleType]   VARCHAR (100) NOT NULL,
    CONSTRAINT [PK_tblVehicleTypeMstr] PRIMARY KEY CLUSTERED ([VehicleTypeID] ASC)
);

