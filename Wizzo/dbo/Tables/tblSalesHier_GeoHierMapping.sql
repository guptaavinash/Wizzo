CREATE TABLE [dbo].[tblSalesHier_GeoHierMapping] (
    [MapId]             INT      IDENTITY (1, 1) NOT NULL,
    [GeoNodeId]         INT      NOT NULL,
    [GeoNodeType]       INT      NOT NULL,
    [SalesAreaNodeId]   INT      NOT NULL,
    [SalesAreaNodeType] INT      NOT NULL,
    [FromDate]          DATETIME CONSTRAINT [DF_tblSalesHier_GeoHierMapping_FromDate] DEFAULT (getdate()) NOT NULL,
    [ToDate]            DATETIME CONSTRAINT [DF_tblSalesHier_GeoHierMapping_ToDate] DEFAULT (((2049)-(12))-(31)) NOT NULL,
    [LoginID]           INT      CONSTRAINT [DF_tblSalesHier_GeoHierMapping_LoginID] DEFAULT ((1)) NOT NULL,
    [CreateDate]        DATETIME CONSTRAINT [DF_tblSalesHier_GeoHierMapping_CreateDate] DEFAULT (getdate()) NOT NULL,
    [LoginID_Modify]    INT      NULL,
    [ModifyDate]        DATETIME NULL,
    CONSTRAINT [PK_tblSalesHier_GeoHierMapping] PRIMARY KEY CLUSTERED ([MapId] ASC)
);

