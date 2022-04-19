
CREATE proc [dbo].[spGetAllXMLFilesFromFolder]
as
begin
Declare @SourcePath varchar(500),@SuccessPath varchar(500),@ErrorPath varchar(500),@IncorrectImei varchar(500)

set @SourcePath='F:\ApplicationData\SFAData\RajTraders_Live\XML_Files\SFA_XML\'
set @SuccessPath='F:\ApplicationData\SFAData\RajTraders_Live\XML_Files\Success'
set @ErrorPath='F:\ApplicationData\SFAData\RajTraders_Live\XML_Files\Error'
set @IncorrectImei='F:\ApplicationData\SFAData\RajTraders_Live\XML_Files\IncorrectIMEI'

IF OBJECT_ID('tempdb..#DirectoryTree') IS NOT NULL
      DROP TABLE #DirectoryTree;

CREATE TABLE #DirectoryTree (Id int identity(1,1), 
       subdirectory nvarchar(512)
      ,depth int
      ,isfile bit);

	  
IF OBJECT_ID('tempdb..#XMLFile') IS NOT NULL
      DROP TABLE #XMLFile;

CREATE TABLE #XMLFile(Id int identity(1,1), 
       FileName varchar(100));


INSERT #DirectoryTree (subdirectory,depth,isfile)
EXEC master.sys.xp_dirtree @SourcePath,1,1;

insert into #XMLFile 
SELECT subdirectory FROM #DirectoryTree
WHERE isfile = 1 AND RIGHT(subdirectory,4) = '.xml'
ORDER BY id;

Declare @i int,@cnt int,@FileName varchar(100),@flgExecuted tinyint,@MovePathString varchar(1000),@PDACode varchar(100)

set @i=1
select @cnt=count(*) from #XMLFile

while @i<=@cnt AND @i<=30
begin
SELECT @PDACode='',@FileName=NULL
select @FileName=FileName from #XMLFile where id=@i
SELECT @PDACode=SUBSTRING(@FileName,0,PATINDEX('%.%',@FileName))
--select @FileName=FileName from #XMLFile where id=@i


--select top 1 @Imei=items from dbo.split(@FileName,'.') where items<>''

--SELECT @Imei=SUBSTRING(@Filename,0,PATINDEX('%.%',@Filename))

--if  exists(select top 1 1 from tblPdamaster where pda_imei=@Imei or pda_imei_sec=@Imei)
begin
set @flgExecuted=0
exec spReadXMLFile @SourcePath,1,0,@FileName,@flgExecuted output,@PDACode



	if @flgExecuted=1
	begin
		set @MovePathString='move '+@SourcePath+'\'+@FileName+' '+@SuccessPath
	end
	else
	begin
		set @MovePathString='move '+@SourcePath+'\'+@FileName+' '+@ErrorPath
	end
end
--else
--begin
--	set @MovePathString='move '+@SourcePath+'\'+@FileName+' '+@IncorrectImei
--end

print @MovePathString
exec master.dbo.xp_cmdshell @MovePathString

set @i=@i+1
end

end
