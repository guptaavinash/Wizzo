CREATE TABLE [dbo].[tblSORouteDataSentMarking] (
    [SORouteDataId] INT          IDENTITY (1, 1) NOT NULL,
    [SONodeId]      INT          NOT NULL,
    [SONodeType]    INT          NOT NULL,
    [RouteERPID]    VARCHAR (50) NULL,
    [DataDate]      DATE         CONSTRAINT [DF_tblSORouteOrderWrongNoDataSentMarking_DataDate] DEFAULT (getdate()) NOT NULL,
    [flgMark]       TINYINT      NOT NULL,
    [TimeStampIns]  DATETIME     CONSTRAINT [DF_tblSORouteOrderWrongNoDataSentMarking_TimeStampIns] DEFAULT (getdate()) NOT NULL,
    CONSTRAINT [PK_tblSORouteOrderWrongNoDataSentMarking] PRIMARY KEY CLUSTERED ([SORouteDataId] ASC)
);

