CREATE TYPE [dbo].[udt_ProductFeedbackDetail_Product] AS TABLE (
    [PrdNodeId]    INT           NULL,
    [PrdNodeType]  INT           NULL,
    [FBAnsID]      VARCHAR (50)  NULL,
    [feedbackDate] DATE          NULL,
    [Comments]     VARCHAR (500) NULL);

