CREATE TABLE [dbo].[tblCompanySalesStructureRouteMstr] (
    [NodeID]            INT               IDENTITY (1, 1) NOT NULL,
    [NodeType]          INT               CONSTRAINT [DF_tblCompanySalesStructureRouteMstr_NodeType] DEFAULT ((140)) NOT NULL,
    [Code]              VARCHAR (50)      NULL,
    [Descr]             VARCHAR (500)     NOT NULL,
    [ShortName]         VARCHAR (500)     NULL,
    [RouteCode]         VARCHAR (50)      NULL,
    [RouteName]         VARCHAR (500)     NULL,
    [ISActive]          INT               CONSTRAINT [DF_tblCompanySalesStructureRouteMstr_ISActive] DEFAULT ((1)) NOT NULL,
    [CovFrqID]          INT               NULL,
    [CoveredStoreCount] INT               NULL,
    [RouteGeography]    [sys].[geography] NULL,
    [OffDay]            TINYINT           CONSTRAINT [DF_tblCompanySalesStructureRouteMstr_OffDay] DEFAULT ((7)) NOT NULL,
    [LoginIDIns]        INT               CONSTRAINT [DF_tblCompanySalesStructureRouteMstr_LoginIDIns] DEFAULT ((1)) NOT NULL,
    [TimestampIns]      DATETIME          CONSTRAINT [DF_tblCompanySalesStructureRouteMstr_TimestampIns] DEFAULT (getdate()) NOT NULL,
    [LoginIDUpd]        INT               NULL,
    [TimestampUpd]      DATETIME          NULL,
    [FileSetId]         INT               NULL,
    CONSTRAINT [PK_tblCompanySalesStructureRouteMstr] PRIMARY KEY CLUSTERED ([NodeID] ASC)
);

