-- [spIMEIVersionDetailStatus] 34,'DFD7BFE6-0299-423B-AE7B-48A3681E0141' ,4

CREATE PROCEDURE [dbo].[spIMEIVersionDetailStatus] --7,'911348700252142'          
@VersionID integer,          
@PDACode varchar(50),  
@ApplicationType int,-- =1  
@FCMTokenNo varchar(1024) =''
AS          
DECLARE @flgUserAuthenticated TINYINT -- 0=User Not Authenticated ,1=Authenticated.
DECLARE @CurrentVersionNumber integer=0 -- 0=No Version released, >0 Latest versionID released.
DECLARE @PersonName VARCHAR(200)=''
DECLARE @FlgRegistered TINYINT=0
DECLARE @PersonNodeID Integer=0 
DECLARE @PersonNodeType Integer=0 
DECLARE @CoverageAreaNodeID INT
DECLARE @CoverageAreaNodeType SMALLINT
DECLARE @PDAID INT=0

IF @FCMTokenNo  <>''
BEGIN
PRINT 'FCM Saving Called'
PRINT '@FCMTokenNo=' + CAST(@FCMTokenNo AS VARCHAR(1024)) 
DECLARE @Date DATETIME
SET @Date=GETDATE()
EXEC spSFAUpdateFCMTokenNo  @PDACode,@FCMTokenNo
END


SET @flgUserAuthenticated=0
SELECT @PersonNodeID=NodeID,@PersonNodeType=NodeType FROM dbo.fnGetPersonIDfromPDACode(@PDACode) U INNER JOIN tblMstrPerson P ON P.NodeID=U.PersonID

--SELECT @PersonNodeID PersonNodeID
--SELECT @PersonNodeType PersonNodeType

INSERT INTO tblVersionDownload_Log(VersionID,IMEINo,ApplicationType)
VALUES (@VersionID,@PDACode,@ApplicationType)

IF @PersonNodeType IN (220,230)
SELECT  @PersonNodeID=SP.PersonNodeID,@PersonNodeType=SP.PersonType,@CoverageAreaNodeID=SP.NodeID,@CoverageAreaNodeType=SP.NodeType,@PersonName=MP.Descr,@FlgRegistered=ISNULL(MP.flgRegistered,0)  FROM  tblSalesPersonMapping SP INNER JOIN tblMstrPerson MP ON SP.PersonNodeID=MP.NodeId WHERE Sp.PersonNodeID=@PersonNodeID AND SP.PersonType=@PersonNodeType AND (GETDATE() BETWEEN SP.FromDate AND SP.ToDate) AND SP.NodeType=130 ORDER BY SP.NodeType desc
ELSE
SELECT  @PersonNodeID=SP.PersonNodeID,@PersonNodeType=SP.PersonType,@CoverageAreaNodeID=SP.NodeID,@CoverageAreaNodeType=SP.NodeType,@PersonName=MP.Descr,@FlgRegistered=ISNULL(MP.flgRegistered,0)  FROM  tblSalesPersonMapping SP INNER JOIN tblMstrPerson MP ON SP.PersonNodeID=MP.NodeId WHERE Sp.PersonNodeID=@PersonNodeID AND SP.PersonType=@PersonNodeType AND (GETDATE() BETWEEN SP.FromDate AND SP.ToDate) AND SP.NodeType=110 ORDER BY SP.NodeType desc



PRINT '@CoverageAreaNodeID=' + CAST(@CoverageAreaNodeID AS VARCHAR)
PRINT '@CoverageAreaNodeType=' + CAST(@CoverageAreaNodeType AS VARCHAR)

IF ISNULL(@CoverageAreaNodeID,0)=0 AND ISNULL(@CoverageAreaNodeType,0)=0
BEGIN
	PRINT 'A'
	SET @flgUserAuthenticated=0
