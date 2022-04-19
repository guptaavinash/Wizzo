CREATE TABLE [dbo].[tblPDAOutletQstResponseMaster] (
    [StoreIDDB]        INT            NOT NULL,
    [GrpQuestID]       INT            NOT NULL,
    [QstId]            INT            NOT NULL,
    [AnsControlTypeID] INT            NULL,
    [AnsValId]         VARCHAR (200)  NULL,
    [AnsTextVal]       NVARCHAR (MAX) NULL,
    [TimeStampIn]      SMALLDATETIME  NOT NULL,
    [OptionValue]      VARCHAR (50)   NULL
);

