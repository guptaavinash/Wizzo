CREATE TYPE [dbo].[udt_OutletSTRestaurant] AS TABLE (
    [CountID]         INT      NULL,
    [OutRestTypeID]   INT      NULL,
    [IsAlcoholServed] TINYINT  NULL,
    [NoOfCovers]      SMALLINT NULL,
    [IsBanquet]       TINYINT  NULL,
    [NoOfBanquet]     SMALLINT NULL,
    [CapBanquet1]     SMALLINT NULL,
    [CapBanquet2]     SMALLINT NULL,
    [CapBanquet3]     SMALLINT NULL,
    [CapBanquet4]     SMALLINT NULL,
    [CapBanquet5]     SMALLINT NULL,
    [IsNonVeg]        TINYINT  NULL,
    [AvgCostPlate]    INT      NULL);

