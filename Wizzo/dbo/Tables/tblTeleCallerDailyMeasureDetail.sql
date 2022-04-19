CREATE TABLE [dbo].[tblTeleCallerDailyMeasureDetail] (
    [TCDailyMeasDetId] INT          IDENTITY (1, 1) NOT NULL,
    [TCDailyId]        INT          NOT NULL,
    [MeasureId]        TINYINT      NOT NULL,
    [MeasureVal]       VARCHAR (20) NOT NULL,
    [TimeStampUpd]     DATETIME     NULL,
    CONSTRAINT [PK_tblTCDailyMeasureDetail] PRIMARY KEY CLUSTERED ([TCDailyMeasDetId] ASC)
);

