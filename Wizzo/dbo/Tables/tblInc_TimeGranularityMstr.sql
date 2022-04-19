CREATE TABLE [dbo].[tblInc_TimeGranularityMstr] (
    [TimeGranualrityId]    INT           IDENTITY (1, 1) NOT NULL,
    [TimeGranualrityDescr] VARCHAR (100) NULL,
    CONSTRAINT [PK_tblTimeGranularityMstr] PRIMARY KEY CLUSTERED ([TimeGranualrityId] ASC)
);

