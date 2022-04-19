CREATE TABLE [dbo].[tblReasonCodeMstr] (
    [ReasonCodeID]        INT            NOT NULL,
    [REASNCODE_LVL1NAME]  NVARCHAR (100) NOT NULL,
    [REASNCODE_LVL2NAME]  NVARCHAR (100) NOT NULL,
    [REASNFOR]            TINYINT        CONSTRAINT [DF_tblCFRReasonCodeMstr_REASNFOR] DEFAULT ((0)) NULL,
    [TIMESTAMP]           DATETIME       CONSTRAINT [DF_tblCFRReasonCodeMstr_TIMESTAMP] DEFAULT (getdate()) NOT NULL,
    [flgBilledQtyReject]  BIT            DEFAULT ((0)) NOT NULL,
    [flgReturnsReject]    BIT            DEFAULT ((0)) NOT NULL,
    [flgPickupReject]     BIT            DEFAULT ((0)) NOT NULL,
    [flgFullOrder]        BIT            DEFAULT ((0)) NOT NULL,
    [flgIndividualItem]   BIT            DEFAULT ((0)) NOT NULL,
    [flgOtherTransaction] BIT            DEFAULT ((0)) NOT NULL,
    [RptReasnLvl1]        NVARCHAR (100) NULL,
    [Sequence]            TINYINT        NULL,
    [flgRunningIssue]     TINYINT        NULL,
    [Lvl1Display]         VARCHAR (100)  NULL,
    [Lvl2Display]         VARCHAR (100)  NULL,
    CONSTRAINT [PK_tblCFRReasonCodeMstr] PRIMARY KEY CLUSTERED ([ReasonCodeID] ASC)
);

