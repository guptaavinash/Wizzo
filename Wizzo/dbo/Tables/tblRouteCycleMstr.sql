CREATE TABLE [dbo].[tblRouteCycleMstr] (
    [RouteCycId]    INT          IDENTITY (1, 1) NOT NULL,
    [RouteCycDescr] VARCHAR (50) NULL,
    [TimeStampIns]  DATETIME     CONSTRAINT [DF_tblRouteCycleMstr_TimeStampIns] DEFAULT (getdate()) NOT NULL,
    CONSTRAINT [PK_tblMstrRouteCycleMstr] PRIMARY KEY CLUSTERED ([RouteCycId] ASC)
);

