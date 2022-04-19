CREATE TABLE [dbo].[tblPrdMstrBUOMMaster] (
    [BUOMID]            INT          IDENTITY (1, 1) NOT NULL,
    [ShortBUOMName]     VARCHAR (50) NULL,
    [BUOMName]          VARCHAR (50) NOT NULL,
    [LoginIDCreate]     INT          CONSTRAINT [DF_tblPrdMstrPackUnits_LoginIDCreate] DEFAULT ((0)) NOT NULL,
    [TimeStampCreate]   DATETIME     CONSTRAINT [DF_tblPrdMstrPackUnits_TimeStampCreate] DEFAULT (getdate()) NOT NULL,
    [LoginIDMod]        INT          CONSTRAINT [DF_tblPrdMstrPackUnits_LoginIDMod] DEFAULT ((0)) NOT NULL,
    [TimeStampMod]      DATETIME     CONSTRAINT [DF_tblPrdMstrPackUnits_TimeStampCreate1] DEFAULT (getdate()) NOT NULL,
    [flgConversionUnit] TINYINT      NULL,
    CONSTRAINT [PK__tblPrdMsPU__9825D9FB7F60ED59] PRIMARY KEY CLUSTERED ([BUOMID] ASC)
);

