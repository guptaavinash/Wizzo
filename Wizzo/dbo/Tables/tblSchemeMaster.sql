﻿CREATE TABLE [dbo].[tblSchemeMaster] (
    [SchemeID]                INT             IDENTITY (1, 1) NOT NULL,
    [SchemeTypeID]            TINYINT         NULL,
    [SchemeName]              NVARCHAR (100)  NULL,
    [SchemeDescription]       VARCHAR (500)   NULL,
    [SchemeCode]              VARCHAR (50)    NULL,
    [ApplicableBrands]        VARCHAR (4000)  NULL,
    [SchemeApplicationID]     INT             NULL,
    [flgActive]               TINYINT         CONSTRAINT [DF_tblMstrSchemeMaster_flgActive] DEFAULT ((1)) NULL,
    [FileSetIdIns]            BIGINT          NULL,
    [LoginID]                 INT             NOT NULL,
    [CreateDate]              DATETIME        NULL,
    [FileSetIdUpd]            BIGINT          NULL,
    [ModifyDate]              DATETIME        NULL,
    [SchemeType2Id]           TINYINT         CONSTRAINT [DF__tblScheme__Schem__5689C04F] DEFAULT ((1)) NOT NULL,
    [IsPayoutFixed]           TINYINT         NULL,
    [IsApplyOnDMS]            BIT             NULL,
    [IsApplyOnSFA]            BIT             NULL,
    [IsQPSApplyOnInvioce]     TINYINT         NULL,
    [SchemeCalculationTypeID] INT             NULL,
    [Retailer_Apply_Count]    INT             CONSTRAINT [DF_tblSchemeMaster_NoOfRetailer] DEFAULT ((0)) NOT NULL,
    [IsPurchOfEveryInv]       BIT             CONSTRAINT [DF_tblSchemeMaster_PurchOfEvery] DEFAULT ((0)) NOT NULL,
    [IsRange]                 BIT             CONSTRAINT [DF_tblSchemeMaster_IsRange] DEFAULT ((0)) NOT NULL,
    [ProRata]                 TINYINT         CONSTRAINT [DF_tblSchemeMaster_ProRata] DEFAULT ((0)) NOT NULL,
    [Remarks]                 VARCHAR (500)   NULL,
    [SchLvl]                  TINYINT         NULL,
    [SchType]                 TINYINT         NULL,
    [BUDGETAMT]               NUMERIC (18, 6) NULL,
    [MRPLevel]                INT             NULL,
    [ClaimGroupCode]          VARCHAR (100)   NULL,
    CONSTRAINT [PK_tblMstrSchemeMaster] PRIMARY KEY CLUSTERED ([SchemeID] ASC),
    CONSTRAINT [FK__tblScheme__Schem__5B4E756C] FOREIGN KEY ([SchemeCalculationTypeID]) REFERENCES [dbo].[tblSchemeCalculationTypeMstr] ([SchemeCalculationTypeID])
);

