CREATE TABLE [dbo].[tblCompanySalesStructureMgnrLvl1] (
    [NodeID]       INT           IDENTITY (1, 1) NOT NULL,
    [Code]         VARCHAR (50)  NULL,
    [Descr]        VARCHAR (100) NULL,
    [NodeType]     INT           CONSTRAINT [DF__tblCompan__NodeT__0CC5D56F] DEFAULT ((100)) NOT NULL,
    [IsActive]     BIT           CONSTRAINT [DF__tblCompan__IsAct__0DB9F9A8] DEFAULT ((1)) NOT NULL,
    [FileSetIdIns] BIGINT        CONSTRAINT [DF__tblCompan__FileS__79B300FB] DEFAULT ((0)) NOT NULL,
    [TimestampIns] DATETIME      CONSTRAINT [DF__tblCompan__Times__7AA72534] DEFAULT (getdate()) NOT NULL,
    [FileSetIdUpd] BIGINT        NULL,
    [TimestampUpd] DATETIME      NULL,
    CONSTRAINT [PK_tblCompanySalesStructureMgnrLvl2] PRIMARY KEY CLUSTERED ([NodeID] ASC)
);

