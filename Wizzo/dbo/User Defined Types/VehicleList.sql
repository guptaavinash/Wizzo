CREATE TYPE [dbo].[VehicleList] AS TABLE (
    [DlvryRouteId]           INT          NULL,
    [VehicleId]              INT          NULL,
    [DriverNodeid]           INT          NULL,
    [DriverNodeType]         TINYINT      NULL,
    [DeliveryBoyNodeid]      INT          NULL,
    [DeliveryBoyNodeType]    TINYINT      NULL,
    [flgSetDefaultForMaster] BIT          NULL,
    [VehicleNumber]          VARCHAR (20) NULL,
    [DriverName]             VARCHAR (50) NULL,
    [DeliveryBoy]            VARCHAR (50) NULL,
    [flgVehicleType]         TINYINT      NULL);

