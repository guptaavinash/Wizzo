CREATE TABLE [dbo].[tblMstrFileSet] (
    [FileSetId]                BIGINT        IDENTITY (1, 1) NOT NULL,
    [FileSetName]              VARCHAR (150) NOT NULL,
    [FileCreationDate]         DATETIME      NOT NULL,
    [FileBranchCode]           VARCHAR (50)  CONSTRAINT [DF_tblMstrFileSet_FileBranchCode] DEFAULT ('') NOT NULL,
    [FileDataDate]             DATE          CONSTRAINT [DF_tblMstrFileSet_FileDataDate] DEFAULT ('2000-01-01') NOT NULL,
    [FileVersionNo]            VARCHAR (50)  CONSTRAINT [DF_tblMstrFileSet_FileVersionNo] DEFAULT ('') NOT NULL,
    [FileSetType]              VARCHAR (20)  CONSTRAINT [DF_tblMstrFileSet_FileSetType] DEFAULT ('') NOT NULL,
    [ProcessStartTime]         DATETIME      CONSTRAINT [DF_tblMstrFileSet_ProcessStartTime] DEFAULT (getdate()) NOT NULL,
    [ProcessEndTime]           DATETIME      NULL,
    [flgSuccess]               TINYINT       CONSTRAINT [DF_tblMstrFileSet_flgSuccess] DEFAULT ((0)) NOT NULL,
    [FileSetErrorId]           TINYINT       CONSTRAINT [DF_tblMstrFileSet_FileSetErrorId] DEFAULT ((0)) NOT NULL,
    [BranchId]                 INT           CONSTRAINT [DF_tblMstrFileSet_BranchId] DEFAULT ((0)) NOT NULL,
    [VersionId]                INT           CONSTRAINT [DF_tblMstrFileSet_VersionId] DEFAULT ((0)) NOT NULL,
    [DataSourceId]             TINYINT       CONSTRAINT [DF_tblMstrFileSet_DataSourceId] DEFAULT ((1)) NULL,
    [FileDataProcessStartTime] DATETIME      NULL,
    [FileDataProcessEndTime]   DATETIME      NULL,
    [FileSize]                 INT           NULL,
    [IMEINo]                   VARCHAR (50)  NULL,
    CONSTRAINT [PK_tblMstrFileSet] PRIMARY KEY CLUSTERED ([FileSetId] ASC)
);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'1:Success,2:Error,0:Pending', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblMstrFileSet', @level2type = N'COLUMN', @level2name = N'flgSuccess';

