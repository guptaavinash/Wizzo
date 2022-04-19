CREATE TABLE [dbo].[tblStoreContactUpdate] (
    [StoreID]         INT           NULL,
    [OutCnctPersonID] INT           NULL,
    [OTP]             VARCHAR (10)  NULL,
    [flgLock]         TINYINT       NULL,
    [TimestampIns]    SMALLDATETIME NULL,
    [TimestampUpd]    SMALLDATETIME NULL,
    [ContactNo]       BIGINT        NULL,
    [PersonNodeID]    INT           NULL,
    [PersonNodeType]  SMALLINT      NULL
);

