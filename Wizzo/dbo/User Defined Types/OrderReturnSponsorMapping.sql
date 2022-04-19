CREATE TYPE [dbo].[OrderReturnSponsorMapping] AS TABLE (
    [OrderReturnDetailId] INT            NOT NULL,
    [SponsorId]           INT            NOT NULL,
    [Percentage]          NUMERIC (5, 2) NOT NULL,
    [TotalAmount]         [dbo].[Amount] NULL);

