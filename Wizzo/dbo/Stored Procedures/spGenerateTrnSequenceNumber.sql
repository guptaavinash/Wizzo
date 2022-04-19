

CREATE PROCEDURE [dbo].[spGenerateTrnSequenceNumber] 
@TableName varchar(50),
@ColumnName varchar(50),
@TableUnqTag varchar(3),
@FYID int,
@SalesNodeId int,
@SalesNodeType int,
@SeqNo int output,
@NextGeneratedNumber varchar(50) output
as
set @NextGeneratedNumber=''
if not exists (select * from tblMstrSequenceForTrnTable where TableName=@TableName and ColumnName=@ColumnName and TableUnqTag=@TableUnqTag and FYID=@FYID and SalesNodeId=@SalesNodeId and SalesNodeType=@SalesNodeType)
begin
insert into tblMstrSequenceForTrnTable values(@TableName,@ColumnName,@TableUnqTag,@FYID,@SalesNodeId,@SalesNodeType,@TableUnqTag,6,100001)
end
else
begin
UPDATE tblMstrSequenceForTrnTable set LastGenNum=LastGenNum+1 where TableName=@TableName and ColumnName=@ColumnName and FYID=@FYID and TableUnqTag=@TableUnqTag   and SalesNodeId=@SalesNodeId and SalesNodeType=@SalesNodeType
end
Declare @FYYearSuffix varchar(5)=@FYID
select @FYYearSuffix=YearSuffix from tblFinancialYear where FYID=@FYID
select @NextGeneratedNumber=InitialTag+right(REPLICATE('0',NumberLength)+CONVERT(varchar,LastGenNum),NumberLength)+'/'+@FYYearSuffix,@SeqNo=LastGenNum from tblMstrSequenceForTrnTable 
where TableName=@TableName and ColumnName=@ColumnName and TableUnqTag=@TableUnqTag and FYID=@FYID  and SalesNodeId=@SalesNodeId and SalesNodeType=@SalesNodeType




