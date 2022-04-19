CREATE TABLE [dbo].[tblTCAttendanceDetail] (
    [TCAttendDetId] INT           IDENTITY (1, 1) NOT NULL,
    [TCAttendId]    INT           NOT NULL,
    [TeleCallerId]  INT           NOT NULL,
    [Absent]        TINYINT       CONSTRAINT [DF_tblTCAttendanceDetail_Absent] DEFAULT ((1)) NOT NULL,
    [AbsentReason]  VARCHAR (100) NULL,
    [LoginIdUpd]    INT           NULL,
    [TimeStampUpd]  DATETIME      NULL,
    CONSTRAINT [PK_tblTCAttendanceDetail] PRIMARY KEY CLUSTERED ([TCAttendDetId] ASC),
    CONSTRAINT [IX_tblTCAttendanceDetail] UNIQUE NONCLUSTERED ([TCAttendId] ASC, [TeleCallerId] ASC)
);

