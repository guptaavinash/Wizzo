
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[spSFAUpdateFCMTokenNo] 
@IMEINo VARCHAR(100),
@FCMTokenNo VARCHAR(200)
AS
BEGIN
	DECLARE @RptDate DATE=GETDATE()

	DECLARE @PersonNodeID Integer=0 
	DECLARE @PersonNodeType Integer=0 

	SELECT @PersonNodeID=U.PersonID,@PersonNodeType=U.PersonType FROM dbo.fnGetPersonIDfromPDACode(@IMEINo) U INNER JOIN tblMstrperson P ON P.NodeID=U.PersonID

	UPDATE C SET C.FCMTokenNo=@FCMTokenNo
	FROM [dbo].tblMstrperson C 
	WHERE  C.NodeID=@PersonNodeID
END
