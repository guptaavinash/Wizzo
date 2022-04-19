CREATE TABLE [dbo].[tblTCPDA_UserMapMaster] (
    [PDAEmpMapID]  INT      IDENTITY (1, 1) NOT NULL,
    [TCPDAID]      INT      NOT NULL,
    [TCEmpID]      INT      NOT NULL,
    [EmpType]      TINYINT  NULL,
    [DateFrom]     DATE     CONSTRAINT [DF_tblTCPDA_UserMapMaster_DateFrom] DEFAULT (getdate()) NOT NULL,
    [DateTo]       DATE     CONSTRAINT [DF_tblTCPDA_UserMapMaster_DateTo] DEFAULT ('31-dec-2049') NULL,
    [LoginIDIns]   INT      CONSTRAINT [DF_tblTCPDA_UserMapMaster_LoginIDIns] DEFAULT ((1)) NOT NULL,
    [TImestampIns] DATETIME CONSTRAINT [DF_tblTCPDA_UserMapMaster_TImestampIns] DEFAULT (getdate()) NOT NULL,
    [LoginIDUpd]   INT      NULL,
    [TimestampUpd] DATETIME NULL,
    [PDASIMID]     INT      NULL,
    [PDAStatus]    TINYINT  NULL,
    CONSTRAINT [PK_tblTCPDA_UserMapMaster] PRIMARY KEY CLUSTERED ([PDAEmpMapID] ASC)
);

