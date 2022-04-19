
--Select * from tblQuestionDependentMstr  

-- [spGetPDAQuestionDependentMstr] 1  

  
CREATE PROCEDURE [dbo].[spGetPDAQuestionDependentMstr] --1  
  
@ApplicationID int  
  
AS  
  
BEGIN  

CREATE TABLE #QstnDepOption(QuestID INT,DependentQuestID INT,OptID VARCHAR(20),GrpQuestID INT,GrpDepQuestID INT)
INSERT INTO #QstnDepOption(QuestID ,DependentQuestID,OptID,GrpQuestID,GrpDepQuestID)
SELECT     Q.QuestID, D.DependentQuestID ,CAST(ISNULL(D.OptID,0) AS VARCHAR) + '-' + CAST(ISNULL(D.NodeID,0) AS VARCHAR) + '-' + CAST(ISNULL(D.NodeType,0) AS VARCHAR) AS OptID,D.GrpQuestID,D.GrpDepQuestID     
FROM         tblDynamic_PDAQuestMstr Q INNER JOIN  
tblDynamic_PDAQuestDependentMstr D ON Q.QuestID=D.QuestID   
Where Q.ActiveQuest=1 AND ISNULL(Q.AnsSourceOptionDep,0)<>1 
ORDER BY Q.QuestID


--Entry for Master question
INSERT INTO #QstnDepOption(QuestID ,DependentQuestID,OptID,GrpQuestID,GrpDepQuestID)
SELECT     Q.QuestID, D.DependentQuestID ,CAST(ISNULL(D.OptID,0) AS VARCHAR) + '-' + CAST(ISNULL(D.NodeID,0) AS VARCHAR) + '-' + CAST(ISNULL(D.NodeType,0) AS VARCHAR) AS OptID,D.GrpQuestID,D.GrpDepQuestID     
FROM         tblDynamic_PDAQuestMstr Q INNER JOIN  
tblDynamic_PDAQuestDependentMstr D ON Q.QuestID=D.QuestID  
INNER JOIN tblDynamic_PDAQuestDepOptionsMstr OD ON OD.DepQstId=Q.QuestID
Where Q.ActiveQuest=1 AND ISNULL(Q.AnsSourceOptionDep,0)=1  ORDER BY Q.QuestID

--WHERE tblDynamic_PDAQuestMstr.ApplicationTypeID=@ApplicationID  

