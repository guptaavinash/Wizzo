CREATE TABLE [dbo].[tblRouteCoverageStoreMapping] (
    [RouteID]       INT      NOT NULL,
    [StoreID]       INT      NOT NULL,
    [FromDate]      DATE     CONSTRAINT [DF__tblRouteC__FromD__157B1701] DEFAULT (getdate()) NOT NULL,
    [ToDate]        DATE     NOT NULL,
    [LoginIDIns]    INT      NOT NULL,
    [TimestampIns]  DATETIME CONSTRAINT [DF__tblRouteC__Times__166F3B3A] DEFAULT (getdate()) NOT NULL,
    [LoginIDUpd]    INT      NULL,
    [TimestampUpd]  DATETIME NULL,
    [RouteNodeType] INT      NOT NULL,
    [DisplaySeq]    INT      NULL
);


GO
CREATE NONCLUSTERED INDEX [IX_tblRouteCoverageStoreMapping]
    ON [dbo].[tblRouteCoverageStoreMapping]([RouteID] ASC, [RouteNodeType] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_tblRouteCoverageStoreMapping_1]
    ON [dbo].[tblRouteCoverageStoreMapping]([StoreID] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_tblRouteCoverageStoreMapping_2]
    ON [dbo].[tblRouteCoverageStoreMapping]([FromDate] DESC, [ToDate] DESC);

