CREATE TABLE [dbo].[tblPrdInactiveSBFList] (
    [SiteSBFPrdInactiveId] INT      IDENTITY (1, 1) NOT NULL,
    [SBFNodeId]            INT      NOT NULL,
    [SBFNodeType]          INT      NOT NULL,
    [SiteNodeId]           INT      NOT NULL,
    [SiteNodeType]         INT      NOT NULL,
    [FromDate]             DATE     CONSTRAINT [DF_tblPrdInactiveSBFList2_FromDate] DEFAULT (getdate()) NOT NULL,
    [ToDate]               DATE     CONSTRAINT [DF_tblPrdInactiveSBFList2_ToDate] DEFAULT ('2050-12-31') NOT NULL,
    [FilesetidIns]         BIGINT   NULL,
    [TimeStampIns]         DATETIME NULL
);

