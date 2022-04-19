CREATE TABLE [dbo].[tblMstrFrequency] (
    [FrqTypeId]          TINYINT       IDENTITY (1, 1) NOT NULL,
    [FrqType]            VARCHAR (50)  NOT NULL,
    [FrqTypeDetail]      VARCHAR (100) NOT NULL,
    [MaxNo]              TINYINT       CONSTRAINT [DF_tblMstrFrequency_MaxNo] DEFAULT ((0)) NOT NULL,
    [NoOfDaysForTCRoute] TINYINT       CONSTRAINT [DF_tblMstrFrequency_NoOfDaysForTCRoute] DEFAULT ((0)) NOT NULL,
    [SUBDFrqType]        VARCHAR (50)  NULL,
    [NoOfWeeks]          TINYINT       CONSTRAINT [DF_tblMstrFrequency_NoOfWeeks] DEFAULT ((1)) NOT NULL,
    CONSTRAINT [PK_tblMstrFrequency] PRIMARY KEY CLUSTERED ([FrqTypeId] ASC)
);

