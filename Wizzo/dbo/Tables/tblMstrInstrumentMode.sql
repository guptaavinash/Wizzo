CREATE TABLE [dbo].[tblMstrInstrumentMode] (
    [InstrumentModeId] TINYINT      IDENTITY (1, 1) NOT NULL,
    [InstrumentMode]   VARCHAR (50) NULL,
    [InstrumentType]   TINYINT      NULL,
    CONSTRAINT [PK_tblMstrInstrumentMode] PRIMARY KEY CLUSTERED ([InstrumentModeId] ASC)
);

