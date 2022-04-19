CREATE TYPE [dbo].[udt_ProductFeedbackDetail] AS TABLE (
    [MainFeedbackType]     INT           NULL,
    [Comments]             VARCHAR (500) NULL,
    [MainFeedbackDate]     DATE          NULL,
    [MainFeedbackOptionID] VARCHAR (20)  NULL);

