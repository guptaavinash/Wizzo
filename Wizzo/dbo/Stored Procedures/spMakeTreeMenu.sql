


--[spMakeTreeMenu]  0,15222

CREATE procEDURE [dbo].[spMakeTreeMenu] 

	@MenuNode SMALLINT,
	@LoginID INT

AS

 	DECLARE @UserID INT  
 	DECLARE @NodeID INT
	DECLARE @NodeType INT 
 
EXEC spUTLGetUserDetailsFromLoginID @LoginID, @UserID OUTPUT,  @NodeID OUTPUT, @NodeType OUTPUT
  --Drop Table tmpHierTable
 CREATE TABLE #tmpHierTable  
--CREATE TABLE tmpHierTable
 (  
  [HierId] [SMALLINT],  --MnuId
  [Descr] [varChar] (100),  
  [PHierID] [SMALLINT],  --ParentMnuId
  [IsLastLevel] [TINYINT],  
  [OrdrNum] [SMALLINT],
  [IndexNum][varChar] (20),
  [IndexNumP][varChar] (20),
 )  

PRINT   '@UserID=' + CAST(@UserID as varChar(10))
PRINT '@MenuNode=' + CAST(@MenuNode AS VARCHAR)
EXEC spMakeTreeMenuSub @MenuNode, @UserID
INSERT INTO #tmpHierTable ([HierId],[PhierId],Descr, [IsLastLevel], IndexNum) VALUES (0,0,'Menu',10,0)


EXEC   spMakeIndxNumbers 0
--UPDATE #tmpHierTable SET PHierID=NULL WHERE PHierID=0


--Delete #tmpHierTable where [HierId]=28 and @flgDRCPUploadType=2
--Delete #tmpHierTable where [HierId]=31 and @IsMappedLeapSwing=1
--Delete #tmpHierTable where [HierId]=29 and @IsMappedLeapSwing=2
--Declare @flgActivePOProcess tinyint=0 
--select @flgActivePOProcess=flgActivePOProcess from tblDBRSalesStructureDBR where nodeid=@NodeID
--SELECT * FROM #tmpHierTable where (@flgActivePOProcess=1 and HierId<>51) or @flgActivePOProcess=0 ORDER BY OrdrNum

--end
--else
--begin
SELECT * FROM #tmpHierTable  ORDER BY OrdrNum
--end
