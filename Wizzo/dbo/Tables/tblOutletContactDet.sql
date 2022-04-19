CREATE TABLE [dbo].[tblOutletContactDet] (
    [OutCnctPersonID]      INT           IDENTITY (1, 1) NOT NULL,
    [OutCnctpersonTypeID]  INT           NULL,
    [ContactType]          TINYINT       NULL,
    [StoreID]              INT           NOT NULL,
    [FName]                VARCHAR (200) NOT NULL,
    [Lname]                VARCHAR (200) NULL,
    [LandLineNo1]          VARCHAR (20)  NULL,
    [Extn1]                VARCHAR (10)  NULL,
    [LandLineNo2]          VARCHAR (20)  NULL,
    [Extn2]                VARCHAR (10)  NULL,
    [MobNo]                BIGINT        NULL,
    [IsSameWhatsappnumber] TINYINT       NULL,
    [alternatewhatsappNo]  BIGINT        NULL,
    [EMailID]              VARCHAR (200) NULL,
    [Wed_Date]             DATE          NULL,
    [Birth_Date]           DATE          NULL,
    [OrderTakenBy]         INT           NULL,
    [PersonIDIns]          INT           NULL,
    [PersonIDUpd]          INT           NULL,
    [TimestampIns]         SMALLDATETIME CONSTRAINT [DF_tblOutletContactDet_TimestampIns_1] DEFAULT (getdate()) NULL,
    [TimestampUpd]         SMALLDATETIME NULL,
    [alternatenumber]      BIGINT        NULL,
    [flgDisplay]           TINYINT       DEFAULT ((0)) NOT NULL,
    CONSTRAINT [PK_tblOutletContactDet] PRIMARY KEY CLUSTERED ([OutCnctPersonID] ASC),
    CONSTRAINT [FK_tblOutletContactDet_tblStoreMaster] FOREIGN KEY ([StoreID]) REFERENCES [dbo].[tblStoreMaster] ([StoreID]) ON DELETE CASCADE ON UPDATE CASCADE
);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'1=Owner,2=Other', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblOutletContactDet', @level2type = N'COLUMN', @level2name = N'OrderTakenBy';

