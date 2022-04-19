-- Author:		Avinash Gupta
-- Create date: 07Apr2015
-- Description:	
-- =============================================
CREATE PROCEDURE [dbo].[SpGetPersonDetails] 
	
AS
BEGIN
	CREATE TABLE #tblPersonDetail(PersonID INT,PersonName VARCHAR(500),PersonEmail VARCHAR(200),PersonPhone VARCHAR(20),WorkingLoc VARCHAR(500),PersonNodeType INT,flgAssigned TINYINT Default 0, flgCompanyPerson TINYINT)
	INSERT INTO #tblPersonDetail(PersonID ,PersonName,PersonEmail,PersonPhone,PersonNodeType,flgCompanyPerson)
	SELECT DISTINCT SEM.NodeID,SEM.Descr,SEM.PersonEMailID,SEM.PersonPhone,SEM.NodeType,flgCompanyPerson
	FROM tblMstrPerson SEM	WHERE GETDATE() BETWEEN FromDate AND ToDate

	UPDATE SEM SET WorkingLoc=dbo.FuncGetPersonName(PM.NodeID,PM.NodeType),flgAssigned=1 FROM #tblPersonDetail SEM INNER JOIN tblSalesPersonMapping PM ON SEM.PersonID=PM.PersonNodeID
	WHERE Getdate() BETWEEN FromDate AND ToDate

	SELECT PersonID ,PersonName,PersonEmail,PersonPhone,WorkingLoc,PersonNodeType,flgAssigned,flgCompanyPerson FROM #tblPersonDetail

	SELECT NodeType,PersonType FROM tblPMstNodeTypes WHERE PersonType IS NOT NULL 
	UNION ALL
	SELECT 0,0 ORDER BY NodeType
END


