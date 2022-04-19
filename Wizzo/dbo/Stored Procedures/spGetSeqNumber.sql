


CREATE proc [dbo].[spGetSeqNumber]
@SalesNodeId int,
@SalesNodeType int,
@Fyid int,
@TableUnqTag varchar(3),
@TableName varchar(50),
@ColumnName varchar(50)
as
begin
	if exists(select 1 from tblMstrSequenceForTrnTable 
	where TableName=@TableName and ColumnName=@ColumnName and TableUnqTag=@TableUnqTag and FYID=@FYID  and SalesNodeId=@SalesNodeId and SalesNodeType=@SalesNodeType)
	begin
		select InitialTag+right(REPLICATE('0',NumberLength)+CONVERT(varchar,LastGenNum+1),NumberLength)+'-'+convert(varchar,@FYID) from tblMstrSequenceForTrnTable 
		where TableName=@TableName and ColumnName=@ColumnName and TableUnqTag=@TableUnqTag and FYID=@FYID  and SalesNodeId=@SalesNodeId and SalesNodeType=@SalesNodeType
	end
	else
	begin
		select @TableUnqTag+'100001'+'-'+convert(varchar,@FYID)
	end
end





