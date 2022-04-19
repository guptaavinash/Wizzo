CREATE TABLE [dbo].[tblDayEndDetails] (
    [IMEINo]        VARCHAR (50)     NULL,
    [StartTime]     SMALLDATETIME    NULL,
    [Endtime]       SMALLDATETIME    NULL,
    [DayEndFlag]    TINYINT          NULL,
    [ForDate]       DATE             NULL,
    [AppVersionID]  VARCHAR (20)     NULL,
    [BatteryStatus] INT              NULL,
    [PersonId]      INT              NULL,
    [LatCode]       NUMERIC (27, 24) NULL,
    [LongCode]      NUMERIC (27, 24) NULL,
    [Address]       VARCHAR (500)    NULL,
    [PinCode]       BIGINT           NULL,
    [City]          VARCHAR (100)    NULL,
    [State]         VARCHAR (100)    NULL
);

