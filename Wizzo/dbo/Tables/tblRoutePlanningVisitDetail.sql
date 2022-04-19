CREATE TABLE [dbo].[tblRoutePlanningVisitDetail] (
    [RouteNodeId]     INT      NOT NULL,
    [RouteNodetype]   INT      NOT NULL,
    [VisitDate]       DATE     NOT NULL,
    [DSENodeId]       INT      NOT NULL,
    [DSENodeType]     INT      NOT NULL,
    [FileSetId]       INT      NOT NULL,
    [CovAreaNodeID]   INT      NOT NULL,
    [CovAreaNodeType] SMALLINT NOT NULL,
    [Visitmonthyear]  AS       (datepart(year,[visitdate])*(100)+datepart(month,[visitdate]))
);


GO
CREATE NONCLUSTERED INDEX [IX_tblRoutePlanningVisitDetail]
    ON [dbo].[tblRoutePlanningVisitDetail]([RouteNodeId] ASC, [RouteNodetype] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_tblRoutePlanningVisitDetail_1]
    ON [dbo].[tblRoutePlanningVisitDetail]([CovAreaNodeID] ASC, [CovAreaNodeType] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_tblRoutePlanningVisitDetail_2]
    ON [dbo].[tblRoutePlanningVisitDetail]([DSENodeId] ASC, [DSENodeType] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_tblRoutePlanningVisitDetail_3]
    ON [dbo].[tblRoutePlanningVisitDetail]([Visitmonthyear] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_tblRoutePlanningVisitDetail_4]
    ON [dbo].[tblRoutePlanningVisitDetail]([VisitDate] DESC);

