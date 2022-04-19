CREATE TABLE [dbo].[tblPDARouteChangeApprovalDetail] (
    [RequestPersonNodeID]         INT           NOT NULL,
    [RequestPersonNodeType]       SMALLINT      NOT NULL,
    [RequestPDACode]              VARCHAR (100) NULL,
    [OldRouteNodeID]              INT           NULL,
    [OldRouteNodeType]            SMALLINT      NULL,
    [RequestRouteNodeID]          INT           NOT NULL,
    [RequestRouteNodeType]        SMALLINT      NOT NULL,
    [RequestDatetime]             SMALLDATETIME NOT NULL,
    [flgApprovedOrReject]         TINYINT       CONSTRAINT [DF_tblPDARouteChangeApprovalDetail_flgApprovedorreject] DEFAULT ((0)) NULL,
    [ApproverPersonNodeID]        INT           NULL,
    [ApproverPersonNodeType]      SMALLINT      NULL,
    [ApprovalDatetime]            SMALLDATETIME NULL,
    [OTPCode]                     VARCHAR (10)  NULL,
    [ReasonForRouteChangeComment] VARCHAR (500) NULL
);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'0=Approval Requested,1=Approved,2=Reject', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblPDARouteChangeApprovalDetail', @level2type = N'COLUMN', @level2name = N'flgApprovedOrReject';

