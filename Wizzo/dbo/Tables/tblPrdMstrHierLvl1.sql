CREATE TABLE [dbo].[tblPrdMstrHierLvl1] (
    [NodeID]       INT           IDENTITY (1, 1) NOT NULL,
    [Code]         VARCHAR (100) NOT NULL,
    [Descr]        VARCHAR (100) NOT NULL,
    [NodeType]     INT           DEFAULT ((10)) NOT NULL,
    [FileSetIdIns] BIGINT        NOT NULL,
    [TimestampIns] DATETIME      DEFAULT (getdate()) NOT NULL,
    [FileSetIdUpd] INT           NULL,
    [TimestampUpd] DATETIME      NULL,
    [IsActive]     TINYINT       DEFAULT ((1)) NOT NULL,
    [flgSeq]       TINYINT       NULL,
    PRIMARY KEY CLUSTERED ([NodeID] ASC)
);

