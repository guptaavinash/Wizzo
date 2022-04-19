CREATE TABLE [dbo].[tbl_PDAGCM_Mstr] (
    [PDAGCMAutoID]         INT          IDENTITY (1, 1) NOT NULL,
    [PDACode]              VARCHAR (50) NULL,
    [RegistrationID]       TEXT         NULL,
    [RegistrationTime]     DATETIME     CONSTRAINT [DF_tbl_PDAGCM_Mstr_RegistrationTime] DEFAULT (getdate()) NULL,
    [GCMApplicationAutoID] INT          NULL,
    [AppVersionID]         VARCHAR (50) NULL,
    CONSTRAINT [PK_tbl_PDAGCM_Mstr] PRIMARY KEY CLUSTERED ([PDAGCMAutoID] ASC)
);

