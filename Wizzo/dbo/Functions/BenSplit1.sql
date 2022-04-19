


create function [dbo].[BenSplit1](@str varchar(3000))
RETURNS  @BenDetail table(BucketID int,BenSubBucketType int,NodeId varchar(20),NodeType varchar(20),ManufacturerId varchar(50),BenSubBucketValue varchar(1000),BenSubBucketDiscValue varchar(1000),SubBucketID int,CounponID varchar(10),Per varchar(10),UOM varchar(10),PRORata varchar(1))
BEGIN

Declare @BenMstr table (BenId int identity(1,1),BenDesc varchar(1000))
Declare @BenMstrAnd table (BenAndID int identity(1,1),BenAndDesc varchar(1000),BenId int)
set @str=Replace(@str,'(','')
set @str=Replace(@str,')','')
set @str=Replace(@str,'#AND','&')
set @str=Replace(@str,'#OR','*')
set @str=Replace(@str,'#M','<')

insert into @BenMstr
select items FROM dbo.Split(@str,'*') where items<>''


Declare @strAnd varchar(1000),@i int, @cnt int

set @i=1
select @cnt=count(*) from @BenMstr
while @i<=@cnt
begin
set @strAnd=''
select @strAnd=BenDesc from @BenMstr where BenId =@i
insert into @BenMstrAnd(BenAndDesc,BenId)
select items,@i from dbo.Split(@strAnd,'&') where items<>''
set @i=@i+1
end




Declare @BenType int,@NodeID varchar(20),@NodeType varchar(20),@Value varchar(1000),@BenId int,@strCoup varchar(100),@strProdval varchar(300),@strProd varchar(100),
@strDisc varchar(100),@DiscApplied varchar(10),@DiscValue varchar(1000),@strPer varchar(50),@strProRata varchar(2)

set @i=1

select @cnt=count(*) from @BenMstrAnd

while @i<=@cnt
begin
set @strAnd=''
set @BenId=0
select @strAnd=BenAndDesc,@BenId=BenId from @BenMstrAnd where BenAndID =@i

SET @BenType=Substring(@strAnd,0,CharIndex('@',@strAnd))
SET @strAnd= Substring(@strAnd,CharIndex('@',@strAnd)+1,LEN(@strAnd)-CharIndex('@',@strAnd))


SET @strProdval=Substring(@strAnd,0,CharIndex('@',@strAnd))
SET @strAnd= Substring(@strAnd,CharIndex('@',@strAnd)+1,LEN(@strAnd)-CharIndex('@',@strAnd))

SET @strDisc=Substring(@strAnd,0,CharIndex('@',@strAnd))
SET @strAnd= Substring(@strAnd,CharIndex('@',@strAnd)+1,LEN(@strAnd)-CharIndex('@',@strAnd))


SET @strCoup=Substring(@strAnd,0,CharIndex('@',@strAnd))
SET @strAnd= Substring(@strAnd,CharIndex('@',@strAnd)+1,LEN(@strAnd)-CharIndex('@',@strAnd))



if @strAnd like '%@%'
begin
SET @strPer=Substring(@strAnd,0,CharIndex('@',@strAnd))
SET @strAnd= Substring(@strAnd,CharIndex('@',@strAnd)+1,LEN(@strAnd)-CharIndex('@',@strAnd))
set @strProRata=@strAnd
end
else
begin
SET @strPer=@strAnd
set @strProRata='0'
end
--select @BenType,@strProdval,@strDisc,@strCoup,@strPer


SET @strProd=Substring(@strProdval,0,CharIndex('|',@strProdval))
SET @strProdval= Substring(@strProdval,CharIndex('|',@strProdval)+1,LEN(@strProdval)-CharIndex('|',@strProdval))

set @DiscApplied=''

set @DiscValue=''
if @strDisc<>''
begin
	select @DiscValue=@strDisc
end

insert into @BenDetail(BenSubBucketType,NodeID,NodeType,ManufacturerId,BenSubBucketValue,BenSubBucketDiscValue,BucketID,SubBucketID,CounponID,Per,UOM,PRORata)
select @BenType,Substring(items,0,CharIndex('^',items)), Substring(items,CharIndex('^',items)+1,CharIndex('<',items)-CharIndex('^',items)-1),Substring(items,CharIndex('<',items)+1,LEN(items)-CharIndex('<',items)),@strProdval,@DiscValue,@BenId,@i,'',Substring(@strPer,0,CharIndex('^',@strPer)),Substring(@strPer,CharIndex('^',@strPer)+1,LEN(@strPer)-CharIndex('^',@strPer)),@strProRata from dbo.Split(@strProd,'~') where items<>''

if (@BenType=8 or @BenType=9 or @BenType=6 or @BenType=7 or @BenType=10) and @strProd=''
BEGIN
insert into @BenDetail(BenSubBucketType,NodeID,NodeType,ManufacturerId,BenSubBucketValue,BenSubBucketDiscValue,BucketID,SubBucketID,CounponID,Per,UOM,PRORata)
select @BenType,'','','','',@DiscValue,@BenId,@i,'',Substring(@strPer,0,CharIndex('^',@strPer)),Substring(@strPer,CharIndex('^',@strPer)+1,LEN(@strPer)-CharIndex('^',@strPer)),@strProRata

END

if @BenType=4
BEGIN
insert into @BenDetail(BenSubBucketType,NodeID,NodeType,ManufacturerId,BenSubBucketValue,BenSubBucketDiscValue,BucketID,SubBucketID,CounponID,Per,UOM,PRORata)
select @BenType,'','','','','',@BenId,@i,@strCoup,Substring(@strPer,0,CharIndex('^',@strPer)),Substring(@strPer,CharIndex('^',@strPer)+1,LEN(@strPer)-CharIndex('^',@strPer)),@strProRata
END

if @BenType=5
BEGIN
insert into @BenDetail(BenSubBucketType,NodeID,NodeType,ManufacturerId,BenSubBucketValue,BenSubBucketDiscValue,BucketID,SubBucketID,CounponID,Per,UOM,PRORata)
select @BenType,'','','',@strProdval,'',@BenId,@i,'',Substring(@strPer,0,CharIndex('^',@strPer)),Substring(@strPer,CharIndex('^',@strPer)+1,LEN(@strPer)-CharIndex('^',@strPer)),@strProRata
END

--if @BenType=6 and @strProd=''
--BEGIN
--insert into @BenDetail(BenSubBucketType,NodeID,NodeType,BenSubBucketValue,BenSubBucketDiscValue,BucketID,SubBucketID,CounponID,Per,UOM)
--select @BenType,'','','',@DiscValue,@BenId,@i,'',Substring(@strPer,0,CharIndex('^',@strPer)),Substring(@strPer,CharIndex('^',@strPer)+1,LEN(@strPer)-CharIndex('^',@strPer))
--END

--if @BenType=7 and @strProd=''
--BEGIN
--insert into @BenDetail(BenSubBucketType,NodeID,NodeType,BenSubBucketValue,BenSubBucketDiscValue,BucketID,SubBucketID,CounponID,Per,UOM)
--select @BenType,'','','',@DiscValue,@BenId,@i,'',Substring(@strPer,0,CharIndex('^',@strPer)),Substring(@strPer,CharIndex('^',@strPer)+1,LEN(@strPer)-CharIndex('^',@strPer))
--END

set @i=@i+1
end
RETURN
END
