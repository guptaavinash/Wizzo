CREATE TYPE [dbo].[Attendance] AS TABLE (
    [SONodeId]      INT     NOT NULL,
    [SONodeType]    INT     NOT NULL,
    [RouteNodeId]   INT     NOT NULL,
    [RouteNodeType] INT     NOT NULL,
    [VisitDate]     DATE    NOT NULL,
    [flgAbsent]     TINYINT NOT NULL);

