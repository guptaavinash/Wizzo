CREATE TABLE [dbo].[tblAttendanceDet] (
    [AttendDetId]    INT      IDENTITY (1, 1) NOT NULL,
    [AttendId]       INT      NOT NULL,
    [SOAreaNodeId]   INT      NOT NULL,
    [SOAreaNodeType] INT      NOT NULL,
    [RouteNodeId]    INT      NOT NULL,
    [RouteNodetype]  INT      NOT NULL,
    [Absent]         TINYINT  CONSTRAINT [DF_tblAttendanceDet_Absent] DEFAULT ((1)) NOT NULL,
    [VisitDate]      DATE     NOT NULL,
    [LoginIdIns]     INT      NOT NULL,
    [TimeStampIns]   DATETIME NOT NULL,
    [LoginIdUpd]     INT      NULL,
    [TimeStampUpd]   DATETIME NULL,
    CONSTRAINT [PK_tblAttendanceDet] PRIMARY KEY CLUSTERED ([AttendDetId] ASC),
    CONSTRAINT [FK_tblAttendanceDet_tblAttendanceMstr] FOREIGN KEY ([AttendId]) REFERENCES [dbo].[tblAttendanceMstr] ([AttenId]) ON DELETE CASCADE ON UPDATE CASCADE
);

