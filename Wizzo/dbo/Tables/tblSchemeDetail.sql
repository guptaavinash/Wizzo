CREATE TABLE [dbo].[tblSchemeDetail] (
    [SchemeDetID]             INT           IDENTITY (2, 1) NOT NULL,
    [SchemeID]                INT           NULL,
    [SchemeFromDate]          SMALLDATETIME NULL,
    [SchemeToDate]            SMALLDATETIME NULL,
    [SchemeApplRule]          INT           NULL,
    [QPSTimePeriod]           INT           NULL,
    [QPSInterval]             TINYINT       NULL,
    [QPSFromDate]             SMALLDATETIME NULL,
    [QPSToDate]               SMALLDATETIME NULL,
    [flgStoreSelection]       TINYINT       NULL,
    [flgSalesHierarchy]       TINYINT       NULL,
    [flgChannel]              TINYINT       NULL,
    [flgTownClassification]   TINYINT       NULL,
    [Timestamp]               SMALLDATETIME CONSTRAINT [DF_tblSchemeDetail_Timestamp] DEFAULT (getdate()) NULL,
    [LoginIDIns]              INT           NULL,
    [LoginIDModify]           INT           NULL,
    [ManufacturerId]          INT           NULL,
    [SchemeProductApplicable] VARCHAR (MAX) NULL,
    [ProductText]             VARCHAR (MAX) NULL,
    CONSTRAINT [PK_tblSchemeDetail] PRIMARY KEY CLUSTERED ([SchemeDetID] ASC)
);

