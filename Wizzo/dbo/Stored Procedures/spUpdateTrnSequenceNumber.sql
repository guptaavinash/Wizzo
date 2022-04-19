

CREATE Proc [dbo].[spUpdateTrnSequenceNumber] 
@TableName varchar(50),
@ColumnName varchar(50),
@TableUnqTag varchar(3),
@FYID int,
@SalesNodeId int,
@SalesNodeType int,
@LastGeneratedNum INT

as
if not exists (select * from tblMstrSequenceForTrnTable_Direct where TableName=@TableName and ColumnName=@ColumnName and TableUnqTag=@TableUnqTag and FYID=@FYID and SalesNodeId=@SalesNodeId and SalesNodeType=@SalesNodeType)
begin
insert into tblMstrSequenceForTrnTable_Direct values(@TableName,@ColumnName,@TableUnqTag,@FYID,@SalesNodeId,@SalesNodeType,@TableUnqTag,4,1000)
end
else
begin
UPDATE tblMstrSequenceForTrnTable_Direct set LastGenNum=@LastGeneratedNum where TableName=@TableName and ColumnName=@ColumnName and FYID=@FYID and TableUnqTag=@TableUnqTag   and SalesNodeId=@SalesNodeId and SalesNodeType=@SalesNodeType AND LastGenNum<@LastGeneratedNum

end





