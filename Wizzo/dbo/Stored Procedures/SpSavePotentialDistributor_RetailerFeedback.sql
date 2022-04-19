CREATE PROCEDURE [dbo].[SpSavePotentialDistributor_RetailerFeedback] 
	@PDACode VARCHAR(100),
	@DBNodeID INT,
	@DBNodeType SMALLINT,
	@NewDBRCode VARCHAR(100),
	@tblPotentialDBRetailerData udt_PotentialDBRetailerData_Saving READONLY,
	@flgFinalSubmit TINYINT -- 0=ONly Save,1=Final Save
AS
BEGIN
	IF ISNULL(@DBNodeID,0)=0
		SELECT @DBNodeID=P.NodeID,@DBNodeType=NodeType FROM tblPotentialDistributor P WHERE P.DBRCode=@NewDBRCode

	DELETE D FROM tblPotentialDistributorRetailerDet D WHERE DBNodeID=@DBNodeID AND DBNodeType=@DBNodeType

	INSERT INTO tblPotentialDistributorRetailerDet(DBNodeID,DBNodeType,RetailerCode,RetailerName,Address,RetFeedback,Comment,ContactNumber)
	SELECT @DBNodeID,@DBNodeType,RetailerCode,RetailerName,Address,RetFeedback,Comment,ContactNumber FROM @tblPotentialDBRetailerData

	UPDATE P SET flgFinalSubmit=@flgFinalSubmit FROM tblPotentialDistributor P WHERE NodeID=@DBNodeID AND NodeType=@DBNodeType

	DECLARE @flgStatus INT
		SET @flgStatus=1
		
		SELECT @flgStatus flgStatus

END
