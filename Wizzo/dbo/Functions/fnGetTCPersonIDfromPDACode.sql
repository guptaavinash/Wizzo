


-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE FUNCTION [dbo].[fnGetTCPersonIDfromPDACode] 
(
	@PDACode VARCHAR(50)
)
RETURNS @Person TABLE
(
	PersonID INT,
	PersonType SMALLINT
)
AS
BEGIN
	DECLARE @asOf datetime2(7) = GETDATE()  
	DECLARE @PersonID INT

	INSERT INTO @Person
	SELECT P.EmpId,800 FROM tblTCEmpMstr P INNER JOIN tblTCPDACodeMapping U ON U.PersonID=P.EmpId WHERE U.PDACode=@PDACode AND @asOf BETWEEN U.ValidFrom AND U.ValidTo
	UNION
	SELECT P.EmpId,800 FROM tblTCEmpMstr P INNER JOIN tblTCPDACodeMapping_History U ON U.PersonID=P.EmpId WHERE U.PDACode=@PDACode

	-- Handling the OLD way of IMEI
	--INSERT INTO @Person
	--SELECT DISTINCT U.TCEmpID,U.EmpType FROM [dbo].[tblTCPDA_UserMapMaster] U INNER JOIN [tblTCPDAMaster] PDA ON PDA.TCPDAID=U.TCPDAID WHERE CAST(GETDATE() AS DATE) BETWEEN U.DateFrom AND U.DateTo AND (PDA.PDA_IMEI=@PDACode OR PDA.PDA_IMEI_Sec=@PDACode)

	RETURN 
END
