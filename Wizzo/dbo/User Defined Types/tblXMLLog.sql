CREATE TYPE [dbo].[tblXMLLog] AS TABLE (
    [IMEI]      VARCHAR (100) NULL,
    [TableName] VARCHAR (100) NULL,
    [TotRecord] INT           NULL,
    [Created]   DATETIME      NULL);

