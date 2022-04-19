CREATE TABLE [dbo].[tblSecUserLogin] (
    [LoginID]      INT          IDENTITY (1, 1) NOT NULL,
    [UserID]       INT          NOT NULL,
    [LoginTime]    DATETIME     CONSTRAINT [DF_tblSecUserLogin_LoginTime] DEFAULT (getdate()) NOT NULL,
    [Logouttime]   DATETIME     NULL,
    [SessionID]    VARCHAR (50) NULL,
    [IPAddress]    VARCHAR (50) NULL,
    [IsSessionEnd] TINYINT      NULL,
    [LoginType]    TINYINT      NULL,
    [LogOutSrc]    TINYINT      NULL,
    [IEVersion]    VARCHAR (50) NULL,
    [ScrRsltn]     VARCHAR (50) NULL,
    [CenterID]     INT          NULL,
    CONSTRAINT [PK_tblSecUserLogin] PRIMARY KEY CLUSTERED ([LoginID] ASC)
);

