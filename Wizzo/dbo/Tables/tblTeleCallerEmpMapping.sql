CREATE TABLE [dbo].[tblTeleCallerEmpMapping] (
    [TCEmpMapId]   INT      IDENTITY (1, 1) NOT NULL,
    [NodeId]       INT      NOT NULL,
    [NodeType]     INT      NOT NULL,
    [EmpId]        INT      NOT NULL,
    [FromDate]     DATE     CONSTRAINT [DF_tblTeleCallerEmpMapping_FromDate] DEFAULT (getdate()) NOT NULL,
    [ToDate]       DATE     CONSTRAINT [DF_tblTeleCallerEmpMapping_ToDate] DEFAULT ('2050-12-31') NOT NULL,
    [LoginIdIns]   INT      CONSTRAINT [DF_tblTeleCallerEmpMapping_LoginIdIns] DEFAULT ((0)) NOT NULL,
    [TimeStampIns] DATETIME CONSTRAINT [DF_tblTeleCallerEmpMapping_TimeStampIns] DEFAULT (getdate()) NOT NULL,
    [LoginIdUPd]   INT      NULL,
    [TimeSTampUpd] DATETIME NULL,
    CONSTRAINT [PK_tblTeleCallerEmpMapping] PRIMARY KEY CLUSTERED ([TCEmpMapId] ASC)
);

