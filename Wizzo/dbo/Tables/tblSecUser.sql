CREATE TABLE [dbo].[tblSecUser] (
    [UserID]                             INT           IDENTITY (1, 1) NOT NULL,
    [NodeID]                             INT           NULL,
    [NodeType]                           SMALLINT      NULL,
    [UserName]                           NVARCHAR (50) NULL,
    [PwdStatus]                          INT           NULL,
    [Active]                             BIT           CONSTRAINT [DF_tblSecUser_Active] DEFAULT ((1)) NULL,
    [LoginType]                          TINYINT       NULL,
    [RoleID]                             TINYINT       NULL,
    [UserMail]                           VARCHAR (100) NULL,
    [IsAdminApprvSalesQuote]             BIT           NOT NULL,
    [LastUpdated]                        DATETIME      NULL,
    [UserFullName]                       VARCHAR (100) NULL,
    [IsDefaultTeleUserForHandlingO2Data] BIT           CONSTRAINT [DF_tblSecUser_IsDefaultTeleUserForHandlingO2Data] DEFAULT ((0)) NOT NULL,
    [CurrentActiveTime]                  DATETIME      NULL,
    [Password]                           VARCHAR (100) NULL,
    [IsFiveStarApplicable]               TINYINT       CONSTRAINT [DF__tblSecUse__IsFiv__58671BC9] DEFAULT ((0)) NOT NULL,
    [flgReleasingForTesting]             TINYINT       CONSTRAINT [DF__tblSecUse__flgRe__595B4002] DEFAULT ((0)) NOT NULL,
    CONSTRAINT [PK_tblSecUser] PRIMARY KEY CLUSTERED ([UserID] ASC)
);