CREATE TABLE #tblLoop(ID INT IDENTITY(1,1), QuestID INT ,DependentQuestID INT,GrpQuestID INT,GrpDepQuestID INT,Nodeid INT,Nodetype SMAllINT,flgOptionAreaDependent TINYINT)
INSERT INTO #tblLoop( QuestID ,DependentQuestID,GrpQuestID,GrpDepQuestID,Nodeid,Nodetype,flgOptionAreaDependent)
SELECT     Q.QuestID, D.DependentQuestID ,D.GrpQuestID,D.GrpDepQuestID,D.NodeID,D.NodeType,Q.flgOptionAreaDependent     
FROM         tblDynamic_PDAQuestMstr Q INNER JOIN  
tblDynamic_PDAQuestDependentMstr D ON Q.QuestID=D.QuestID   
INNER JOIN tblDynamic_PDAQuestDepOptionsMstr DO ON DO.QstId=Q.QuestID
Where Q.ActiveQuest=1 AND Q.AnsSourceOptionDep=1
ORDER BY Q.QuestID

	DECLARE @CurrentNodeType SMALLINT 
	DECLARE @ParentNodeType SMALLINT 
	DECLARE @tablename VARCHAR(200)  
	DECLARE @DetTableColumnname VARCHAR(200)  
	DECLARE @DetTableIDColumn VARCHAR(200)
	DECLARE @Parenttablename VARCHAR(200)  
	DECLARE @ParentDetTableColumnname VARCHAR(200)  
	DECLARE @ParentDetTableIDColumn VARCHAR(200)
	DECLARE @IsPartHierarchy TINYINT --0=No,1=Yes
	DECLARE @HierarchyTable VARCHAR(200) 
	DECLARE @MAXID INT  
	DECLARE @Count INT  
	DECLARE @QuestID INT 
	DECLARE @DepQuestID INT 
	DECLARE @GrpQuestID INT 
	DECLARE @GrpDepQuestID INT 
	DECLARE @DepNodeID INT
	DECLARE @DepNodeType SMALLINT
	DECLARE @flgOptionAreaDependent TINYINT
	DECLARE @SQL VARCHAR(MAX)=''  
	SET @Count=1 

	SELECT @MAXID=MAX(ID) FROM #tblLoop  
	PRINT '@MAXID' + CAST(@MAXID AS VARCHAR)  
	WHILE (@MAXID>=@Count)  
	BEGIN  
		PRINT '@Count' + CAST(@Count AS VARCHAR)  
		SELECT @QuestID=QuestID,@DepQuestID=DependentQuestID,@GrpQuestID=GrpQuestID,@GrpDepQuestID=GrpDepQuestID,@DepNodeID=Nodeid,@DepNodeType=Nodetype,@flgOptionAreaDependent=flgOptionAreaDependent FROM #tblLoop WHERE ID=@Count  
		SELECT @CurrentNodeType=AnsSourceNodeType FROM tblDynamic_PDAQuestMstr WHERE QuestID=@QuestID AND tblDynamic_PDAQuestMstr.ActiveQuest=1 
		SELECT @ParentNodeType= AnsSourceNodeType FROM tblDynamic_PDAQuestMstr WHERE QuestID=@DepQuestID AND tblDynamic_PDAQuestMstr.ActiveQuest=1 

		SELECT @tablename=DetTable,@DetTableColumnname=Dettablenamedcolumn,@DetTableIDColumn=Deltableidcolumn,@IsPartHierarchy=CASE ISNULL(Hierarchytable,'') WHEN '' THEN 0 ELSE 1 END ,@HierarchyTable=Hierarchytable FROM tblPMstNodeTypes WHERE NodeType=@CurrentNodeType 
		SELECT @Parenttablename=DetTable,@ParentDetTableColumnname=Dettablenamedcolumn,@ParentDetTableIDColumn=Deltableidcolumn FROM tblPMstNodeTypes WHERE NodeType=@ParentNodeType
	  
		PRINT '@tablename=' + @tablename  
		PRINT '@tablename=' + @Parenttablename 
		PRINT '@ParentDetTableIDColumn=' + @ParentDetTableIDColumn 

		IF @DepNodeID IS NULL
		BEGIN
			SET @SQL='INSERT INTO #QstnDepOption(QuestID,DependentQuestID,OptID,GrpQuestID,GrpDepQuestID)'  
			SET @SQL=@SQL + 'SELECT DISTINCT ' +  CAST(@QuestID AS VARCHAR) + ',' + CAST(@DepQuestID AS VARCHAR) + ',' + '''0-''+CAST(' + @Parenttablename + '.' + @ParentDetTableIDColumn  + ' AS VARCHAR) +''-' + CAST(@ParentNodeType AS VARCHAR) + ''',' + CAST(@GrpQuestID AS VARCHAR) + ',' + CAST(@GrpDepQuestID AS VARCHAR) + ' FROM ' + @Parenttablename
		END
		ELSE
		BEGIN
			SET @SQL='INSERT INTO #QstnDepOption(QuestID,DependentQuestID,OptID,GrpQuestID,GrpDepQuestID)'  
			SET @SQL=@SQL + 'SELECT DISTINCT ' +  CAST(@QuestID AS VARCHAR) + ',' + CAST(@DepQuestID AS VARCHAR) + ',''0-' + CAST(@DepNodeID AS VARCHAR) + '-' + CAST(@DepNodeType AS VARCHAR) + ''',' + CAST(@GrpQuestID AS VARCHAR) + ',' + CAST(@GrpDepQuestID AS VARCHAR) + ' FROM ' + @Parenttablename
		END

		 PRINT '@SQL=' + @SQL  
		 EXEC (@SQL)  
		 SET @Count=@Count + 1  
	END

	SELECT * FROM #QstnDepOption ORDER BY 1
  
END


