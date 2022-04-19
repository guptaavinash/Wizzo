-- =============================================
-- Author:		Avinash Gupta
-- Create date: 28-Sep-2015
-- Description:	Sp to save the distributor coverage Area Detail
-- =============================================
CREATE PROCEDURE [dbo].[SpSaveDistributorCoverageAreaMapping] 
	@DBRList udt_DBR Readonly,
	@SHNodeID INT,  -- Area to which distributor need to map.
	@SHNodeType TINYINT,
	@LoginID INT	
AS
BEGIN
	DECLARE @DistNodeType SMALLINT
	SET @DistNodeType=0

	SELECT @DistNodeType=NodeType FROM tblSecMenuContextMenu WHERE flgDistributor=1

	SELECT * FROM tblCompanySalesStructure_DistributorMapping WHERE DHNodeType=150
	UPDATE D SET Todate=GETDATE() FROM tblCompanySalesStructure_DistributorMapping D WHERE SHNodeID=@SHNodeID AND SHNodeType=@SHNodeType AND DHNodeType=@DistNodeType

	INSERT INTO tblCompanySalesStructure_DistributorMapping(DHNodeID,DHNodeType,SHNodeID,SHNodeType,FromDate,ToDate,TimestampIns)
	SELECT DISTINCT DBRID,DBRNodeType,@SHNodeID,@SHNodeType,GETDATE(),'31-Dec-2049',GETDATE() FROM @DBRList
 
	------Added By Alok on 15-May to populate  tblDBR_LiveMarking which is list of DBR with coverage area under 
	----TRUNCATE TABLE tblDBR_LiveMarking
	----INSERT INTO tblDBR_LiveMarking
	----SELECT DISTINCT PHierId
	----FROM   tblCompanySalesStructureHierarchy
	----WHERE (PNodeType = 150)
	----INSERT INTO tblDBR_LiveMarking
	----SELECT DISTINCT HierId
	----FROM   tblCompanySalesStructureHierarchy
	----WHERE (PNodeType = 150)
	----INSERT INTO tblDBR_LiveMarking
	----SELECT DISTINCT HierId
	----FROM   tblCompanySalesStructureHierarchy
	----WHERE (PNodeType = 160)




		
END
