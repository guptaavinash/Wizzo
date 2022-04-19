CREATE TABLE [dbo].[tblIncentive_SlabRuleDetail] (
    [IncSlabRuleID]        INT          IDENTITY (1, 1) NOT NULL,
    [IncSlabID]            INT          NOT NULL,
    [MsrId]                INT          NOT NULL,
    [TimeGranualrityId]    INT          NOT NULL,
    [CalcSequence]         INT          NULL,
    [CutoffVal]            INT          NOT NULL,
    [UomId]                INT          NOT NULL,
    [PayoutAmount]         MONEY        NOT NULL,
    [DependentSlabRuleId]  INT          NULL,
    [DependentSlabRuleStr] VARCHAR (20) NULL,
    CONSTRAINT [PK_tblIncentive_SlabRuleDetail] PRIMARY KEY CLUSTERED ([IncSlabRuleID] ASC)
);

