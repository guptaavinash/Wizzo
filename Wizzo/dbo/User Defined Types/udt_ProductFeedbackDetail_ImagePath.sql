CREATE TYPE [dbo].[udt_ProductFeedbackDetail_ImagePath] AS TABLE (
    [PrdId]         INT            NULL,
    [PrdNodeType]   INT            NULL,
    [FBAnsID]       INT            NULL,
    [Comments]      VARCHAR (500)  NULL,
    [MediaPath]     VARCHAR (1000) NULL,
    [flgMediaType]  TINYINT        NULL,
    [flgOverAllLvl] TINYINT        NULL);

