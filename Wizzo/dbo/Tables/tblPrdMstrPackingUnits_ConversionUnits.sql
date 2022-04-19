CREATE TABLE [dbo].[tblPrdMstrPackingUnits_ConversionUnits] (
    [SKUId]              INT             NOT NULL,
    [SqNo]               INT             NOT NULL,
    [BaseUOMID]          INT             NOT NULL,
    [PackUOMID]          INT             NOT NULL,
    [RelConversionUnits] DECIMAL (18, 4) NOT NULL,
    [LoginIDCreate]      INT             CONSTRAINT [DF_tblPrdMstrPackingUnitsRelConversion_LoginIDCreate] DEFAULT ((0)) NOT NULL,
    [TimeStampCreate]    DATETIME        CONSTRAINT [DF_tblPrdMstrPackingUnitsRelConversion_TimeStampCreate] DEFAULT (getdate()) NOT NULL,
    [LoginIDMod]         INT             CONSTRAINT [DF_tblPrdMstrPackingUnitsRelConversion_LoginIDMod] DEFAULT ((0)) NOT NULL,
    [TimeStampMod]       DATETIME        CONSTRAINT [DF_tblPrdMstrPackingUnitsRelConversion_TimeStampMod] DEFAULT (getdate()) NOT NULL,
    [flgDistOrder]       TINYINT         NULL,
    [flgDistInvoice]     TINYINT         NULL,
    [flgReporting]       TINYINT         CONSTRAINT [DF_tblPrdMstrPackingUnits_ConversionUnits_flgReporting] DEFAULT ((0)) NULL,
    [flgRetailUnit]      TINYINT         NULL,
    [NodeType]           INT             NULL,
    [flgVanLoading]      TINYINT         NULL,
    CONSTRAINT [FK_tblPrdMstrPackingUnits_ConversionUnits_tblPrdMstrBUOMMaster] FOREIGN KEY ([PackUOMID]) REFERENCES [dbo].[tblPrdMstrBUOMMaster] ([BUOMID]) ON DELETE CASCADE ON UPDATE CASCADE
);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Relative Conversion Units. This is relative to the conversion unit where RelConvUnit =  1', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblPrdMstrPackingUnits_ConversionUnits', @level2type = N'COLUMN', @level2name = N'RelConversionUnits';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'0=Reporting at BaseUnit,1=Reporting at Parent Unit', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblPrdMstrPackingUnits_ConversionUnits', @level2type = N'COLUMN', @level2name = N'flgReporting';

