CREATE TABLE [dbo].[tblWhatsAppAPI_RegisteredCustomer] (
    [ID]                   INT          IDENTITY (1, 1) NOT NULL,
    [RegistrationID]       VARCHAR (10) NULL,
    [CustomerMobNo]        BIGINT       NULL,
    [CustomerNodeID]       INT          NULL,
    [CustomerNodeType]     SMALLINT     NULL,
    [flgRegistered]        TINYINT      NULL,
    [RegisteredDatetime]   DATETIME     NULL,
    [UnregisteredDatetime] DATETIME     NULL
);

