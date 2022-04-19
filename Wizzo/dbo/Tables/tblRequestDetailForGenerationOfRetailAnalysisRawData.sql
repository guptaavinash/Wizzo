CREATE TABLE [dbo].[tblRequestDetailForGenerationOfRetailAnalysisRawData] (
    [RequestId]                INT           IDENTITY (1, 1) NOT NULL,
    [strTime]                  VARCHAR (500) NULL,
    [strProduct]               VARCHAR (500) NULL,
    [strCompanySales]          VARCHAR (500) NULL,
    [SalesLvl]                 INT           NULL,
    [strKeyVal]                VARCHAR (500) NULL,
    [LoginId]                  INT           NULL,
    [MainMeasureId]            INT           NULL,
    [flgToShowPriorityDBROnly] TINYINT       NULL,
    [FileName]                 VARCHAR (500) NULL,
    [EMailId]                  VARCHAR (200) NULL,
    [TimeStampIns]             DATETIME      NULL,
    [flgGenerated]             TINYINT       CONSTRAINT [DF_tblRequestDetailForGenerationOfRetailAnalysisRawData_flgGenerated] DEFAULT ((0)) NULL,
    [GenerationTime]           DATETIME      NULL,
    CONSTRAINT [PK_tblRequestDetailForGenerationOfRetailAnalysisRawData] PRIMARY KEY CLUSTERED ([RequestId] ASC)
);

