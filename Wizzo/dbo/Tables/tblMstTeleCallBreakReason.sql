CREATE TABLE [dbo].[tblMstTeleCallBreakReason] (
    [TelCallBreakReasonId] TINYINT      IDENTITY (1, 1) NOT NULL,
    [TelCallBreakReason]   VARCHAR (50) NOT NULL,
    CONSTRAINT [PK_tblMstTeleCallBreakReason] PRIMARY KEY CLUSTERED ([TelCallBreakReasonId] ASC)
);

