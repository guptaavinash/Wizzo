CREATE TYPE [dbo].[udt_OutletBakery] AS TABLE (
    [flgServing]          TINYINT    NULL,
    [NoOfCovers]          SMALLINT   NULL,
    [OutBakTypeID]        INT        NULL,
    [IsSnackFood]         TINYINT    NULL,
    [IsManufacturingUnit] TINYINT    NULL,
    [EstTurnOver]         FLOAT (53) NULL,
    [AvgCostPerMeal]      INT        NULL);

