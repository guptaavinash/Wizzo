CREATE TABLE [dbo].[tblTCPDACodeMapping_History] (
    [TCPDAID]   INT            NULL,
    [PersonID]  INT            NULL,
    [PDACode]   NVARCHAR (200) NULL,
    [ValidFrom] DATETIME2 (7)  NULL,
    [ValidTo]   DATETIME2 (7)  NULL,
    [flgLock]   TINYINT        NULL,
    [OTP]       VARCHAR (10)   NULL,
    [FCMToken]  VARCHAR (200)  NULL
);

