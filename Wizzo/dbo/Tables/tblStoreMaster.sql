CREATE TABLE [dbo].[tblStoreMaster] (
    [StoreID]                    INT              IDENTITY (1, 1) NOT NULL,
    [StoreCode]                  VARCHAR (50)     NULL,
    [StoreName]                  VARCHAR (500)    NOT NULL,
    [TimeStampIns]               SMALLDATETIME    CONSTRAINT [DF_tblStoreMaster_TimeStampIns] DEFAULT (getdate()) NOT NULL,
    [TimeStampUpd]               SMALLDATETIME    NULL,
    [flgActive]                  TINYINT          CONSTRAINT [DF_tblStoreMaster_flgActive] DEFAULT ((1)) NOT NULL,
    [ChannelId]                  INT              NULL,
    [FileSetIdUpd]               BIGINT           NULL,
    [FileSetIdTimeStamp]         DATETIME         NULL,
    [FileSetIdIns]               BIGINT           NULL,
    [ShopType]                   TINYINT          NULL,
    [IsDiscountApplicable]       TINYINT          NULL,
    [DBID]                       INT              NULL,
    [DBNodeType]                 SMALLINT         NULL,
    [Lat Code]                   NUMERIC (26, 22) NULL,
    [Long Code]                  NUMERIC (26, 22) NULL,
    [StoreIdDB]                  INT              NULL,
    [IMEINo]                     VARCHAR (50)     NULL,
    [StoreMapAddress]            VARCHAR (1000)   NULL,
    [MapCity]                    VARCHAR (100)    NULL,
    [MapPincode]                 BIGINT           NULL,
    [MapState]                   VARCHAR (500)    NULL,
    [CreatedDate]                SMALLDATETIME    NULL,
    [flgApproved]                TINYINT          NULL,
    [ApprovedDate]               SMALLDATETIME    NULL,
    [flgValidated]               TINYINT          NULL,
    [StoreIDPDA]                 VARCHAR (100)    NULL,
    [FirmType]                   TINYINT          NULL,
    [IsGSTSubmitted]             TINYINT          NULL,
    [GSTNumber]                  VARCHAR (50)     NULL,
    [IsPanSubmitted]             TINYINT          NULL,
    [PanNumber]                  VARCHAR (100)    NULL,
    [IsAadharSubmitted]          TINYINT          NULL,
    [AadharNumber]               VARCHAR (100)    NULL,
    [IsElectricityBillSubmitted] TINYINT          NULL,
    [ElectricityBillNumber]      VARCHAR (100)    NULL,
    [IsVoterIDSubmitted]         TINYINT          NULL,
    [VoterIDNumber]              VARCHAR (100)    NULL,
    CONSTRAINT [pk_tblStoreMaster] PRIMARY KEY CLUSTERED ([StoreID] ASC),
    CONSTRAINT [IX_tblStoreMaster] UNIQUE NONCLUSTERED ([StoreCode] ASC)
);


GO
CREATE NONCLUSTERED INDEX [IX_tblStoreMaster_1]
    ON [dbo].[tblStoreMaster]([DBID] ASC, [DBNodeType] ASC);

