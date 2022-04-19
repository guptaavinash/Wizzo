CREATE TABLE [dbo].[tblTCEmpMstr] (
    [EmpId]            INT           IDENTITY (1, 1) NOT NULL,
    [EmpName]          VARCHAR (100) NOT NULL,
    [ContactNo]        VARCHAR (50)  NOT NULL,
    [EmailId]          VARCHAR (50)  NOT NULL,
    [Address]          VARCHAR (500) NOT NULL,
    [EmgencyContactNo] VARCHAR (50)  NULL,
    [DOB]              DATE          NULL,
    [flgActive]        BIT           CONSTRAINT [DF_tblEmpMstr_flgActive_1] DEFAULT ((1)) NOT NULL,
    [TASSiteNodeId]    INT           NOT NULL,
    [TASSiteNodeType]  INT           NOT NULL,
    [LoginIdIns]       INT           CONSTRAINT [DF_tblEmpMstr_LoginIdIns] DEFAULT ((0)) NOT NULL,
    [TimeStampIns]     DATETIME      CONSTRAINT [DF_tblEmpMstr_TimeStampIns] DEFAULT (getdate()) NOT NULL,
    [LoginIdUpd]       INT           NULL,
    [TimeStampUpd]     DATETIME      NULL,
    [FCMTokenNo]       VARCHAR (200) NULL,
    CONSTRAINT [PK_tblEmpMstr] PRIMARY KEY CLUSTERED ([EmpId] ASC)
);

