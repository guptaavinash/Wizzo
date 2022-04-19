CREATE TABLE [dbo].[tblCompanySalesStructureMgnrLvl4] (
    [NodeID]       INT           IDENTITY (1, 1) NOT NULL,
    [Code]         VARCHAR (100) NULL,
    [Descr]        VARCHAR (100) NULL,
    [NodeType]     INT           CONSTRAINT [DF__tblCompan__NodeT__10966653] DEFAULT ((105)) NOT NULL,
    [IsActive]     BIT           CONSTRAINT [DF__tblCompan__IsAct__118A8A8C] DEFAULT ((1)) NOT NULL,
    [FileSetIdIns] BIGINT        CONSTRAINT [DF__tblCompan__FileS__015422C3] DEFAULT ((0)) NOT NULL,
    [TimestampIns] DATETIME      CONSTRAINT [DF__tblCompan__Times__024846FC] DEFAULT (getdate()) NOT NULL,
    [FileSetIdUpd] BIGINT        NULL,
    [TimestampUpd] DATETIME      NULL,
    CONSTRAINT [PK_tblCompanySalesStructureMgnrLvl4] PRIMARY KEY CLUSTERED ([NodeID] ASC)
);

