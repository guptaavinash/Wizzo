CREATE TYPE [dbo].[OrderReturnSteps] AS TABLE (
    [OrderReturnStepsId]     INT            NULL,
    [OrderReturnDetailID]    INT            NOT NULL,
    [RowNo]                  TINYINT        NULL,
    [OrderReturnActionId]    TINYINT        NOT NULL,
    [Qty]                    INT            NOT NULL,
    [ReplacementString]      VARCHAR (1000) NULL,
    [PrdId]                  INT            NULL,
    [ReturnAction]           VARCHAR (1000) NULL,
    [Resolution]             VARCHAR (1000) NULL,
    [ResolutionWhen]         VARCHAR (1000) NULL,
    [IsApproved]             TINYINT        NULL,
    [OrderReturnSubActionId] TINYINT        NULL,
    [Reason]                 VARCHAR (1000) NULL);

