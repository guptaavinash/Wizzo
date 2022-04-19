CREATE TYPE [dbo].[udtResponse_ASM] AS TABLE (
    [StoreVisitCode]      VARCHAR (100) NULL,
    [JointVisitCode]      VARCHAR (100) NULL,
    [StoreCheckVisitID]   INT           NULL,
    [JointVisitID]        INT           NULL,
    [flgApplicablemodule] TINYINT       NULL,
    [GrpQuestID]          INT           NULL,
    [QstID]               INT           NULL,
    [AnsControlTypeID]    TINYINT       NULL,
    [AnsValID]            VARCHAR (500) NULL,
    [AnsTextVal]          VARCHAR (500) NULL,
    [OptionValue]         VARCHAR (50)  NULL);

