CREATE TABLE [dbo].[tblPDAMaster] (
    [PDAID]            INT           IDENTITY (1, 1) NOT NULL,
    [PDAModelName]     VARCHAR (50)  NULL,
    [PDA_IMEI]         VARCHAR (50)  NOT NULL,
    [TASSiteNodeId]    INT           CONSTRAINT [DF_tblPDAMaster_TASSiteNodeId] DEFAULT ((0)) NOT NULL,
    [TASSiteNodeType]  INT           CONSTRAINT [DF_tblPDAMaster_TASSiteNodeType] DEFAULT ((0)) NOT NULL,
    [LoginID]          INT           NULL,
    [PDA_PurchaseDate] DATETIME      NULL,
    [PDA_IMEI_Sec]     VARCHAR (50)  NULL,
    [InstallDate]      DATETIME      NULL,
    [PrchFrom]         VARCHAR (100) NULL,
    [flgTesting]       TINYINT       NULL,
    CONSTRAINT [PK_tblPDAMaster] PRIMARY KEY CLUSTERED ([PDAID] ASC)
);

