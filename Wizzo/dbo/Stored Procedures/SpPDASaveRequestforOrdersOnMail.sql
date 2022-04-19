
-- =============================================
-- Author:		Avinash Gupta
-- Create date: 05-Jan-2021
-- Description:	
-- =============================================
-- SpPDASaveRequestforOrdersOnMail '60E0117B-EBF4-4AB1-9A6C-B6ADBF600FC7','rajawebhi232003@gmail.com','07-Jan-2021'
CREATE PROCEDURE [dbo].[SpPDASaveRequestforOrdersOnMail] 
	@PDACode VARCHAR(100),
	@EMailID VARCHAR(500),
	@OrderDate Date
AS
BEGIN
	DECLARE @RequestID INT,@flgMarkStatus TINYINT=0
	SELECT @RequestID=0
	SELECT @RequestID=RequestID FROM tblOrderSendOnMailRequest WHERE PDACOde=@PDACode AND DataDate=@OrderDate

	DECLARE @PersonNodeID INT,@PersonNodetype SMALLINT
	SELECT @PersonNodeID=P.NodeID FROM dbo.fnGetPersonIDfromPDACode(@PDACode) U INNER JOIN tblMstrPerson P ON P.NodeID=U.PersonID
	SELECT @PersonNodetype=PersonType FROM tblSalesPersonMapping WHERE PersonNodeID=@PersonNodeID



	IF ISNULL(@RequestID,0)=0
	BEGIN	
		INSERT INTO tblOrderSendOnMailRequest(PDACode,PersonNodeID,PersonNodeType,DataDate,EMailID,flgSendStatus,Failedtext,TimestampIns)
		SELECT @PDACode,@PersonNodeID,@PersonNodetype,@OrderDate,@EMailID,0,NULL,GETDATE()

		SELECT @RequestID=@@IDENTITY
	END

	IF @RequestID>0
		SET @flgMarkStatus=1

	SELECT @flgMarkStatus flgMarkStatus
END
