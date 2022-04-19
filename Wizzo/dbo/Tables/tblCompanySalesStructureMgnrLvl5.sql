CREATE TABLE [dbo].[tblCompanySalesStructureMgnrLvl5] (
    [NodeID]       INT           IDENTITY (1, 1) NOT NULL,
    [Code]         VARCHAR (100) NULL,
    [Descr]        VARCHAR (100) NULL,
    [NodeType]     INT           CONSTRAINT [DF__tblCompan__NodeT__1466F737] DEFAULT ((110)) NOT NULL,
    [IsActive]     BIT           CONSTRAINT [DF__tblCompan__IsAct__155B1B70] DEFAULT ((1)) NOT NULL,
    [FileSetIdIns] BIGINT        CONSTRAINT [DF__tblCompan__FileS__08F5448B] DEFAULT ((0)) NOT NULL,
    [TimestampIns] DATETIME      CONSTRAINT [DF__tblCompan__Times__09E968C4] DEFAULT (getdate()) NOT NULL,
    [FileSetIdUpd] BIGINT        NULL,
    [TimestampUpd] DATETIME      NULL,
    CONSTRAINT [PK_tblCompanySalesStructureMgnrLvl5] PRIMARY KEY CLUSTERED ([NodeID] ASC)
);

