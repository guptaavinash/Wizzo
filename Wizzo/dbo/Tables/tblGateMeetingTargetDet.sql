CREATE TABLE [dbo].[tblGateMeetingTargetDet] (
    [PersonMeetingDetID] INT             IDENTITY (1, 1) NOT NULL,
    [PersonMeetingID]    INT             NULL,
    [SKUNodeID]          INT             NULL,
    [SKUNodeType]        SMALLINT        NULL,
    [Sales_Tgt]          NUMERIC (10, 4) NULL,
    [Dstrbn_Tgt]         INT             NULL
);

