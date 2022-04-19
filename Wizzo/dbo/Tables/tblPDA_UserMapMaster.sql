CREATE TABLE [dbo].[tblPDA_UserMapMaster] (
    [PDAPersonMapID] INT      IDENTITY (1, 1) NOT NULL,
    [PDAID]          INT      NOT NULL,
    [PersonID]       INT      NOT NULL,
    [PersonType]     TINYINT  NULL,
    [DateFrom]       DATETIME CONSTRAINT [DF_tblPDA_UserMapMaster_DateFrom] DEFAULT (getdate()) NOT NULL,
    [DateTo]         DATETIME CONSTRAINT [DF_tblPDA_UserMapMaster_DateTo] DEFAULT ('31-dec-2049') NULL,
    [LoginIDIns]     INT      CONSTRAINT [DF_tblPDA_UserMapMaster_LoginIDIns] DEFAULT ((1)) NOT NULL,
    [TImestampIns]   DATETIME CONSTRAINT [DF_tblPDA_UserMapMaster_TImestampIns] DEFAULT (getdate()) NOT NULL,
    [LoginIDUpd]     INT      NULL,
    [TimestampUpd]   DATETIME NULL,
    [PDASIMID]       INT      NULL,
    [PDAStatus]      TINYINT  NULL,
    CONSTRAINT [PK_tblPDA_UserMapMaster] PRIMARY KEY CLUSTERED ([PDAPersonMapID] ASC)
);

