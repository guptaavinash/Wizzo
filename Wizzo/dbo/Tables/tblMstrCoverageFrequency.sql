CREATE TABLE [dbo].[tblMstrCoverageFrequency] (
    [CovFrqID]     INT          IDENTITY (1, 1) NOT NULL,
    [CovFrq]       VARCHAR (50) NULL,
    [LoginIDIns]   INT          NOT NULL,
    [TimestampIns] DATETIME     NULL,
    [LoginIDUpd]   INT          NULL,
    [TimestampUpd] DATETIME     NULL
);

