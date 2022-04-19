CREATE TABLE [dbo].[tblMstrReasonForClosedStore] (
    [ReasonId]    INT           IDENTITY (1, 1) NOT NULL,
    [ReasonDescr] VARCHAR (100) NULL,
    [IsActive]    TINYINT       CONSTRAINT [DF_tblMstrReasonForClosedStore_IsActive] DEFAULT ((1)) NULL,
    [Ordr]        TINYINT       NULL,
    CONSTRAINT [PK_tblMstrReasonForClosedStore] PRIMARY KEY CLUSTERED ([ReasonId] ASC)
);

