CREATE TABLE [dbo].[tblIncentive_SlabMaster] (
    [IncSlabID]    INT           IDENTITY (1, 1) NOT NULL,
    [IncId]        INT           NOT NULL,
    [FromDate]     DATETIME      NULL,
    [ToDate]       DATETIME      NULL,
    [strSlabRule]  VARCHAR (200) NULL,
    [LoginIDIns]   INT           NULL,
    [TimestampIns] DATETIME      CONSTRAINT [DF_tblIncentive_KPISlabDetail_TimestampIns] DEFAULT (getdate()) NULL,
    [LoginIDUpd]   INT           NULL,
    [TimestampUpd] DATETIME      NULL,
    CONSTRAINT [PK_tblIncentive_KPISlabDetail] PRIMARY KEY CLUSTERED ([IncSlabID] ASC)
);

