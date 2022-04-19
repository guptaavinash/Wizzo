CREATE TABLE [dbo].[tblTCAttendanceMstr] (
    [TCAttendId]   INT      IDENTITY (1, 1) NOT NULL,
    [AttndDate]    DATE     NOT NULL,
    [TSVNodeId]    INT      NOT NULL,
    [TSVNodeType]  INT      NOT NULL,
    [LoginIdIns]   INT      NOT NULL,
    [TimeStampIns] DATETIME NOT NULL,
    [LoginIdUpd]   INT      NULL,
    [TimeStampUpd] DATETIME NULL,
    CONSTRAINT [PK_tblTCAttendanceMstr] PRIMARY KEY CLUSTERED ([TCAttendId] ASC)
);

