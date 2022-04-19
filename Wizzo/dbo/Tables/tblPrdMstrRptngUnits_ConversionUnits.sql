CREATE TABLE [dbo].[tblPrdMstrRptngUnits_ConversionUnits] (
    [SKUID]            INT              NOT NULL,
    [SqNo]             INT              NULL,
    [PackUnitID]       INT              NOT NULL,
    [RptngUnitID]      INT              NOT NULL,
    [ConversionFactor] DECIMAL (28, 12) NOT NULL,
    [LoginIDCreate]    INT              CONSTRAINT [DF_tblPrdMstrRptngUnits_ConversionUnits_LoginIDCreate] DEFAULT ((0)) NOT NULL,
    [TimeStampCreate]  DATETIME         CONSTRAINT [DF_tblPrdMstrRptngUnits_ConversionUnits_TimeStampCreate] DEFAULT (getdate()) NOT NULL,
    [LoginIDMod]       INT              CONSTRAINT [DF_tblPrdMstrRptngUnits_ConversionUnits_LoginIDMod] DEFAULT ((0)) NOT NULL,
    [TimeStampMod]     DATETIME         CONSTRAINT [DF_tblPrdMstrRptngUnits_ConversionUnits_TimeStampMod] DEFAULT (getdate()) NOT NULL,
    [NodeType]         INT              NULL
);

