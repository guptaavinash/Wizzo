-- =============================================
-- Author:		Avinash Gupta
-- Create date: 08Apr2015
-- Description:	Sp to Save the hierarchy Details
-- =============================================
-- [SpManageSalesHierarchy] 0,0,0,2,10,65,'FMCG|',2,20,3175
CREATE PROCEDURE [dbo].[SpManageSalesHierarchy] 
	@PNodeID INT =0 ,
	@PNodeType int = 0,
	@PHierID INT,
	@NodeID INT,
	@NodeType INT,
	@HierID INT,
	@strDetail VARCHAR(500),   --- This can contain all values that need to save against the Node. Ex : 'Descr|'
	@SecFlag TINYINT,
	@Lstlevel INT = 20,
	@LoginID INT
AS
BEGIN
	DECLARE @tblHier VARCHAR(50)
	DECLARE @tblDesc VARCHAR(50)
	DECLARE @FrameID INT
	DECLARE @HierTypeID INT
	DECLARE @PHierTypeID INT
	DECLARE @strSQL VARCHAR(4000)

	DECLARE @PHierId_Org INT=0
	DECLARE @FlgToOpenPopUp TINYINT=0
	DECLARE @FlgToManageStoreToDBRMapping TINYINT=0

	SELECT @PHierTypeID=HierTypeId FROM tblPMstNodeTypes WHERE NodeType=@PNodeType

	EXEC spUTLGetSQLTblSource @NodeType,  @tblHier OUTPUT, @tblDesc OUTPUT, @FrameID OUTPUT, @HierTypeID OUTPUT
	-- Code to update the Descr detail of Parent #######################################################
	PRINT '@HierTypeID=' + CAST(@HierTypeID As VARCHAR)
	IF ISNULL(@strDetail,'')<>''
	BEGIN
		IF ISNULL(@NodeID,0)<>0
		BEGIN
			SET @strSQL='UPDATE ' +  @tblDesc + ' SET Descr= ''' + SUBSTRING(@strDetail,1,PATINDEX('%|%',@strDetail)-1) + ''', LoginIDUpd=' + CAST(@LoginID as varChar) + ' , TimestampUpd=''' + CAST(getDate() AS VARCHAR) + ''' where NodeId=' +  CAST(@NodeID AS varChar)
			print @strSQL
			EXEC (@strSQL)
		END
		ELSE
		BEGIN
			SET @strSQL='INSERT INTO ' +  @tblDesc + '(Descr,LoginIDIns,NodeType) VALUES  (''' + SUBSTRING(@strDetail,1,PATINDEX('%|%',@strDetail)-1) + ''',' + CAST(@LoginID as varChar) + ',' + CAST(@NodeType as varChar) + ')'
			print @strSQL
			EXEC (@strSQL)
			SELECT @NodeID=@@IDENTITY
		END
	END	
	PRINT '@HierID=' + CAST(@HierID AS VARCHAR)
	PRINT '@tblHier=' + @tblHier
	PRINT CAST(@PHierID as varChar)
	PRINT CAST(@NodeId as varChar)
	PRINT CAST(@NodeType as varChar)
	PRINT CAST(@PNodeID  as varChar)
	PRINT CAST(@PNodeType as varChar)

	IF @HierID=0
		BEGIN
			SET @strSQL= 'INSERT INTO ' + @tblHier + ' (PHierID, NodeId, NodeType, PNodeID, PNodeType, HierTypeID,VldFrom,VldTo) VALUES (' + CAST(@PHierID as varChar) + ',' +  CAST(@NodeId as varChar) + ',' + CAST(@NodeType as varChar) + ','  + CAST(@PNodeID  as varChar) + ','  + CAST(@PNodeType as varChar)  + ','  + CAST(@HierTypeID  as varChar) + ',GetDate(),''2075-12-31'')'
			EXEC (@strSQL)
			PRINT @strSQL
			SET @HierID = @@IDENTITY
			PRINT '@HierID=' + CAST(@HierID AS VARCHAR)
			SELECT cast(isnull(@HierID,0) as varchar) + '|' + cast(isnull(@PHierID,0) as varchar) + '|' + cast(isnull(@NodeID,0) as varchar) + '|' + cast(isnull(@NodeType,0) as varchar) + '|' + cast(isnull(@PNodeID,0) as varchar) + '|' + cast(isnull(@PNodeType,0) as varchar) + '|20|' + cast(isnull(@SecFlag,0) as varchar) + '|0' AS PKey
		END
	ELSE
		BEGIN
			CREATE TABLE #ExistingParent(PNodeId INT,PNodeType INT,PHierId INT)
			SELECT @strSQL='SELECT PNodeId,PNodeType,PHierId  FROM ' +  @tblHier + ' WHERE HierID=' + CAST(@HierID  as varChar)
			PRINT @strSQL

			INSERT INTO #ExistingParent(PNodeId,PNodeType,PHierId)
			EXEC(@strSQL)
			--SELECT * FROM #ExistingParent

			SELECT @PHierId_Org=PHierId FROM #ExistingParent
			--SELECT @PHierId_Org


			IF @PHierId_Org<>@PHierId
			BEGIN
				IF EXISTS(SELECT 1 FROM tblSecMenuContextMenu WHERE NodeType=@NodeType AND (flgRoute=1 OR flgCoverageArea=1))
				BEGIN
					SET @FlgToManageStoreToDBRMapping=1
				END
				--SELECT @FlgToManageStoreToDBRMapping
				IF @FlgToManageStoreToDBRMapping=0
				BEGIN
					INSERT INTO tblCompanySalesStructureHierarchy_Backup(HierID,NodeID,NodeType,PNodeID,PNodeType,HierTypeID,PHierId,VldFrom,VldTo,LoginIdIns,TimeStampIns)
					SELECT HierID,NodeID,NodeType,PNodeID,PNodeType,HierTypeID,PHierId,VldFrom,DATEADD(dd,-1,GETDATE()),@LoginID,GETDATE()
					FROM tblCompanySalesStructureHierarchy WHERE HierID=@HierID

					SET @strSQL='UPDATE ' +  @tblHier + ' SET PHierID=' + CAST(@PHierID as varChar) + ',NodeId=' + CAST(@NodeId as varChar) + ', NodeType=' + CAST(@NodeType  as varChar) + ', PNodeID=' + CAST(@PNodeID as varChar) + ', PNodeType=' + CAST(@PNodeType as varChar) +  ', HierTypeID =' + CAST(@HierTypeID as varChar) + ',VldFrom=CAST(GETDATE() AS DATE)  WHERE HierID=' + CAST(@HierID  as varChar)
					PRINT @strSQL
					EXEC (@strSQL)
				END
				ELSE
				BEGIN
					IF @FlgToManageStoreToDBRMapping=1
					BEGIN
						EXEC [spManageStoreToDBRMappingOnTransfer] @PNodeID,@PNodeType,@PHierID,@NodeID,@NodeType,@HierID,@tblHier,@HierTypeID,@LoginID,@FlgToOpenPopUp OUTPUT
					END				
				END
			END
			ELSE
			BEGIN
				SELECT @FlgToOpenPopUp=0
				SET @strSQL='UPDATE ' +  @tblHier + ' SET PHierID=' + CAST(@PHierID as varChar) + ',NodeId=' + CAST(@NodeId as varChar) + ', NodeType=' + CAST(@NodeType  as varChar) + ', PNodeID=' + CAST(@PNodeID as varChar) + ', PNodeType=' + CAST(@PNodeType as varChar) +  ', HierTypeID =' + CAST(@HierTypeID as varChar) + '  WHERE HierID=' + CAST(@HierID  as varChar)
				PRINT @strSQL
				EXEC (@strSQL)
			END

			SELECT cast(isnull(@HierID,0) as varchar) + '|' + cast(isnull(@PHierID,0) as varchar) + '|' + cast(isnull(@NodeID,0) as varchar) + '|' + cast(isnull(@NodeType,0) as varchar) + '|' + cast(isnull(@PNodeID,0) as varchar) + '|' + cast(isnull(@PNodeType,0) as varchar) + '|' + CAST(ISNULL(@Lstlevel,0) AS VARCHAR) + '|' + cast(isnull(@SecFlag,0) as varchar) + '|0' AS PKey
		END

		SELECT @FlgToOpenPopUp AS FlgToOpenPopUp	
	---########################################################################################


	
END




