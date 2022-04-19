CREATE proc [dbo].[spSetIdentitySeedAgainstTAble]
as
begin
SELECT identity(int,1,1) as ident,
OBJECT_SCHEMA_NAME(tables.object_id, db_id())
	AS SchemaName,
	tables.name As TableName,
	columns.name as ColumnName,
	IDENT_SEED(OBJECT_SCHEMA_NAME(tables.object_id, db_id()) + '.' + tables.name) 
	AS Seed,
	IDENT_INCR(OBJECT_SCHEMA_NAME(tables.object_id, db_id()) + '.' + tables.name) 
	AS Increment,
	IDENT_CURRENT(OBJECT_SCHEMA_NAME(tables.object_id, db_id()) + '.' + tables.name) 
	AS Current_Identity into #tables
FROM sys.tables tables 
	JOIN sys.columns columns 
ON tables.object_id=columns.object_id
WHERE columns.is_identity=1

Declare @i int,@cnt int,@TableName varchar(200),@col varchar(200),@MaxId int,@SqlStr nvarchar(1000)

Declare  @tblMax  table(id int)   
set @i=1

select @cnt=count(*) from #tables

while @i<=@cnt
begin

delete @tblMax

select @TableName=TableName,@col=ColumnName from #tables where ident=@i


set @SqlStr='select isnull(max(['+@col+']),1) from ['+@TableName+'] '


insert into @tblMax
exec sp_executesql @SqlStr
set @MaxId=0
select @MaxId=id from @tblMax

select @TableName,@MaxId,@col
DBCC CHECKIDENT (@TableName, RESEED, @MaxId); 


set @i=@i+1
end

end