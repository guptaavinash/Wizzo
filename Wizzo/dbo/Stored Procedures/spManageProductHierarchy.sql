CREATE    PROCEDURE [dbo].[spManageProductHierarchy]

@NodeID INT,
@NodeType INT,
@HierID INT,
@SecFlag TINYINT,
@PNodeType INT,
@PHierID INT,
@FrmDate DATETIME,
@strDetails varChar(4000), --This will vary for each NodeType
@LoginID INT,
@FrameID INT,
@Lstlevel INT = 20
 AS

DECLARE @PNodeID INT
--DECLARE @PNodeType INT
DECLARE @Descr varChar(4000)
DECLARE @Item_Code varchar(50)
DECLARE @Rate FLOAT(8)
DECLARE @Unit SMALLINT
DECLARE @tblHier VARCHAR(50)
DECLARE @tblDesc VARCHAR(50)
--DECLARE @FrameID INT
DECLARE @HierTypeID INT
DECLARE @strSQL varChar(2000)


IF @PHierID>0
	BEGIN
		EXEC spUTLGetNodeDetFromHierID @PHierID, @PNodeID OUTPUT, @PNodeType OUTPUT
	END

SET @PNodeID=ISNULL(@PNodeID,0)
SET @PNodeType=ISNULL(@PNodeType,0)
--PRINT 'OK'
EXEC spUTLGetSQLTblSource @NodeType,  @tblHier OUTPUT, @tblDesc OUTPUT, @FrameID OUTPUT, @HierTypeID OUTPUT
--PRINT 'Hello' + @tblDesc

IF PATINDEX('%|%',@strDetails)>0
BEGIN
	SET @Descr=SUBSTRING(@strDetails,1,PATINDEX('%|%',@strDetails)-1)
	SET @strDetails=SUBSTRING(@strDetails,PATINDEX('%|%',@strDetails)+1,LEN(@strDetails))

	IF @NodeID=0
		BEGIN
			IF @NodeType<>40
			BEGIN
				SET @strSQL='INSERT INTO ' +  @tblDesc + '(Descr, LoginIDIns) VALUES  (''' + @Descr + ''',' + CAST(@LoginID as varChar) + ')'
				Print @strSQL
				EXEC (@strSQL)
				SET @NodeID=@@IDENTITY
			END
					
		END
	ELSE
		BEGIN
			SET @strSQL='UPDATE ' +  @tblDesc + ' SET Descr=''' + @Descr + ''', LoginIDUpd=' + CAST(@LoginID as varChar) + '  where NodeId=' +  CAST(@NodeID AS varChar)
			print @strSQL
			EXEC (@strSQL)
		END
	IF @NodeType<>40
	BEGIN
		IF @HierID=0
			BEGIN
				SET @strSQL= 'INSERT INTO ' + @tblHier + ' (PHierID, NodeId, NodeType, PNodeID, PNodeType, LoginID, HierTypeID,VldFrom,VldTo) VALUES (' + CAST(@PHierID as varChar) + ',' +  CAST(@NodeId as varChar) + ',' + CAST(@NodeType as varChar) + ','  + CAST(@PNodeID  as varChar) + ','  + CAST(@PNodeType as varChar) + ','  + CAST(@LoginID  as varChar) + ','  + CAST(@HierTypeID  as varChar) + ',GETDATE(),''31-Dec-2049'')'
				EXEC (@strSQL)
				SET @HierID = @@IDENTITY
			SELECT cast(isnull(@HierID,0) as varchar) + '|' + cast(isnull(@PHierID,0) as varchar) + '|' + cast(isnull(@NodeID,0) as varchar) + '|' + cast(isnull(@NodeType,0) as varchar) + '|' + cast(isnull(@PNodeID,0) as varchar) + '|' + cast(isnull(@PNodeType,0) as varchar) + '|20|' + cast(isnull(@SecFlag,0) as varchar) + '|0' AS PKey
			END
		ELSE
			BEGIN
				SET @strSQL='UPDATE ' +  @tblHier + ' SET PHierID=' + CAST(@PHierID as varChar) + ',NodeId=' + CAST(@NodeId as varChar) + ', NodeType=' + CAST(@NodeType  as varChar) + ', PNodeID=' + CAST(@PNodeID as varChar) + ', PNodeType=' + CAST(@PNodeType as varChar) + ', LoginID=' + CAST(@LoginID as varChar) + ', HierTypeID =' + CAST(@HierTypeID as varChar) + '  WHERE HierID=' + CAST(@HierID  as varChar)
				PRINT @strSQL
				EXEC (@strSQL)
			SELECT cast(isnull(@HierID,0) as varchar) + '|' + cast(isnull(@PHierID,0) as varchar) + '|' + cast(isnull(@NodeID,0) as varchar) + '|' + cast(isnull(@NodeType,0) as varchar) + '|' + cast(isnull(@PNodeID,0) as varchar) + '|' + cast(isnull(@PNodeType,0) as varchar) + '|' + CAST(ISNULL(@Lstlevel,0) AS VARCHAR) + '|' + cast(isnull(@SecFlag,0) as varchar) + '|0' AS PKey
			END
	END

END





