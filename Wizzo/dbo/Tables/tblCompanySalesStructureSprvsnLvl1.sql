CREATE TABLE [dbo].[tblCompanySalesStructureSprvsnLvl1] (
    [NodeID]       INT           IDENTITY (1, 1) NOT NULL,
    [UnqCode]      VARCHAR (250) NOT NULL,
    [Descr]        VARCHAR (100) NULL,
    [SEName]       VARCHAR (250) NULL,
    [NodeType]     INT           CONSTRAINT [DF__tblCompan__NodeT__127EAEC5] DEFAULT ((120)) NOT NULL,
    [IsActive]     BIT           CONSTRAINT [DF__tblCompan__IsAct__1372D2FE] DEFAULT ((1)) NOT NULL,
    [FileSetIdIns] BIGINT        CONSTRAINT [DF__tblCompan__FileS__0524B3A7] DEFAULT ((0)) NOT NULL,
    [TimestampIns] DATETIME      CONSTRAINT [DF__tblCompan__Times__0618D7E0] DEFAULT (getdate()) NOT NULL,
    [FileSetIdUpd] BIGINT        NULL,
    [TimestampUpd] DATETIME      NULL,
    CONSTRAINT [PK_tblCompanySalesStructureSprvsnLvl1] PRIMARY KEY CLUSTERED ([NodeID] ASC)
);

