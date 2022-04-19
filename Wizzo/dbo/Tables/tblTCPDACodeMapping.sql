CREATE TABLE [dbo].[tblTCPDACodeMapping] (
    [TCPDAID]   INT            IDENTITY (1, 1) NOT NULL,
    [PersonID]  INT            NULL,
    [PDACode]   NVARCHAR (200) NULL,
    [ValidFrom] DATETIME2 (7)  NULL,
    [ValidTo]   DATETIME2 (7)  NULL,
    [flgLock]   TINYINT        CONSTRAINT [DF_tblTCPDACodeMapping_flgLock] DEFAULT ((0)) NULL,
    [OTP]       VARCHAR (10)   NULL,
    [FCMToken]  VARCHAR (200)  NULL,
    CONSTRAINT [IX_tblTCPDACodeMapping] UNIQUE NONCLUSTERED ([PersonID] ASC, [PDACode] ASC)
);

