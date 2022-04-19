-- =============================================
-- Author:		Avinash Gupta
-- Create date: 09Apr2015
-- Description:	Sp to Map the Channels against the Product Hierarchy.
-- =============================================

-- SpManageSalesChannelMapping 1,5,'1^1^0^|2^0^0^|','19-Aug-2015',267
CREATE PROCEDURE [dbo].[SpManageSalesChannelMapping] --2,10,'1^0|2^1|','10-Apr-2015',3129
	-- Add the parameters for the stored procedure here
	@NodeID INT,
	@NodeType INT, 
	@StrChannelID VARCHAR(500),  -- Channel1^flgAddDelete^@flgChannelSub^NodeType1$NodeID1,NodeID2,...#NodeType2$NodeID1,NodeID2,...|Channel2^flgAddDelete.....
	@ApplicableFromDate DATETIME,
	@LoginID INT
	
AS
BEGIN
	DECLARE @ChildNodeID INT
	DECLARE @ChildNodeType INT
	DECLARE @ChannelID INT
	DECLARE @flgAddDelete TINYINT
	DECLARE @flgChannelSub TINYINT
	DECLARE @strNodeTypes VARCHAR(50)
	DECLARE @StrChannelIDDet VARCHAR(500)
	DECLARE @StrSQL VARCHAR(500)
	DECLARE @StrChannelIDTemp VARCHAR(MAX)
	SET @StrChannelIDTemp=@StrChannelID

	;WITH CTEAllChilds AS 
	( 
	--initialization 
	SELECT NodeID, NodeType, HierID ,PNodeID,PNodeType,PHierID,1 AS LstLevel
	FROM tblCompanySalesStructureHierarchy  
	WHERE (NodeID= @NodeID AND NodeType=@NodeType) 
	UNION ALL 
	SELECT NodeID, NodeType, HierID ,PNodeID,PNodeType,PHierID,1 AS LstLevel
	FROM tblCompanySalesStructureHierarchy  
	WHERE PNodeID= @NodeID AND PNodeType=@NodeType AND @NodeID=0 AND @NodeType=0
	UNION ALL 
	--recursive execution 
	SELECT C.NodeID, C.NodeType, C.HierID ,C.PNodeID,C.PNodeType,C.PHierID,O.LstLevel + 1
	FROM tblCompanySalesStructureHierarchy C INNER JOIN CTEAllChilds O
	ON C.PHierID = O.HierID 
	) 

	SELECT * INTO #cteallchilds FROM CTEAllChilds
	CREATE TABLE #cteallchild(NodeID INT, NodeType INT, HierID INT,PNodeID INT,PNodeType INT,PHierID INT,LstLevel INT)
	WHILE PATINDEX('%|%',@StrChannelIDTemp)>0
	BEGIN
		PRINT '@StrChannelIDTemp=' + @StrChannelIDTemp
		 SET @StrChannelIDDet=SUBSTRING(@StrChannelIDTemp,1,PATINDEX('%|%',@StrChannelIDTemp)-1)  
		 SET @StrChannelIDTemp=SUBSTRING(@StrChannelIDTemp,PATINDEX('%|%',@StrChannelIDTemp)+1,LEN(@StrChannelIDTemp))  

		SET @ChannelID=CAST(SUBSTRING(@StrChannelIDDet,1,PATINDEX('%^%',@StrChannelIDDet)-1) AS INT)
		SET @StrChannelIDDet=SUBSTRING(@StrChannelIDDet,PATINDEX('%^%',@StrChannelIDDet)+1,LEN(@StrChannelIDDet))  

		SET @flgAddDelete=CAST(SUBSTRING(@StrChannelIDDet,1,PATINDEX('%^%',@StrChannelIDDet)-1) AS TINYINT) --- 1=Delete,0=Add
		SET @StrChannelIDDet=SUBSTRING(@StrChannelIDDet,PATINDEX('%^%',@StrChannelIDDet)+1,LEN(@StrChannelIDDet))  

		SET @flgChannelSub=CAST(SUBSTRING(@StrChannelIDDet,1,PATINDEX('%^%',@StrChannelIDDet)-1) AS TINYINT)  --- 1=Applicable,0=Not Applicable
		SET @StrChannelIDDet=SUBSTRING(@StrChannelIDDet,PATINDEX('%^%',@StrChannelIDDet)+1,LEN(@StrChannelIDDet))  

		SET @strNodeTypes=@StrChannelIDDet
		
		PRINT '@NodeID=' + CAST(@NodeID AS VARCHAR)
		PRINT '@NodeType=' + CAST(@NodeType AS VARCHAR)
		PRINT '@ChannelID=' + CAST(@ChannelID AS VARCHAR)
		PRINT '@flgAddDelete=' + CAST(@flgAddDelete AS VARCHAR)
		PRINT '@flgChannelSub=' + CAST(@flgChannelSub AS VARCHAR)
		PRINT '@strNodeTypes=' + @strNodeTypes

		IF ISNULL(@flgAddDelete,0)=1  --Delete Channels
		BEGIN
			INSERT INTO tblSalesHierChannelMappingHistory([SalesStructureNodID],[SalesStructureNodType],[ChannelID],[FromDate],[ToDate],[LoginIDIns],[TimestampIns],[LoginIDUpd],[TimestampUpd],[DateMoved])
			SELECT [SalesStructureNodID],[SalesStructureNodType],[ChannelID],[FromDate],[ToDate],[LoginIDIns],[TimestampIns],[LoginIDUpd],[TimestampUpd],GETDATE()
			FROM [tblSalesHierChannelMapping] WHERE SalesStructureNodID=@NodeID AND SalesStructureNodType=@NodeType AND ChannelID=@ChannelID
			AND @ApplicableFromDate>=FromDate

			DELETE FROM tblSalesHierChannelMapping WHERE @ApplicableFromDate>=FromDate AND SalesStructureNodID=@NodeID AND SalesStructureNodType=@NodeType AND ChannelID=@ChannelID
		END
		ELSE 
		BEGIN
			IF EXISTS(SELECT 1 FROM tblSalesHierChannelMapping WHERE SalesStructureNodID=@NodeID AND SalesStructureNodType=@NodeType AND ChannelID=@ChannelID)
			BEGIN
			PRINT 'BB'
				IF EXISTS(SELECT 1 FROM tblSalesHierChannelMapping WHERE @ApplicableFromDate>= FromDate AND SalesStructureNodID=@NodeID AND SalesStructureNodType=@NodeType AND ChannelID=@ChannelID)
				BEGIN
					INSERT INTO tblSalesHierChannelMappingHistory([SalesStructureNodID],[SalesStructureNodType],[ChannelID],[FromDate],[ToDate],[LoginIDIns],[TimestampIns],[LoginIDUpd],[TimestampUpd],[DateMoved])
					SELECT [SalesStructureNodID],[SalesStructureNodType],[ChannelID],[FromDate],[ToDate],[LoginIDIns],[TimestampIns],[LoginIDUpd],[TimestampUpd],GETDATE()
					FROM [tblSalesHierChannelMapping] WHERE SalesStructureNodID=@NodeID AND SalesStructureNodType=@NodeType AND ChannelID=@ChannelID
					AND @ApplicableFromDate>=FromDate

					UPDATE tblSalesHierChannelMapping SET ToDate=DATEADD(d,-1,@ApplicableFromDate),[LoginIDIns]=@LoginID,[TimestampIns]=GETDATE() WHERE SalesStructureNodID=@NodeID AND SalesStructureNodType=@NodeType AND ChannelID=@ChannelID
					AND @ApplicableFromDate>FromDate

					UPDATE tblSalesHierChannelMapping SET ToDate=@ApplicableFromDate,[LoginIDIns]=@LoginID,[TimestampIns]=GETDATE() WHERE SalesStructureNodID=@NodeID AND SalesStructureNodType=@NodeType AND ChannelID=@ChannelID
					AND @ApplicableFromDate=FromDate

					--DELETE FROM tblSalesHierChannelMapping WHERE @ApplicableFromDate>=FromDate AND SalesStructureNodID=@NodeID AND SalesStructureNodType=@NodeType AND ChannelID=@ChannelID

					INSERT INTO tblSalesHierChannelMapping([SalesStructureNodID],[SalesStructureNodType],[ChannelID],[FromDate],[ToDate],[LoginIDIns],[TimestampIns])
					SELECT @NodeID,@NodeType,@ChannelID,@ApplicableFromDate,'01-01-2050',@LoginID,GETDATE()
				END
				IF EXISTS(SELECT 1 FROM tblSalesHierChannelMapping WHERE @ApplicableFromDate < FromDate AND SalesStructureNodID=@NodeID AND SalesStructureNodType=@NodeType AND ChannelID=@ChannelID)
				BEGIN
					--DELETE FROM tblSalesHierChannelMapping WHERE @ApplicableFromDate>=FromDate AND SalesStructureNodID=@NodeID AND SalesStructureNodType=@NodeType AND ChannelID=@ChannelID
					PRINT 'INSERTED11'
					INSERT INTO tblSalesHierChannelMapping([SalesStructureNodID],[SalesStructureNodType],[ChannelID],[FromDate],[ToDate],[LoginIDIns],[TimestampIns])
					SELECT @NodeID,@NodeType,@ChannelID,@ApplicableFromDate,DATEADD(d,-1,@ApplicableFromDate),@LoginID,GETDATE()
				END
			END
			ELSE
			BEGIN
				PRINT 'INSERTED'
				INSERT INTO tblSalesHierChannelMapping([SalesStructureNodID],[SalesStructureNodType],[ChannelID],[FromDate],[ToDate],[LoginIDIns],[TimestampIns])
				SELECT @NodeID,@NodeType,@ChannelID,@ApplicableFromDate,'01-01-2050',@LoginID,GETDATE()
			END
		END
	

	----Channel Updation for the childs-------------------------------------------------------------------------------------------------------------------------------

	IF @flgChannelSub=1
	BEGIN
		PRINT 'AA'
		-- @strNodeTypes : NodeType1$NodeID1,NodeID2,...#NodeType2$NodeID1,NodeID2,...
		DECLARE @ChildNodeIDStr VARCHAR(MAX)
		SET @ChildNodeID=0
		SET @ChildNodeType=0
		DECLARE @strDetNodeTypes VARCHAR(MAX)
		WHILE PATINDEX('%#%',@strNodeTypes)>0
		BEGIN
			 PRINT '@strNodeTypes=' + @strNodeTypes
			 
			 SET @strDetNodeTypes=SUBSTRING(@strNodeTypes,1,PATINDEX('%#%',@strNodeTypes)-1) 
			 SET @ChildNodeType=CAST(SUBSTRING(@strDetNodeTypes,1,PATINDEX('%$%',@strDetNodeTypes)-1) AS INT)
			 SET @ChildNodeIDStr =SUBSTRING(@strDetNodeTypes,PATINDEX('%$%',@strDetNodeTypes)+1,LEN(@strDetNodeTypes)) 

			 SET @strNodeTypes=SUBSTRING(@strNodeTypes,PATINDEX('%#%',@strNodeTypes)+1,LEN(@strNodeTypes)) 
			PRINT '@ChildNodeType=' + CAST(@ChildNodeType AS VARCHAR)
			PRINT '@ChildNodeIDStr=' + @ChildNodeIDStr

			TRUNCATE TABLE #cteallchild
			SET @StrSQL='SELECT * FROM #cteallchilds WHERE NodeType IN (' + CAST(@ChildNodeType AS VARCHAR) + ') AND NodeID IN (' + @ChildNodeIDStr + ')'
			PRINT @StrSQL
			INSERT INTO #cteallchild(NodeID, NodeType, HierID ,PNodeID,PNodeType,PHierID,LstLevel)
			EXEC (@StrSQL)

			--SELECT * FROM #cteallchild

			DECLARE Cur_Childs CURSOR FOR 
			SELECT NodeID,NodeType FROM #cteallchild;

			OPEN Cur_Childs
			FETCH NEXT FROM Cur_Childs INTO @ChildNodeID,@ChildNodeType
			WHILE @@FETCH_STATUS = 0
			BEGIN
				----SET @StrChannelIDTemp=@StrChannelID
				----PRINT '@@StrChannelIDTemp=' + @StrChannelIDTemp
				----WHILE PATINDEX('%|%',@StrChannelIDTemp)>0
				----BEGIN
				----	 SET @StrChannelIDDet=SUBSTRING(@StrChannelIDTemp,1,PATINDEX('%|%',@StrChannelIDTemp)-1)  
				----	 SET @StrChannelIDTemp=SUBSTRING(@StrChannelIDTemp,PATINDEX('%|%',@StrChannelIDTemp)+1,LEN(@StrChannelIDTemp))  

				----	SET @ChannelID=CAST(SUBSTRING(@StrChannelIDDet,1,PATINDEX('%^%',@StrChannelIDDet)-1) AS INT)
				----	SET @flgAddDelete=CAST(SUBSTRING(@StrChannelIDDet,PATINDEX('%^%',@StrChannelIDDet)+1,1) AS TINYINT)  

		
					PRINT '@@flgAddDelete=' + CAST(@flgAddDelete AS VARCHAR)
					IF @flgAddDelete=1
					BEGIN
						INSERT INTO tblSalesHierChannelMappingHistory([SalesStructureNodID],[SalesStructureNodType],[ChannelID],[FromDate],[ToDate],[LoginIDIns],[TimestampIns],[LoginIDUpd],[TimestampUpd],[DateMoved])
						SELECT [SalesStructureNodID],[SalesStructureNodType],[ChannelID],[FromDate],[ToDate],[LoginIDIns],[TimestampIns],[LoginIDUpd],[TimestampUpd],GETDATE()
						FROM [dbo].[tblSalesHierChannelMapping] WHERE SalesStructureNodID=@ChildNodeID AND SalesStructureNodType=@ChildNodeType AND ChannelID=@ChannelID
						AND @ApplicableFromDate>=FromDate

						DELETE FROM tblSalesHierChannelMapping WHERE @ApplicableFromDate>=FromDate AND SalesStructureNodID=@ChildNodeID AND SalesStructureNodType=@ChildNodeType AND ChannelID=@ChannelID
					END
					ELSE 
					BEGIN
						PRINT '@NodeID=' + CAST(@NodeID AS VARCHAR)
						PRINT '@NodeType=' + CAST(@NodeType AS VARCHAR)

						IF EXISTS(SELECT 1 FROM tblSalesHierChannelMapping WHERE SalesStructureNodID=@ChildNodeID AND SalesStructureNodType=@ChildNodeType AND ChannelID=@ChannelID)
						BEGIN
							IF EXISTS(SELECT 1 FROM tblSalesHierChannelMapping WHERE @ApplicableFromDate>= FromDate AND SalesStructureNodID=@ChildNodeID AND SalesStructureNodType=@ChildNodeType AND ChannelID=@ChannelID)
							BEGIN
								INSERT INTO tblSalesHierChannelMappingHistory([SalesStructureNodID],[SalesStructureNodType],[ChannelID],[FromDate],[ToDate],[LoginIDIns],[TimestampIns],[LoginIDUpd],[TimestampUpd],[DateMoved])
								SELECT [SalesStructureNodID],[SalesStructureNodType],[ChannelID],[FromDate],[ToDate],[LoginIDIns],[TimestampIns],[LoginIDUpd],[TimestampUpd],GETDATE()
								FROM [dbo].[tblSalesHierChannelMapping] WHERE SalesStructureNodID=@ChildNodeID AND SalesStructureNodType=@ChildNodeType AND ChannelID=@ChannelID
								AND @ApplicableFromDate>=FromDate

								UPDATE tblSalesHierChannelMapping SET ToDate=DATEADD(d,-1,@ApplicableFromDate),[LoginIDIns]=@LoginID,[TimestampIns]=GETDATE() WHERE SalesStructureNodID=@ChildNodeID AND SalesStructureNodType=@ChildNodeType AND ChannelID=@ChannelID
								AND @ApplicableFromDate>FromDate

								UPDATE tblSalesHierChannelMapping SET ToDate=@ApplicableFromDate,[LoginIDIns]=@LoginID,[TimestampIns]=GETDATE() WHERE SalesStructureNodID=@ChildNodeID AND SalesStructureNodType=@ChildNodeType AND ChannelID=@ChannelID
								AND @ApplicableFromDate=FromDate

								--DELETE FROM tblSalesHierChannelMapping WHERE @ApplicableFromDate>=FromDate AND SalesStructureNodID=@NodeID AND SalesStructureNodType=@NodeType AND ChannelID=@ChannelID

								INSERT INTO tblSalesHierChannelMapping([SalesStructureNodID],[SalesStructureNodType],[ChannelID],[FromDate],[ToDate],[LoginIDIns],[TimestampIns])
								SELECT @ChildNodeID,@ChildNodeType,@ChannelID,@ApplicableFromDate,'01-01-2050',@LoginID,GETDATE()
							END
							IF EXISTS(SELECT 1 FROM tblSalesHierChannelMapping WHERE @ApplicableFromDate < FromDate AND SalesStructureNodID=@ChildNodeID AND SalesStructureNodType=@ChildNodeType AND ChannelID=@ChannelID)
							BEGIN
								--DELETE FROM tblSalesHierChannelMapping WHERE @ApplicableFromDate>=FromDate AND SalesStructureNodID=@NodeID AND SalesStructureNodType=@NodeType AND ChannelID=@ChannelID

								INSERT INTO tblSalesHierChannelMapping([SalesStructureNodID],[SalesStructureNodType],[ChannelID],[FromDate],[ToDate],[LoginIDIns],[TimestampIns])
								SELECT @ChildNodeID,@ChildNodeType,@ChannelID,@ApplicableFromDate,DATEADD(d,-1,@ApplicableFromDate),@LoginID,GETDATE()
							END
						END
						ELSE
						BEGIN
							PRINT 'Make Entry'
							INSERT INTO tblSalesHierChannelMapping([SalesStructureNodID],[SalesStructureNodType],[ChannelID],[FromDate],[ToDate],[LoginIDIns],[TimestampIns])
							SELECT @ChildNodeID,@ChildNodeType,@ChannelID,@ApplicableFromDate,'01-01-2050',@LoginID,GETDATE()
						END
					END
				--END
				FETCH NEXT FROM Cur_Childs INTO @ChildNodeID,@ChildNodeType
			END
			CLOSE Cur_Childs
			DEALLOCATE Cur_Childs
		
		END
	END

END
	-------------------------------------------------------------------------------------------------------------------------------------------
	
	
	
	
END





