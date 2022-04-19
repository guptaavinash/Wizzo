CREATE TABLE [dbo].[tblMeasureListForMTDRetailRouteReport] (
    [Id]                        INT           IDENTITY (1, 1) NOT NULL,
    [Measure]                   VARCHAR (200) NULL,
    [PId]                       INT           NULL,
    [Flg]                       INT           NULL,
    [Ordr]                      INT           NULL,
    [ColorCode]                 VARCHAR (10)  NULL,
    [ColorCode_2]               VARCHAR (10)  NULL,
    [OLAPMeasureName]           VARCHAR (200) NULL,
    [ColumnName]                VARCHAR (200) NULL,
    [ColumnDataType]            VARCHAR (20)  NULL,
    [FlgRound]                  TINYINT       NULL,
    [NoOfDecimals]              TINYINT       NULL,
    [FlgPercentage]             TINYINT       NULL,
    [flgMeasureForTopLevelUser] TINYINT       DEFAULT ((0)) NOT NULL,
    [flgForPopUp]               TINYINT       DEFAULT ((0)) NOT NULL,
    CONSTRAINT [PK_tblMeasureListForMTDRetailRouteReport1] PRIMARY KEY CLUSTERED ([Id] ASC)
);

