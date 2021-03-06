CREATE TYPE [dbo].[udt_OutletHotel] AS TABLE (
    [NoOfRes]          INT      NULL,
    [IsResAvailable]   TINYINT  NULL,
    [NoOfRooms]        INT      NULL,
    [AvgRoomRate]      INT      NULL,
    [Stars]            SMALLINT NULL,
    [IsMinibar]        TINYINT  NULL,
    [IsCoffeshop]      TINYINT  NULL,
    [CoffeStarttime]   TIME (7) NULL,
    [CoffeEndTime]     TIME (7) NULL,
    [IsBar]            TINYINT  NULL,
    [BarStarttime]     TIME (7) NULL,
    [BarEndTime]       TIME (7) NULL,
    [IsGourmetStoreAv] TINYINT  NULL,
    [IsBanquetSpc]     TINYINT  NULL,
    [NoOfBanquet]      SMALLINT NULL,
    [CapBanquet1]      SMALLINT NULL,
    [CapBanquet2]      SMALLINT NULL,
    [CapBanquet3]      SMALLINT NULL,
    [CapBanquet4]      SMALLINT NULL,
    [CapBanquet5]      SMALLINT NULL);

