







--[spMakeTreeWSInitialNode] '2^0^0^|',1505
CREATE   PROCEDURE [dbo].[spMakeTreeWSInitialNode] 

		--Created by Ak on 01-Jun-07
		--This SP is used to draw the initial node where it is required in format Customer Hierarchy etc. and not actual node desc in initial node. Multiple hierarchies can be shown in same tree.

--spMakeTreeWSInitialNode 1, 0, 0, '30-Apr-07', 1, 111
@strHierTypeID varChar(500),  --This is the Type of Tree in the format A^B^C^|1^0^0^| ...A=HierTypeID ^ B=0 or n - This is HierID to start that HierTypeID tree from ^. C - if B<>0 then 1 to display actual descr of tree node and 0 to display name of hierarchy; if B=0 then 0 always
@LoginID INT

AS

SET NOCOUNT ON

DECLARE @HierTypeID INT
DECLARE @HierID INT
DECLARE @NodeDescrFlg TINYINT
DECLARE @SecFlag TINYINT
DECLARE @NodeID INT
DECLARE @NodeType INT
DECLARE @NodeDesc nvarchar(255)
DECLARE @SSClass varchar(100)
DECLARE @ImageName varchar(50)
DECLARE @strHierTypeIDsub varChar(50)
DECLARE @ISActive INT

	WHILE PATINDEX('%|%',@strHierTypeID)>0
		BEGIN
			SET @strHierTypeIDsub=SUBSTRING(@strHierTypeID,1,PATINDEX('%|%',@strHierTypeID)-1)
			SET @strHierTypeID=SUBSTRING(@strHierTypeID,PATINDEX('%|%',@strHierTypeID)+1,LEN(@strHierTypeID))

				SET @HierTypeID=SUBSTRING(@strHierTypeIDsub,1,PATINDEX('%^%',@strHierTypeIDsub)-1)
				SET @strHierTypeIDsub=SUBSTRING(@strHierTypeIDsub,PATINDEX('%^%',@strHierTypeIDsub)+1,LEN(@strHierTypeIDsub))
	
				SET @HierID=SUBSTRING(@strHierTypeIDsub,1,PATINDEX('%^%',@strHierTypeIDsub)-1)
				SET @strHierTypeIDsub=SUBSTRING(@strHierTypeIDsub,PATINDEX('%^%',@strHierTypeIDsub)+1,LEN(@strHierTypeIDsub))
	
				SET @NodeDescrFlg=SUBSTRING(@strHierTypeIDsub,1,PATINDEX('%^%',@strHierTypeIDsub)-1)
	
				IF @HierID=0
					BEGIN
						SET @NodeType=0
					END
				ELSE
					BEGIN
						SELECT    @NodeType=MIN(NodeType)  FROM tblPMstNodeTypes WHERE     (HierTypeID = @HierTypeID)
					END
				
	
				EXEC spUTLGetNodeDetFromHierID @HierID, @NodeID OUTPUT, @NodeType OUTPUT
				SET @NodeID=ISNULL(@NodeID,0)
				SET @SecFlag=2
				
				DECLARE @NodeTypeSec INT
				SELECT    @NodeTypeSec=MIN(NodeType)  FROM tblPMstNodeTypes WHERE     (HierTypeID = @HierTypeID)
				EXEC spMakeTreeGetUserSec @LoginID, @NodeID, @NodeTypeSec, @SecFlag, @SecFlag OUTPUT

				PRINT 'SecFlag' + CAST(@SecFlag AS VARCHAR)
	
				EXEC spMakeTreeGetFormat @NodeTypeSec, @SSClass OUTPUT, @ImageName OUTPUT
				PRINT 'Done'
				IF @NodeDescrFlg=0
					BEGIN
						IF @HierTypeID=1
							BEGIN
								SET @NodeDesc='Product Hierarchy'
							END
						ELSE IF @HierTypeID=2
							BEGIN
								SET @NodeDesc='Sales Hierarchy'
							END
						ELSE IF @HierTypeID=4
							BEGIN
								SET @NodeDesc='Location Hierarchy'
							END
						ELSE IF @HierTypeID=5
							BEGIN
								SET @NodeDesc='Distributor Hierarchy'
							END
					END
				ELSE
					BEGIN
						EXEC spGetNodeDesc @NodeID, @NodeType, @NodeDesc OUTPUT,@ISActive OUTPUT
					END
				
				IF @SecFlag<>3
					BEGIN
						--SELECT cast(isnull(@HierID,0) as varchar) + '|0' +  '|'  +cast(isnull(@NodeID,0) as varchar) + '|' + CASE @HierID WHEN 0 THEN CAST(0 as varChar(2)) ELSE  cast(isnull(@NodeType,0) as varchar) END + '|0|0|10|' + cast(isnull(@SecFlag,0) as varchar) + '|0' AS PKey, @NodeID NodeId, @NodeType NodeType, @NodeDesc NodeDesc, 0 PNodeId, 0 PNodeType, @SSClass SSC, @ImageName ImageName, 0 LstLevel, @SecFlag  SecFlag
						SELECT cast(isnull(@HierID,0) as varchar) + '|0' +  '|'  +cast(isnull(@NodeID,0) as varchar) + '|' +  cast(isnull(@NodeType,0) as varchar) + '|0|0|10|' + cast(isnull(@SecFlag,0) as varchar) + '|0' AS PKey, @NodeID NodeId, @NodeType NodeType, @NodeDesc NodeDesc, 0 PNodeId, 0 PNodeType, @SSClass SSC, @ImageName ImageName, 0 LstLevel, @SecFlag  SecFlag
					END
			END
