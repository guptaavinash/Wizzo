CREATE TYPE [dbo].[udt_RawDataSelectedManagerDetails] AS TABLE (
    [CurDate]     NVARCHAR (500) NULL,
    [IMEI]        NVARCHAR (500) NULL,
    [ManagerID]   NVARCHAR (500) NULL,
    [ManagerName] NVARCHAR (500) NULL,
    [ManagerType] NVARCHAR (500) NULL,
    [OtherName]   NVARCHAR (500) NULL,
    [PersonID]    NVARCHAR (500) NULL,
    [PersonName]  NVARCHAR (500) NULL,
    [PersonType]  NVARCHAR (500) NULL,
    [Sstat]       NVARCHAR (500) NULL);

