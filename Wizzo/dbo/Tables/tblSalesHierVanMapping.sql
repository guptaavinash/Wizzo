CREATE TABLE [dbo].[tblSalesHierVanMapping] (
    [SalesNodeID]   INT           NOT NULL,
    [SalesNodetype] SMALLINT      NOT NULL,
    [VanID]         INT           NOT NULL,
    [VanNodeType]   SMALLINT      NULL,
    [Fromdate]      DATE          NULL,
    [Todate]        DATE          NULL,
    [LoginIDIns]    INT           NULL,
    [TimestampIns]  SMALLDATETIME NULL,
    [LoginIDUpd]    INT           NULL,
    [TimestampUpd]  SMALLDATETIME NULL
);

