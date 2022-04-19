CREATE TABLE [dbo].[tblPayoutDetail] (
    [IncSlabRuleId]        INT          NULL,
    [IncSlabID]            INT          NULL,
    [PersonNodeId]         INT          NULL,
    [PersonNodeType]       INT          NULL,
    [flgattendenceRule]    TINYINT      NULL,
    [TimeGranualrityId]    INT          NULL,
    [TimeGranualrityValue] VARCHAR (50) NULL,
    [SlabSeq]              INT          NULL,
    [AchVal]               FLOAT (53)   NULL,
    [CutOffVal]            FLOAT (53)   NULL,
    [flgPayoutAcheived]    TINYINT      CONSTRAINT [DF_tblPayoutDetail_flgPayoutAcheived] DEFAULT ((0)) NULL,
    [PayoutValue]          MONEY        NULL
);

