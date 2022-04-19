




--(PROD@7^2~9^2~79^4~80^4~81^4~14^2~19^2|10*1)#AND(VAL@NVAL^NVAL|2000*1)#OR(PROD@2^4~3^4~4^2~16^2~17^2|15*1)#AND(VAL@GVAL^GVAL|2000*1)


CREATE function [dbo].[SlabSplit](@str varchar(8000))
RETURNS @SlabDetail table(SlabSubBucketType char(4),NodeID varchar(10),NodeType varchar(10),ManufacturerId varchar(50),SlabSubBucketValue varchar(20),BucketID int,SubBucketID int,QtyType int)
AS
BEGIN


Declare @SlabMstr table (SlabID int identity(1,1),SlabDesc varchar(8000))
Declare @SlabMstrAnd table (SlabAndID int identity(1,1),SlabAndDesc varchar(8000),SlabID int)
set @str=Replace(@str,'(','')
set @str=Replace(@str,')','')
set @str=Replace(@str,'#AND','%')
set @str=Replace(@str,'#OR','$')
set @str=Replace(@str,'#M','<')
insert into @SlabMstr
select items FROM dbo.Split(@str,'$') where items<>''

Declare @strAnd varchar(8000),@i int, @cnt int

set @i=1
select @cnt=count(*) from @SlabMstr
while @i<=@cnt
begin
set @strAnd=''
select @strAnd=slabDesc from @SlabMstr where SlabID =@i
insert into @SlabMstrAnd(SlabAndDesc,SlabID)
select items,@i from dbo.Split(@strAnd,'%') where items<>''
set @i=@i+1
end

Declare @SlapType char(4),@NodeID varchar(10),@NodeType varchar(10),@Value varchar(20),@SlabID int,@strProd varchar(8000),@strSubBucketValue varchar(20)

set @i=1

select @cnt=count(*) from @SlabMstrAnd

while @i<=@cnt
begin
set @strAnd=''
set @SlabID=0
select @strAnd=slabAndDesc,@SlabID=SlabID from @SlabMstrAnd where SlabAndID =@i
SET @SlapType=Substring(@strAnd,0,CharIndex('@',@strAnd))
SET @strAnd= Substring(@strAnd,CharIndex('@',@strAnd)+1,LEN(@strAnd)-CharIndex('@',@strAnd))

SET @strProd=Substring(@strAnd,0,CharIndex('|',@strAnd))
SET @strAnd= Substring(@strAnd,CharIndex('|',@strAnd)+1,LEN(@strAnd)-CharIndex('|',@strAnd))

set @strSubBucketValue=Substring(@strAnd,0,CharIndex('*',@strAnd))
SET @strAnd= Substring(@strAnd,CharIndex('*',@strAnd)+1,LEN(@strAnd)-CharIndex('*',@strAnd))



insert into @SlabDetail(SlabSubBucketType,NodeID,NodeType,ManufacturerId,SlabSubBucketValue,BucketID,SubBucketID,QtyType)
select @SlapType,Substring(items,0,CharIndex('^',items)), Substring(items,CharIndex('^',items)+1,CharIndex('<',items)-CharIndex('^',items)-1),Substring(items,CharIndex('<',items)+1,LEN(items)-CharIndex('<',items)),@strSubBucketValue,@SlabID,@i,@strAnd from dbo.Split(@strProd,'~') where items<>''
set @i=@i+1
end
RETURN
END
