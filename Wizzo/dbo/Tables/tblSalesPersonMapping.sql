CREATE TABLE [dbo].[tblSalesPersonMapping] (
    [PersonNodeID]        INT      NOT NULL,
    [PersonType]          TINYINT  NOT NULL,
    [NodeID]              INT      NOT NULL,
    [NodeType]            TINYINT  NULL,
    [FromDate]            DATETIME CONSTRAINT [DF_tblSalesPersonMapping_FromDate] DEFAULT (getdate()) NOT NULL,
    [ToDate]              DATETIME CONSTRAINT [DF_tblSalesPersonMapping_ToDate] DEFAULT ('31-dec-2049') NOT NULL,
    [FileSetIDIns]        BIGINT   NOT NULL,
    [LoginIDIns]          INT      NULL,
    [TimestampIns]        DATETIME CONSTRAINT [DF_tblSalesPersonMapping_TimestampIns] DEFAULT (getdate()) NOT NULL,
    [FileSetIDUpd]        BIGINT   NULL,
    [LoginIDUpd]          INT      NULL,
    [TimestampUpd]        DATETIME NULL,
    [flgOtherLevelPerson] TINYINT  CONSTRAINT [DF_tblSalesPersonMapping_flgOtherLevelPerson] DEFAULT ((0)) NULL
);


GO
CREATE NONCLUSTERED INDEX [IX_tblSalesPersonMapping]
    ON [dbo].[tblSalesPersonMapping]([PersonNodeID] ASC, [PersonType] ASC, [FromDate] ASC, [ToDate] DESC);

