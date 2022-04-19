CREATE TYPE [dbo].[udt_OutletContactDet] AS TABLE (
    [OutCnctPersonID]     INT           NULL,
    [OutCnctPersonTypeID] INT           NULL,
    [FName]               VARCHAR (200) NULL,
    [Lname]               VARCHAR (200) NULL,
    [LandLineNo1]         VARCHAR (20)  NULL,
    [Extn1]               VARCHAR (10)  NULL,
    [LandLine2]           VARCHAR (20)  NULL,
    [Extn2]               VARCHAR (10)  NULL,
    [MobNo]               BIGINT        NULL,
    [EMailID]             VARCHAR (200) NULL,
    [flgAction]           TINYINT       NOT NULL);

