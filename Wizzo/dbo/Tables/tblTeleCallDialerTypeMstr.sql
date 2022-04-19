CREATE TABLE [dbo].[tblTeleCallDialerTypeMstr] (
    [DialerTypeId] TINYINT       IDENTITY (1, 1) NOT NULL,
    [DialerType]   VARCHAR (100) NOT NULL,
    CONSTRAINT [PK_tblTeleCallDeviceMstr] PRIMARY KEY CLUSTERED ([DialerTypeId] ASC)
);

