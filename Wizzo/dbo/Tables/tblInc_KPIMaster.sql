CREATE TABLE [dbo].[tblInc_KPIMaster] (
    [KPIID]   INT           IDENTITY (1, 1) NOT NULL,
    [KPIname] VARCHAR (200) NULL,
    [KRAID]   INT           NOT NULL,
    PRIMARY KEY CLUSTERED ([KPIID] ASC),
    CONSTRAINT [FK_tblInc_KPImaster_ToTable] FOREIGN KEY ([KRAID]) REFERENCES [dbo].[tblInc_KRAMaster] ([KRAID]) ON DELETE CASCADE
);

