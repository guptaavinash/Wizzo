CREATE TYPE [dbo].[OtherChargesDetail] AS TABLE (
    [OthChrgsAmt]    [dbo].[Amount] NOT NULL,
    [OthChrgsReason] VARCHAR (100)  NULL);

