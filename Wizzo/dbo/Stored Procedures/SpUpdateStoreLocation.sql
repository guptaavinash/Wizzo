-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE SpUpdateStoreLocation 
	
AS
BEGIN
	SELECT ROW_NUMBER() OVER(PARTITION BY SM.StoreID ORDER BY VisitDate DESC) Sq,SM.StoreID,VM.VisitID,VM.VisitDate,SM.[Lat Code],SM.[Long Code],VM.VisitLatitude,VM.VisitLongitude INTO #Locations FROM tblVisitMaster VM INNER JOIN tblStoreMaster SM ON SM.StoreID=VM.StoreID 
	WHERE CAST(Accuracy AS NUMERIC(10,0))<10 AND VM.IsGeoValidated=0 AND VM.VisitLatitude<>0
	ORDER BY SM.StoreID,VM.VisitDate DESC

	SELECT *,dbo.fnCalcDistanceKM([Lat Code],VisitLatitude,[Long Code],VisitLongitude)*1000 Distance INTO #Data FROM #Locations WHERE StoreID IN (SELECT StoreID FROM #Locations WHERE Sq=3) AND Sq<=3 ORDER BY StoreID

	CREATE TABLE #StoreData(StoreID INT,[LatCode] NUMERIC(27,24),[LongCode] NUMERIC(27,24),VisitLatitude_1 NUMERIC(27,24),VisitLongitude_1 NUMERIC(27,24),Distance_V1_V2 INT,VisitLatitude_2 NUMERIC(27,24),VisitLongitude_2 NUMERIC(27,24),Distance_V1_V3 INT,VisitLatitude_3 NUMERIC(27,24),VisitLongitude_3 NUMERIC(27,24),Distance_V1_S INT)

	INSERT INTO #StoreData(StoreID,LatCode,LongCode)
	SELECT DISTINCT StoreID,[Lat Code],[Long Code] FROM #Data

	UPDATE S SET VisitLatitude_1=L.VisitLatitude,VisitLongitude_1=L.VisitLongitude FROM #StoreData S INNER JOIN #Data L ON L.StoreID=S.StoreID AND L.Sq=1
	UPDATE S SET VisitLatitude_2=L.VisitLatitude,VisitLongitude_2=L.VisitLongitude FROM #StoreData S INNER JOIN #Data L ON L.StoreID=S.StoreID AND L.Sq=2
	UPDATE S SET VisitLatitude_3=L.VisitLatitude,VisitLongitude_3=L.VisitLongitude FROM #StoreData S INNER JOIN #Data L ON L.StoreID=S.StoreID AND L.Sq=3

	UPDATE S SET Distance_V1_V2=dbo.fnCalcDistanceKM(VisitLatitude_1,VisitLatitude_2,VisitLongitude_1,VisitLongitude_2)*1000 FROM #StoreData S
	UPDATE S SET Distance_V1_V3=dbo.fnCalcDistanceKM(VisitLatitude_1,VisitLatitude_3,VisitLongitude_1,VisitLongitude_3)*1000 FROM #StoreData S
	UPDATE S SET Distance_V1_S=dbo.fnCalcDistanceKM(VisitLatitude_1,LatCode,VisitLongitude_1,LongCode)*1000 FROM #StoreData S

	SELECT * FROM #StoreData
	SELECT * INTO #Tobeupdated FROM #StoreData WHERE Distance_V1_S>50 AND Distance_V1_V2<10 AND Distance_V1_V3<10

	UPDATE S SET [Lat Code]=U.VisitLatitude_1,[Long Code]=U.VisitLongitude_1 FROM tblStoreMaster S INNER JOIN #Tobeupdated U ON S.StoreID=U.StoreID

END
