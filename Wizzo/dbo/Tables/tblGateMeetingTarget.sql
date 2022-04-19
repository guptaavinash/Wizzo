CREATE TABLE [dbo].[tblGateMeetingTarget] (
    [PersonMeetingID]     INT             IDENTITY (1, 1) NOT NULL,
    [CovAreaNodeID]       INT             NULL,
    [CovAreaNodeType]     SMALLINT        NULL,
    [PersonNodeID]        INT             NULL,
    [PersonNodeType]      SMALLINT        NULL,
    [EntryPersonNodeID]   INT             NULL,
    [EntryPersonNodeType] SMALLINT        NULL,
    [DataDate]            DATE            NULL,
    [FileSetID]           INT             NULL,
    [TimestampIns]        SMALLDATETIME   NULL,
    [Dstrbn_Tgt]          INT             NULL,
    [Sales_Tgt]           NUMERIC (10, 4) NULL,
    CONSTRAINT [PK_tblGateMeetingTarget] PRIMARY KEY CLUSTERED ([PersonMeetingID] ASC)
);

