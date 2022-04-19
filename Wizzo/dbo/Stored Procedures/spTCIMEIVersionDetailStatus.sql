
-- [spIMEIVersionDetailStatus] 1,'1234567890' ,1,''  

CREATE PROCEDURE [dbo].[spTCIMEIVersionDetailStatus] --7,'911348700252142'          
@VersionID integer,          
@IMEINo varchar(100),  
@ApplicationType int,-- =1 
@FCMTokenNo varchar(200) ='' 

AS          

DECLARE @flgUserAuthenticated TINYINT -- 0=User Not Authenticated ,1=Authenticated.
DECLARE @CurrentVersionNumber integer=0 -- 0=No Version released, >0 Latest versionID released.
DECLARE @PersonName VARCHAR(200)='Abhi'

DECLARE @FlgRegistered TINYINT=0

DECLARE @PersonNodeID Integer=0 
DECLARE @PersonNodeType Integer=0 

DECLARE @CoverageAreaNodeID INT
DECLARE @CoverageAreaNodeType SMALLINT

DECLARE @PDAID INT=0

SET @flgUserAuthenticated=0



INSERT INTO tblVersionDownload_Log(VersionID,IMEINo,ApplicationType)
VALUES (@VersionID,@IMEINo,@ApplicationType)

SELECT @PersonNodeID=U.PersonID,@PersonNodeType=U.PersonType FROM dbo.fnGetTCPersonIDfromPDACode(@IMEINo) U INNER JOIN tblTCEmpMstr P ON P.EmpId=U.PersonID


--SELECT  @PersonNodeID=UM.EmpID,@PersonNodeType=UM.EmpType,@PDAID=tblPDAMaster.PDAID  FROM         tblPDAMaster INNER JOIN
--tblPDA_UserMapMaster UM ON tblPDAMaster.PDAID = UM.PDAID 
--WHERE     (tblPDAMaster.PDA_IMEI = @IMEINo OR tblPDAMaster.PDA_IMEI_Sec=@IMEINo) AND (GETDATE() BETWEEN UM.DateFrom AND UM.DateTo) 


IF @PersonNodeID=0 AND @PersonNodeType=0
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

	IF NOT EXISTS (SELECT 1 FROM tblNotReleaseIMEIVersionMstr WHERE IMEINo=@IMEINo)
	BEGIN
	   	 DECLARE @chkIMEIExistOrNot int          
		Set @chkIMEIExistOrNot= (select Count(PDACode) from tblVersionDownloadStatusMstr where PDACode=@IMEINo AND tblVersionDownloadStatusMstr.ApplicationType=@ApplicationType and VersionID=@CurrentVersionNumber)          
		IF(@chkIMEIExistOrNot=0)          
		BEGIN 
			INSERT INTO tblVersionDownloadStatusMstrHistory(VersionID,PDACode,VersionDownloadDate,VersionDownloadStatus,ApplicationType)
			SELECT 	VersionID,PDACode,VersionDownloadDate,VersionDownloadStatus,ApplicationType FROM tblVersionDownloadStatusMstr  where PDACode=@IMEINo AND tblVersionDownloadStatusMstr.ApplicationType=@ApplicationType 
			Delete From tblVersionDownloadStatusMstr where PDACode=@IMEINo AND tblVersionDownloadStatusMstr.ApplicationType=@ApplicationType 
			IF @VersionID=@CurrentVersionNumber
				Insert into  tblVersionDownloadStatusMstr (VersionID,PDACode,VersionDownloadStatus,ApplicationType,VersionDownloadDate) values(@CurrentVersionNumber,@IMEINo,0,@ApplicationType,GETDATE())          
			ELSE
				Insert into  tblVersionDownloadStatusMstr (VersionID,PDACode,VersionDownloadStatus,ApplicationType) values(@CurrentVersionNumber,@IMEINo,1,@ApplicationType)          
		END
		Else
		BEGIN
			IF @VersionID=@CurrentVersionNumber
			BEGIN
				Update tblVersionDownloadStatusMstr SET VersionDownloadStatus=0, VersionDownloadDate=GETDATE() where PDACode=@IMEINo AND  tblVersionDownloadStatusMstr.ApplicationType=@ApplicationType and tblVersionDownloadStatusMstr.VersionID=@CurrentVersionNumber and
				 VersionDownloadStatus=1
			END
			ELSE
			BEGIN
				Update tblVersionDownloadStatusMstr SET VersionDownloadStatus=1, VersionDownloadDate=GETDATE() where PDACode=@IMEINo AND  tblVersionDownloadStatusMstr.ApplicationType=@ApplicationType and tblVersionDownloadStatusMstr.VersionID=@CurrentVersionNumber 
			END			
		END
	END        
END



SELECT @flgUserAuthenticated flgUserAuthenticated,@PersonName AS PersonName,@PersonNodeID AS PersonNodeID,@PersonNodeType AS PersonNodeType

SELECT    top(1) tblVersionMstr.VersionID , tblVersionMstr.VersionSerialNo, tblVersionDownloadStatusMstr.VersionDownloadStatus,dbo.fncSetDateFormat(GETDATE()) AS ServerDate         
FROM         tblVersionMstr INNER JOIN     tblVersionDownloadStatusMstr ON tblVersionMstr.VersionID = tblVersionDownloadStatusMstr.VersionID 
WHERE tblVersionDownloadStatusMstr.PDACode=@IMEINo AND tblVersionDownloadStatusMstr.ApplicationType=@ApplicationType order by tblVersionMstr.VersionID DESC

IF @FCMTokenNo  <>''
BEGIN
DECLARE @Date DATETIME
SET @Date=GETDATE()
EXEC spUpdateFCMTokenNo  @IMEINo,@FCMTokenNo
END
