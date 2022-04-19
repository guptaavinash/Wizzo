CREATE TYPE [dbo].[OrderDeliveryTime] AS TABLE (
    [DlvryTimeType]  TINYINT  NOT NULL,
    [DlvryStartTime] TIME (7) NOT NULL,
    [DlvryEndTime]   TIME (7) NOT NULL);

