
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[spUpdateFCMTokenNo] 
@IMEINo VARCHAR(100),
@FCMTokenNo VARCHAR(200)
AS
BEGIN
	DECLARE @RptDate DATE=GETDATE()

	DECLARE @PersonNodeID Integer=0 
	DECLARE @PersonNodeType Integer=0 

	SELECT @PersonNodeID=U.PersonID,@PersonNodeType=U.PersonType FROM dbo.fnGetTCPersonIDfromPDACode(@IMEINo) U INNER JOIN tblTCEmpMstr P ON P.EmpId=U.PersonID

	UPDATE C SET C.FCMTokenNo=@FCMTokenNo
	FROM [dbo].[tblTCEmpMstr] C 
	WHERE  C.EmpId=@PersonNodeID
END
