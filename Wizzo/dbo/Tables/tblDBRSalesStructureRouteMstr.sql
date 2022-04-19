CREATE TABLE [dbo].[tblDBRSalesStructureRouteMstr] (
    [NodeID]            INT               IDENTITY (1, 1) NOT NULL,
    [NodeType]          INT               CONSTRAINT [DF_tblDBRSalesStructureRouteMstr_NodeType_1] DEFAULT ((170)) NOT NULL,
    [Descr]             VARCHAR (200)     NOT NULL,
    [ShortName]         VARCHAR (200)     NULL,
    [ISActive]          INT               CONSTRAINT [DF_tblDBRSalesStructureRouteMstr_ISActive_1] DEFAULT ((1)) NOT NULL,
    [CovFrqID]          INT               NULL,
    [CoveredStoreCount] INT               NULL,
    [RouteGeography]    [sys].[geography] NULL,
    [OffDay]            TINYINT           CONSTRAINT [DF_tblDBRSalesStructureRouteMstr_OffDay] DEFAULT ((7)) NOT NULL,
    [LoginIDIns]        INT               CONSTRAINT [DF_tblDBRSalesStructureRouteMstr_LoginIDIns_1] DEFAULT ((1)) NOT NULL,
    [TimestampIns]      DATETIME          CONSTRAINT [DF_tblDBRSalesStructureRouteMstr_TimestampIns_1] DEFAULT (getdate()) NOT NULL,
    [LoginIDUpd]        INT               NULL,
    [TimestampUpd]      DATETIME          NULL,
    CONSTRAINT [PK_tblDBRSalesStructureRouteMstr_1] PRIMARY KEY CLUSTERED ([NodeID] ASC)
);

