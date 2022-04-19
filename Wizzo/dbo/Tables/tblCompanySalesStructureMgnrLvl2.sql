CREATE TABLE [dbo].[tblCompanySalesStructureMgnrLvl2] (
    [NodeID]       INT           IDENTITY (1, 1) NOT NULL,
    [Code]         VARCHAR (50)  NULL,
    [Descr]        VARCHAR (100) NULL,
    [NodeType]     INT           CONSTRAINT [DF__tblCompan__NodeT__0EAE1DE1] DEFAULT ((103)) NOT NULL,
    [IsActive]     BIT           CONSTRAINT [DF__tblCompan__IsAct__0FA2421A] DEFAULT ((1)) NOT NULL,
    [FileSetIdIns] BIGINT        CONSTRAINT [DF__tblCompan__FileS__7D8391DF] DEFAULT ((0)) NOT NULL,
    [TimestampIns] DATETIME      CONSTRAINT [DF__tblCompan__Times__7E77B618] DEFAULT (getdate()) NOT NULL,
    [FileSetIdUpd] BIGINT        NULL,
    [TimestampUpd] DATETIME      NULL,
    CONSTRAINT [PK_tblCompanySalesStructureMgnrLvl3] PRIMARY KEY CLUSTERED ([NodeID] ASC)
);

