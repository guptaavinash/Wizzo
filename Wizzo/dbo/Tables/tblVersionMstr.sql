CREATE TABLE [dbo].[tblVersionMstr] (
    [VersionID]           INT            IDENTITY (1, 1) NOT NULL,
    [VersionSerialNo]     VARCHAR (50)   NULL,
    [VersionCreationDate] DATETIME       CONSTRAINT [DF_tblVersionMstr_VersionCreationDate] DEFAULT (getdate()) NULL,
    [ApplicationType]     INT            NULL,
    [VSNMajor]            VARCHAR (4)    NULL,
    [VSNMinor]            VARCHAR (4)    NULL,
    [TxtMajorChanges]     VARCHAR (1000) NULL,
    [TxtMinorChanges]     VARCHAR (1000) NULL,
    [TxtIssues]           VARCHAR (1000) NULL,
    CONSTRAINT [PK_tblVersionMstr] PRIMARY KEY CLUSTERED ([VersionID] ASC)
);

