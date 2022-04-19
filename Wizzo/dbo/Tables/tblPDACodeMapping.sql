CREATE TABLE [dbo].[tblPDACodeMapping] (
    [PDAID]     INT            IDENTITY (1, 1) NOT NULL,
    [PersonID]  INT            NULL,
    [PDACode]   NVARCHAR (200) NULL,
    [ValidFrom] DATETIME2 (7)  NULL,
    [ValidTo]   DATETIME2 (7)  NULL,
    [flgLock]   TINYINT        CONSTRAINT [DF_tblPDACodeMapping_flgLock] DEFAULT ((0)) NULL,
    [OTP]       VARCHAR (10)   NULL,
    [FCMToken]  VARCHAR (200)  NULL,
    CONSTRAINT [IX_tblPDACodeMapping] UNIQUE NONCLUSTERED ([PersonID] ASC, [PDACode] ASC)
);

