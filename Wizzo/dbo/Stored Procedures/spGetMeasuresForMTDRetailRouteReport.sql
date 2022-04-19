

--EXEC [spGetMeasuresForMTDRetailRouteReport] 0
CREATE PROCEDURE [dbo].[spGetMeasuresForMTDRetailRouteReport]
@flgType TINYINT=0	--0:All Measures
AS
BEGIN
	
	SELECT Id AS HireId,Id AS HireId_Org,Measure AS Descr,NULL AS PHireId,NULL AS PHireId_Org,Id AS NodeId,2 as NodeType,2 as LstLevel,Ordr
	FROM [dbo].tblMeasureListForMTDRetailRouteReport WHERE Flg=1 AND PId=0
	UNION ALL
	SELECT Id AS HireId,Id AS HireId_Org,Measure AS Descr,PId AS PHireId,PId AS PHireId_Org,Id AS NodeId,1 as NodeType,1 as LstLevel,Ordr
	FROM [dbo].tblMeasureListForMTDRetailRouteReport WHERE Flg=1 AND PId<>0 ORDER BY Ordr
	
END













