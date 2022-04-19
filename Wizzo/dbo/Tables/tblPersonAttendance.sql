CREATE TABLE [dbo].[tblPersonAttendance] (
    [PersonAttendanceID]                    INT             IDENTITY (1, 1) NOT NULL,
    [PersonNodeID]                          INT             NOT NULL,
    [PersonNodeType]                        SMALLINT        NOT NULL,
    [Address]                               VARCHAR (1000)  NULL,
    [Lat Code]                              DECIMAL (18, 6) NULL,
    [Long Code]                             DECIMAL (18, 6) NULL,
    [Accuracy]                              FLOAT (53)      NULL,
    [AllProvidersLocation]                  VARCHAR (MAX)   NULL,
    [Datetime]                              DATETIME        NOT NULL,
    [TimestampIns]                          DATETIME        NULL,
    [TimestampUpd]                          DATETIME        NULL,
    [VisitID]                               INT             NULL,
    [IMEINo]                                VARCHAR (50)    NULL,
    [Comments]                              VARCHAR (200)   NULL,
    [DBNodeID]                              INT             NULL,
    [DBNodeType]                            INT             NULL,
    [flgLocationServicesOnOff]              TINYINT         NULL,
    [flgGPSOnOff]                           TINYINT         NULL,
    [flgNetworkOnOff]                       TINYINT         NULL,
    [flgFusedOnOff]                         TINYINT         NULL,
    [flgInternetOnOffWhileLocationTracking] TINYINT         NULL,
    [XMLFileSetID]                          INT             NULL,
    [BatteryStatus]                         INT             NULL,
    [City]                                  VARCHAR (200)   NULL,
    [PinCode]                               VARCHAR (10)    NULL,
    [State]                                 VARCHAR (200)   NULL,
    [MapAddress]                            VARCHAR (200)   NULL,
    [MapPinCode]                            VARCHAR (10)    NULL,
    [MapCity]                               VARCHAR (200)   NULL,
    [MapState]                              VARCHAR (200)   NULL,
    [IsNetworkTimeRecorded]                 TINYINT         NULL,
    [OSVersion]                             VARCHAR (200)   NULL,
    [DeviceID]                              VARCHAR (20)    NULL,
    [BrandName]                             VARCHAR (200)   NULL,
    [Model]                                 VARCHAR (200)   NULL,
    [DeviceDatetime]                        DATETIME        NULL,
    [ApprovalPersonNodeID]                  INT             NULL,
    [ApprovalPersonNodeType]                SMALLINT        NULL,
    [ApprovalLoginID]                       INT             NULL,
    [ApproveactionTime]                     DATETIME        NULL,
    [ApprovalIMEINo]                        VARCHAR (100)   NULL,
    [flgApprove]                            TINYINT         NULL,
    [SelfieName]                            VARCHAR (200)   NULL,
    CONSTRAINT [PK_tblPersonAttendance] PRIMARY KEY CLUSTERED ([PersonAttendanceID] ASC)
);


GO
CREATE NONCLUSTERED INDEX [IX_tblPersonAttendance]
    ON [dbo].[tblPersonAttendance]([PersonNodeID] ASC, [PersonNodeType] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_tblPersonAttendance_1]
    ON [dbo].[tblPersonAttendance]([Datetime] ASC);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'1=Approve,2=Reject', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblPersonAttendance', @level2type = N'COLUMN', @level2name = N'flgApprove';

