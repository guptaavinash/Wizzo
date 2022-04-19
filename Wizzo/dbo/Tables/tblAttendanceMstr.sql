CREATE TABLE [dbo].[tblAttendanceMstr] (
    [AttenId]         INT      IDENTITY (1, 1) NOT NULL,
    [AttenDate]       DATE     NOT NULL,
    [ASMAreaNodeId]   INT      NOT NULL,
    [ASMAreaNodeType] INT      NOT NULL,
    [LoginIdIns]      INT      NOT NULL,
    [TimeStampIns]    DATETIME NOT NULL,
    [LoginIdUpd]      INT      NULL,
    [TimeStampUpd]    DATETIME NULL,
    CONSTRAINT [PK_tblAttendanceMstr] PRIMARY KEY CLUSTERED ([AttenId] ASC)
);

