CREATE TYPE [dbo].[OrderDetail] AS TABLE (
    [PrdNodeID]               INT              NULL,
    [PrdNodeType]             INT              NULL,
    [OrderQty]                INT              NULL,
    [FreeQty]                 INT              NOT NULL,
    [SalesUnitId]             INT              NULL,
    [ProductPrice]            NUMERIC (18, 10) NOT NULL,
    [LineOrderValue]          NUMERIC (18, 2)  NOT NULL,
    [DiscValue]               NUMERIC (18, 2)  NULL,
    [LineOrderValueAfterDisc] NUMERIC (18, 2)  NULL,
    [NetValue]                NUMERIC (18, 2)  NULL,
    [InvLevelDisc]            NUMERIC (18, 2)  NULL,
    [flgSBDGap]               TINYINT          NULL,
    [flgFB]                   TINYINT          NULL,
    [flgInitiative]           TINYINT          NULL,
    [SBDGroupid]              INT              NULL,
    [flgSBD]                  TINYINT          NULL,
    [FBId]                    INT              NULL);

