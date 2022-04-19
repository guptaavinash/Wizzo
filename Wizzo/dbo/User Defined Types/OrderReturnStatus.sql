CREATE TYPE [dbo].[OrderReturnStatus] AS TABLE (
    [OrderReturnDetailID]     INT     NOT NULL,
    [ActionDate]              DATE    NOT NULL,
    [ReturnActionStatusId]    TINYINT NOT NULL,
    [UOMID]                   INT     NOT NULL,
    [Qty]                     INT     NOT NULL,
    [OrderReturnStepsId]      INT     NOT NULL,
    [DlvryPlanReturnDetailId] INT     NOT NULL,
    [StkRetDetailId]          INT     NOT NULL);