END
ELSE
BEGIN
	PRINT 'B'
	SET @flgUserAuthenticated=1

	SET @CurrentVersionNumber=(SELECT top(1) tblVersionMstr.VersionID FROM   tblVersionMstr WHERE tblVersionMstr.ApplicationType=@ApplicationType 
	   	 order by	tblVersionMstr.VersionID DESC)

	IF NOT EXISTS (SELECT 1 FROM tblNotReleasePDAVersionMstr WHERE PDACode=@PDACode)
	BEGIN
		DECLARE @chkIMEIExistOrNot int          

		Set @chkIMEIExistOrNot= (select Count(PDACode) from tblVersionDownloadStatusMstr where PDACode=@PDACode AND tblVersionDownloadStatusMstr.ApplicationType=@ApplicationType and VersionID=@CurrentVersionNumber)          

		IF(@chkIMEIExistOrNot=0)          
		BEGIN 
			INSERT INTO tblVersionDownloadStatusMstrHistory(VersionID,PDACode,VersionDownloadDate,VersionDownloadStatus,ApplicationType)
			SELECT 	VersionID,PDACode,VersionDownloadDate,VersionDownloadStatus,ApplicationType FROM tblVersionDownloadStatusMstr  where PDACode=@PDACode AND tblVersionDownloadStatusMstr.ApplicationType=@ApplicationType 

			Delete From tblVersionDownloadStatusMstr where PDACode=@PDACode AND tblVersionDownloadStatusMstr.ApplicationType=@ApplicationType 
			IF @VersionID=@CurrentVersionNumber
				Insert into  tblVersionDownloadStatusMstr (VersionID,PDACode,VersionDownloadStatus,ApplicationType,VersionDownloadDate) values(@CurrentVersionNumber,@PDACode,0,@ApplicationType,GETDATE())          
			ELSE
				Insert into  tblVersionDownloadStatusMstr (VersionID,PDACode,VersionDownloadStatus,ApplicationType) values(@CurrentVersionNumber,@PDACode,1,@ApplicationType)          
		END
		Else
		BEGIN
			IF @VersionID=@CurrentVersionNumber
			BEGIN
				Update tblVersionDownloadStatusMstr SET VersionDownloadStatus=0, VersionDownloadDate=GETDATE() where PDACode=@PDACode AND  tblVersionDownloadStatusMstr.ApplicationType=@ApplicationType and tblVersionDownloadStatusMstr.VersionID=@CurrentVersionNumber and VersionDownloadStatus=1
			END
			ELSE
			BEGIN
				Update tblVersionDownloadStatusMstr SET VersionDownloadStatus=1, VersionDownloadDate=GETDATE() where PDACode=@PDACode AND  tblVersionDownloadStatusMstr.ApplicationType=@ApplicationType and tblVersionDownloadStatusMstr.VersionID=@CurrentVersionNumber 
			END			
		END
	END        
END
---##################### Flag for Attandence ###############################################################################################################
DECLARE @flgPersonTodaysAtt TINYINT=0,@AttenDatetime DAtetime
SELECT @flgPersonTodaysAtt=1,@AttenDatetime=Datetime FROM tblPersonAttendance WHERE PersonNodeID=@PersonNodeID AND CAST(datetime AS DATE)=CAST(GETDATE() AS DATE)

--@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
DECLARE @SalesAreaName VARCHAR(200)
CREATE TABLE #tblSalesArea(SalesArea VARCHAR(200))
INSERT INTO #tblSalesArea(SalesArea)

EXEC SpGetSalesAreaName @CoverageAreaNodeID,@CoverageAreaNodeType
SELECT @SalesAreaName=SalesArea FROM #tblSalesArea

DECLARE @ContactNo varchar(20)
DECLARE @DOB Date
DECLARE @SelfieName varchar(300)
--PRINT 'Abhinav Raj'
SELECT @ContactNo=ContactNo,@DOB=DOB,@SelfieName=SelfieName from tblRegisteredPersonDetails WHERE tblRegisteredPersonDetails.PersonNodeId=@PersonNodeID 
--PRINt '@ContactNo:-'

--PRINt @ContactNo

if(@ContactNo is null or @ContactNo='' or @ContactNo='0' or  @ContactNo=' ')

BEGIN

--DECLARE @ContactNo varchar(20)

SELECT @ContactNo=PersonPhone from tblMStrPerson WHERE tblMStrPerson.NodeID=@PersonNodeID 

--SELECT @ContactNo

END
PRINT '@CoverageAreaNodeID=' + CAST(@CoverageAreaNodeID AS VARCHAR)
PRINT '@CoverageAreaNodeType=' + CAST(@CoverageAreaNodeType AS VARCHAR)
SELECT @flgUserAuthenticated flgUserAuthenticated,@PersonName AS PersonName,@FlgRegistered AS FlgRegistered,1 AS flgToShowAllRoutesData,@PersonNodeID AS PersonNodeID,@PersonNodeType AS PersonNodeType,

ISNULL(@CoverageAreaNodeID,0) AS CoverageAreaNodeID,ISNULL(@CoverageAreaNodeType,0) AS CoverageAreaNodeType,@flgPersonTodaysAtt flgPersonTodaysAtt ,isnull(@ContactNo,'0')  AS ContactNo,isnull(CAST(FORMAT(@DOB,'dd-MMM-yyyy') AS VARCHAR),'NA') AS DOB,isnull(@SelfieName,'NA') AS SelfieName,ISNULL
('http://103.20.212.67/SFAImages/RajTrader_dev/'+@SelfieName,'0') AS SelfieNameURL,ISNULL(@SalesAreaName,'0') SalesAreaName,2 WorkingType,FORMAT(@AttenDatetime,'dd-MMM-yyyy, HH:mm','en-us') AttenDatetime,30 AS AllowedGeofence


SELECT    top(1) tblVersionMstr.VersionID , tblVersionMstr.VersionSerialNo, tblVersionDownloadStatusMstr.VersionDownloadStatus,dbo.fncSetDateFormat(GETDATE()) AS ServerDate         
FROM         tblVersionMstr INNER JOIN     tblVersionDownloadStatusMstr ON tblVersionMstr.VersionID = tblVersionDownloadStatusMstr.VersionID 
WHERE tblVersionDownloadStatusMstr.PDACode=@PDACode AND tblVersionDownloadStatusMstr.ApplicationType=@ApplicationType order by tblVersionMstr.VersionID DESC





