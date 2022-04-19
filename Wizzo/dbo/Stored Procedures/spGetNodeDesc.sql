

CREATE PROCEDURE [dbo].[spGetNodeDesc] --1,4,'',1

--		THIS SP is used to get node desc based on nodeid and node type

 @NodeID INT,  
 @NodeType INT,  
 @NodeDesc varchar(100) OUTPUT   ,
 @ISActive INT OUTPUT
  
AS  
  
 DECLARE @tblHier varChar(70)  
 DECLARE @tblDesc varChar(70)  
 DECLARE @strSQL varChar(900)  
 DECLARE @DataLevel TINYINT
DECLARE @FrmID INT
DECLARE @HierTypeID INT




EXEC spUTLGetSQLTblSource @NodeType,  @tblHier OUTPUT, @tblDesc OUTPUT, @FrmID OUTPUT, @HierTypeID OUTPUT
  
 --CREATE TABLE #tmpDescr (Descr varChar(100))  
CREATE TABLE #tmpDescr (Descr varChar(200),Name varchar(500),IsActive INT)  

PRINT '@NodeID= ' + CAST(@NodeID as varChar(10))
PRINT '@NodeID= ' + CAST(@NodeType as varChar(10))

		--SET @strSQL='INSERT INTO #tmpDescr SELECT Descr  FROM ' + @tblDesc + '  WHERE  NodeID=' + CAST(@NodeID as varChar(6)) 
IF @NodeType IN (100,110,120,130,160)		
BEGIN
	SELECT @NodeDesc=ISNULL(MAX(Descr),'VACANT') FROM tblMstrPerson SEM INNER JOIN tblSalesPersonMapping PM ON PM.PersonNodeID=SEM.NodeID
	WHERE PM.NodeID=@NodeID AND PM.NodeType=@NodeType AND GETDATE() BETWEEN PM.FROMDATE AND PM.ToDate

	--SELECT @NodeDesc=ISNULL(@NodeDesc,'VACANT')

	SET @strSQL='INSERT INTO #tmpDescr(Descr,IsActive) SELECT Descr  + '' (' + @NodeDesc + ')'',IsActive  FROM ' + @tblDesc + '  WHERE NodeID=' + CAST(@NodeID as varChar(6)) 
END
ELSE
BEGIN
	--IF @NodeType=40
	--BEGIN
	--	SET @strSQL='INSERT INTO #tmpDescr(Descr,IsActive) SELECT T.Descr + ''/'' + ISNULL(C.Descr,''NA''),T.IsActive  FROM ' + @tblDesc + ' T LEFT OUTER JOIN [tblPrdColourMstr] C ON C.NodeID=T.ColourID  WHERE T.NodeID=' + CAST(@NodeID as varChar(10)) 
	--END
	--ELSE
	--BEGIN
		SET @strSQL='INSERT INTO #tmpDescr(Descr,IsActive) SELECT Descr,IsActive  FROM ' + @tblDesc + '  WHERE NodeID=' + CAST(@NodeID as varChar(6)) 
	--END
END

	PRINT @strSQL
  EXEC (@strSQL)  
-- IF @NodeType IN (6,7)		
--BEGIN
-- SELECT @NodeDesc=Descr + ISNULL('(' + Name + ')',''),@ISActive = IsActive FROM #tmpDescr -- WHERE IsActive=1
--END
--ELSE
--BEGIN
SELECT @NodeDesc=Descr ,@ISActive = IsActive FROM #tmpDescr -- WHERE IsActive=1
--END





