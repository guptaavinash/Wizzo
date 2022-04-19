CREATE TABLE [dbo].[tblTargetMeasureCriteria] (
    [TgtMeasureCrtraID]   INT           IDENTITY (1, 1) NOT NULL,
    [TimePeriodNodeId]    INT           NULL,
    [TimePeriodNodeType]  INT           NULL,
    [TgtMeasureID]        INT           NOT NULL,
    [TgtMeasureName]      VARCHAR (200) NOT NULL,
    [IsStoreLevel]        BIT           NULL,
    [IsProductLevel]      BIT           NULL,
    [IsMeasureAggregated] BIT           NULL,
    [AggregatedLevel]     TINYINT       NULL,
    [IsPercentage]        BIT           NULL
);

