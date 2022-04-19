CREATE TYPE [dbo].[udtResponse] AS TABLE (
    [GrpQuestID]       INT           NOT NULL,
    [QstID]            INT           NULL,
    [AnsControlTypeID] TINYINT       NULL,
    [AnsValID]         VARCHAR (500) NULL,
    [AnsTextVal]       VARCHAR (500) NULL,
    [OptionValue]      VARCHAR (50)  NULL);

