CREATE TABLE [dbo].[tblInc_MeasureMaster] (
    [MsrID]   INT           IDENTITY (1, 1) NOT NULL,
    [MsrName] VARCHAR (200) NULL,
    CONSTRAINT [PK_tblInc_MeasureMaster] PRIMARY KEY CLUSTERED ([MsrID] ASC)
);

