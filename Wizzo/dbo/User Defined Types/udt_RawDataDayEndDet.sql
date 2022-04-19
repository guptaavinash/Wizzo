CREATE TYPE [dbo].[udt_RawDataDayEndDet] AS TABLE (
    [IMEINo]        NVARCHAR (500) NULL,
    [StartTime]     NVARCHAR (500) NULL,
    [EndTime]       NVARCHAR (500) NULL,
    [DayEndFlag]    NVARCHAR (500) NULL,
    [ForDate]       NVARCHAR (500) NULL,
    [AppVersionID]  NVARCHAR (500) NULL,
    [BatteryStatus] NVARCHAR (500) NULL,
    [LatCode]       NVARCHAR (500) NULL,
    [LongCode]      NVARCHAR (500) NULL,
    [Address]       NVARCHAR (500) NULL,
    [PinCode]       NVARCHAR (500) NULL,
    [City]          NVARCHAR (500) NULL,
    [State]         NVARCHAR (500) NULL);

