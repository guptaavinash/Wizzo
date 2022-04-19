ALTER ROLE [db_datareader] ADD MEMBER [SupportSQLUser];


GO
ALTER ROLE [db_datareader] ADD MEMBER [appuser];


GO
ALTER ROLE [db_datawriter] ADD MEMBER [SupportSQLUser];


GO
ALTER ROLE [db_datawriter] ADD MEMBER [appuser];

