CREATE TABLE [dbo].[tblPDARouteChangeApprovalDetail_History] (
    [RequestPersonNodeID]         INT           NOT NULL,
    [RequestPersonNodeType]       SMALLINT      NOT NULL,
    [RequestPDACode]              VARCHAR (100) NULL,
    [OldRouteNodeID]              INT           NULL,
    [OldRouteNodeType]            SMALLINT      NULL,
    [RequestRouteNodeID]          INT           NOT NULL,
    [RequestRouteNodeType]        SMALLINT      NOT NULL,
    [RequestDatetime]             SMALLDATETIME NOT NULL,
    [flgApprovedOrReject]         TINYINT       NULL,
    [ApproverPersonNodeID]        INT           NULL,
    [ApproverPersonNodeType]      SMALLINT      NULL,
    [ApprovalDatetime]            SMALLDATETIME NULL,
    [OTPCode]                     VARCHAR (10)  NULL,
    [ReasonForRouteChangeComment] VARCHAR (500) NULL
);

