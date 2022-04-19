CREATE TABLE [dbo].[tblRouteCoverage] (
    [RouteCoverageID] INT      IDENTITY (1, 1) NOT NULL,
    [RouteID]         INT      NOT NULL,
    [CovFrqID]        INT      NOT NULL,
    [Weekday]         INT      NOT NULL,
    [FromDate]        DATE     DEFAULT (getdate()) NULL,
    [ToDate]          DATE     NULL,
    [flgPrimary]      TINYINT  CONSTRAINT [DF__tblSHRout__flgPr__5CA1C101] DEFAULT ((1)) NULL,
    [LoginIDIns]      INT      NOT NULL,
    [TimestampIns]    DATETIME DEFAULT (getdate()) NULL,
    [LoginIDUpd]      INT      NULL,
    [TimestampUpd]    DATETIME NULL,
    [NodeType]        TINYINT  CONSTRAINT [DF__tblSHRout__NodeT__3C1FE2D6] DEFAULT ((140)) NULL,
    [WeekID]          INT      NULL
);

