CREATE TYPE [dbo].[udt_OutletGTOutlet] AS TABLE (
    [NoOfFreezer] TINYINT  NULL,
    [IsSelfSrv]   TINYINT  NULL,
    [StoreSize]   INT      NULL,
    [IsACStore]   TINYINT  NULL,
    [ComClassID]  SMALLINT NULL,
    [TJUKClassID] SMALLINT NULL);

