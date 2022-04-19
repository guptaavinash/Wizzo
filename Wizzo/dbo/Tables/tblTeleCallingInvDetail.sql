CREATE TABLE [dbo].[tblTeleCallingInvDetail] (
    [TeleCallingId]  INT             NOT NULL,
    [PrdNodeId]      INT             NOT NULL,
    [PrdNodeType]    INT             NOT NULL,
    [InvNo]          VARCHAR (50)    NOT NULL,
    [InvDate]        DATE            NOT NULL,
    [Qty]            INT             NULL,
    [NetValue]       NUMERIC (18, 2) NULL,
    [GrossAmt]       NUMERIC (18, 2) NULL,
    [TaxAmt]         NUMERIC (18, 2) NULL,
    [DiscAmt]        NUMERIC (18, 2) NULL,
    [RETAILING]      NUMERIC (18, 2) NULL,
    [flgOrderSource] TINYINT         NOT NULL,
    [StatusId]       TINYINT         NULL,
    CONSTRAINT [PK_tblTeleCallingInvDetail_1] PRIMARY KEY CLUSTERED ([TeleCallingId] ASC, [flgOrderSource] ASC, [PrdNodeId] ASC, [PrdNodeType] ASC, [InvNo] ASC, [InvDate] ASC)
);

