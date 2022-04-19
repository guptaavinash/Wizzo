
-- =============================================
-- Author:		Avinash Gupta
-- Create date: 05-Nov-2019
-- Description:	
-- =============================================
-- [SpPDARouteChangeApproval]  '314D6CE8-0C6A-4635-9D75-04AC1A56F27A',0,0,14405,140,1,'2767 is the code for verification of your contact number. Please do share it with Raj Super White representative. -Astix'
CREATE PROCEDURE [dbo].[SpPDARouteChangeApproval] 
	@PDACode VARCHAR(100),
	@OldRouteNodeID INT=0,
	@OldRouteNodeTYpe SMALLINT=0,
	@NewRouteNodeID INT,
	@NewRouteNodeType SMALLINT,
	@flgStep TINYINT,--1=Request,2=Approved
	@OTP VARCHAR(10),
	@ReasonForRouteChangeComment VARCHAR(500) 
AS
BEGIN
	DECLARE @flgRequestStatus TINYINT
	SELECT @flgRequestStatus=0
	DECLARE @PersonNodeID INT     
	DECLARE @PersonType INT
	DECLARE @Salesman VARCHAR(100)
	SELECT @PersonNodeID=NodeID,@PersonType=NodeType,@Salesman=P.Descr FROM dbo.fnGetPersonIDfromPDACode(@PDACode) U INNER JOIN tblMstrPerson(nolock) P ON P.NodeID=U.PersonID



	PRINT 'PersonNodeID=' + CAST(ISNULL(@PersonNodeID,0) AS VARCHAR)
	IF ISNULL(@PersonNodeID,0)>0
	BEGIN
		IF @flgStep=1
		BEGIN
			--IF NOT EXISTS (SELECT * FROM tblPDARouteChangeApprovalDetail A WHERE RequestPersonNodeID=@PersonNodeID AND RequestPersonNodeType=@PersonType AND CAST(GETDATE() AS DATE)=CAST(RequestDatetime AS DATE) AND OldRouteNodeID=@OldRouteNodeID AND OldRouteNodeType=@OldRouteNodeTYpe AND RequestRouteNodeID=@NewRouteNodeID AND RequestRouteNodeType=@NewRouteNodeType)
			--BEGIN
			--	INSERT INTO tblPDARouteChangeApprovalDetail(RequestPersonNodeID,RequestPersonNodeType,RequestPDACode,OldRouteNodeID,OldRouteNodeType,RequestRouteNodeID,RequestRouteNodeType,RequestDatetime,flgApprovedOrReject,OTPCode)
			--	SELECT @PersonNodeID,@PersonType,@PDACode,@OldRouteNodeID,@OldRouteNodeTYpe,@NewRouteNodeID,@NewRouteNodeType,GETDATE(),0,@OTP
			--END
			IF NOT EXISTS (SELECT * FROM tblPDARouteChangeApprovalDetail A WHERE RequestPersonNodeID=@PersonNodeID AND RequestPersonNodeType=@PersonType AND CAST(GETDATE() AS DATE)=CAST(RequestDatetime AS DATE)  AND RequestRouteNodeID=@NewRouteNodeID AND RequestRouteNodeType=@NewRouteNodeType)
			BEGIN
				INSERT INTO tblPDARouteChangeApprovalDetail(RequestPersonNodeID,RequestPersonNodeType,RequestPDACode,OldRouteNodeID,OldRouteNodeType,RequestRouteNodeID,RequestRouteNodeType,RequestDatetime,flgApprovedOrReject,OTPCode,ReasonForRouteChangeComment)
				SELECT @PersonNodeID,@PersonType,@PDACode,@OldRouteNodeID,@OldRouteNodeTYpe,@NewRouteNodeID,@NewRouteNodeType,GETDATE(),0,@OTP,@ReasonForRouteChangeComment
			END
			ELSE
			BEGIN
				INSERT INTO tblPDARouteChangeApprovalDetail_History
				SELECT P.* FROM tblPDARouteChangeApprovalDetail P WHERE RequestPersonNodeID=@PersonNodeID AND RequestPersonNodeType=@PersonType AND CAST(RequestDatetime AS DATE)=CAST(GETDATE() AS DATE)  AND RequestRouteNodeID=@NewRouteNodeID AND RequestRouteNodeType=@NewRouteNodeType

				UPDATE A SET flgApprovedOrReject=0,ApprovalDatetime=NULL,OTPCode=@OTP,ReasonForRouteChangeComment=@ReasonForRouteChangeComment FROM tblPDARouteChangeApprovalDetail A WHERE RequestPersonNodeID=@PersonNodeID AND RequestPersonNodeType=@PersonType AND CAST(RequestDatetime AS DATE)=CAST(GETDATE() AS DATE)  AND RequestRouteNodeID=@NewRouteNodeID AND RequestRouteNodeType=@NewRouteNodeType
			END
			SET @flgRequestStatus=1
		END
		ELSE IF @flgStep=2
		BEGIN
			IF EXISTS (SELECT 1 FROM tblPDARouteChangeApprovalDetail A WHERE RequestPersonNodeID=@PersonNodeID AND RequestPersonNodeType=@PersonType AND CAST(GETDATE() AS DATE)=CAST(RequestDatetime AS DATE)  AND RequestRouteNodeID=@NewRouteNodeID AND RequestRouteNodeType=@NewRouteNodeType AND OTPCode=@OTP)
			BEGIN
				UPDATE A SET flgApprovedOrReject=1 FROM tblPDARouteChangeApprovalDetail A WHERE RequestPersonNodeID=@PersonNodeID AND RequestPersonNodeType=@PersonType AND CAST(RequestDatetime AS DATE)=CAST(GETDATE() AS DATE)  AND RequestRouteNodeID=@NewRouteNodeID AND RequestRouteNodeType=@NewRouteNodeType
				SET @flgRequestStatus=1
			END
			ELSE
			BEGIN
				UPDATE A SET flgApprovedOrReject=2 FROM tblPDARouteChangeApprovalDetail A WHERE RequestPersonNodeID=@PersonNodeID AND RequestPersonNodeType=@PersonType AND CAST(RequestDatetime AS DATE)=CAST(GETDATE() AS DATE)  AND RequestRouteNodeID=@NewRouteNodeID AND RequestRouteNodeType=@NewRouteNodeType
				SET @flgRequestStatus=2
			END
		
		END
		
	END
	ELSE
	BEGIN
		SET @flgRequestStatus=0
	END
	DECLARE @ApprovarContactNUmber BIGINT,@ApprovarName VARCHAR(200)
	SELECT @ApprovarContactNUmber=PP.PersonPhone,@ApprovarName=PP.Descr FROM tblSalesPersonMapping SP INNER JOIN tblCompanySalesStructureHierarchy H ON H.NodeID=SP.NodeID AND H.NodeType=SP.NodeType INNER JOIN tblSalesPersonMapping SP1 ON SP1.NodeID=H.PNodeID AND SP1.NodeType=H.PNodeType AND CAST(GETDATE() AS DATE) BETWEEN SP1.FromDate AND SP1.ToDate
	INNER JOIN tblMstrPerson P ON P.NodeID=SP1.PersonNodeID AND P.NodeType=SP1.PersonType
	INNER JOIN tblCompanySalesStructureHierarchy PH ON PH.NodeID=H.PNodeID AND PH.NodeType=H.PNodeType
	INNER JOIN tblSalesPersonMapping SP2 ON SP2.NodeID=PH.NodeID AND SP2.NodeType=PH.NodeType AND CAST(GETDATE() AS DATE) BETWEEN SP2.FromDate AND SP2.ToDate INNER JOIN tblMstrPerson PP ON PP.NodeID=SP2.PersonNodeID AND PP.NodeType=SP2.PersonType
	WHERE SP.PersonNodeID=@PersonNodeID AND SP.PersonType=@PersonType AND CAST(GETDATE() AS DATE) BETWEEN SP.FromDate AND SP.ToDate AND SP.NodeType=120

	IF ISNULL(@ApprovarContactNUmber,0)=0
	BEGIN
		SELECT @ApprovarContactNUmber=R.PersonPhone,@ApprovarName=R.Descr FROM VwCompanyDSRFullDetail V INNER JOIN tblSalesPersonMapping(nolock) SP ON SP.NodeID=V.DSRAreaID AND SP.NodeType=V.DSRAreaNodeType INNER JOIN tblSalesPersonMapping RSP ON RSP.NodeID=V.RSMAreaID AND RSP.NodeType=V.RSMAreaType INNER JOIN tblMstrPerson R ON R.NodeID=RSP.PersonNodeID AND R.NodeType=RSP.PersonType WHERE SP.PersonNodeID=@PersonNodeID AND SP.PersonType=@PersonType AND CAST(GETDATE() AS DATE) BETWEEN SP.FromDate AND SP.ToDate AND CAST(GETDATE() AS DATE) BETWEEN RSP.FromDate AND RSP.ToDate
	END

	DECLARE @OLDRoute VARCHAR(100),@NEWRoute VARCHAR(100)
	SELECT @OLDRoute=Descr FROM tblCompanySalesStructureRouteMstr(nolock) WHERE NodeID=@OldRouteNodeID
	SELECT @NEWRoute=Descr FROM tblCompanySalesStructureRouteMstr(nolock) WHERE NodeID=@NewRouteNodeID

	SELECT CAST(@flgRequestStatus AS INT) flgRequestStatus,@PDACode PDACode,@OTP OTP,ISNULL(@ApprovarContactNUmber,'8447130126') AS ApprovarContact,ISNULL(@ApprovarName,'NA') + '(' + ISNULL(CAST(@ApprovarContactNUmber AS VARCHAR),'NA') + ')' AS ApprovarName,ISNULL(@Salesman,'NA') AS Salesman,ISNULL(@OLDRoute,'NA') AS OldRoute,ISNULL(@NEWRoute,'NA') as NewRoute,@ReasonForRouteChangeComment ReasonForRouteChangeComment
END
