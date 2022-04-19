CREATE TABLE [dbo].[tblCompanySalesStructureMgnrLvl0] (
    [NodeID]       INT           IDENTITY (1, 1) NOT NULL,
    [Code]         VARCHAR (50)  NULL,
    [Descr]        VARCHAR (100) NULL,
    [NodeType]     INT           CONSTRAINT [DF__tblCompan__NodeT__0ADD8CFD] DEFAULT ((95)) NOT NULL,
    [IsActive]     BIT           CONSTRAINT [DF__tblCompan__IsAct__0BD1B136] DEFAULT ((1)) NOT NULL,
    [FileSetIdIns] BIGINT        CONSTRAINT [DF__tblCompan__FileS__75E27017] DEFAULT ((0)) NOT NULL,
    [TimestampIns] DATETIME      CONSTRAINT [DF__tblCompan__Times__76D69450] DEFAULT (getdate()) NOT NULL,
    [FileSetIdUpd] BIGINT        NULL,
    [TimestampUpd] DATETIME      NULL,
    CONSTRAINT [PK_tblCompanySalesStructureMgnrLvl1] PRIMARY KEY CLUSTERED ([NodeID] ASC)
);

