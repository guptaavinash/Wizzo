CREATE TABLE [dbo].[tblInc_NotApplicableUserMapping] (
    [IncDateSHMapId]    INT      IDENTITY (1, 1) NOT NULL,
    [IncDateMapId]      INT      NULL,
    [SalesHierNodeID]   INT      NULL,
    [SalesHierNodeType] INT      NULL,
    [FromDate]          DATETIME NULL,
    [ToDate]            DATETIME NULL,
    [LoginIDIns]        INT      NULL,
    [TimestampIns]      DATETIME CONSTRAINT [DF_tblInc_NotApplicableUserMapping_TimestampIns] DEFAULT (getdate()) NULL,
    [LoginIDUpd]        INT      NULL,
    [TimestampUpd]      DATETIME NULL,
    CONSTRAINT [PK_tblInc_NotApplicableUserMapping] PRIMARY KEY CLUSTERED ([IncDateSHMapId] ASC)
);

