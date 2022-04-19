-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[SpPopulateStoreListForValidation] 
	
AS
BEGIN
----	2,14,15,17,18--- Three consecutive days wuth the same reason
----1,16-- Default
----Invalid number need to check with Ashwani

SELECT T.StoreID,T.Date,T.ReasonID INTO #Last3TARSCalls
FROM
(SELECT DISTINCT T.StoreID,T.Date , ROW_NUMBER() OVER(PARTITION BY T.StoreID ORDER BY T.Date DESC) AS Rnk FROM tblTeleCallerListForDay(nolock) T
) A INNER JOIN tblTeleCallerListForDay(nolock) T ON T.StoreId=A.StoreID AND T.Date=A.Date AND T.ReasonId<>0
WHERE A.Rnk<=3

--SELECT DISTINCT StoreID,COUNT(Date) Countno FROM #Last3TARSCalls GROUP BY StoreID HAVING COUNT(Date)>1  ORDER BY Countno DESC 
--SELECT * FROM #Last3TARSCalls WHERE StoreID=42621
		
---Find the last 3 calls for same reason 
SELECT StoreID,ReasonID,COUNT(DISTINCT Date) NoOfTimes INTO #Storewithsamereasons FROM #Last3TARSCalls GROUP BY StoreID,ReasonID HAVING COUNT(DISTINCT Date)=3

SELECT * FROM #Storewithsamereasons ORDER BY StoreID,ReasonID


SELECT S.StoreID,S.ReasonID INTO #Storewithsamereasonforsomereason FROM #Storewithsamereasons S WHERE ReasonId IN (2,14,15,17,18)

--SELECT * FROM #Storewithsamereasonforsomereason

--- ReasonID=1,16
INSERT INTO tblStoreListForValidation
SELECT DISTINCT D.StoreID,D.reasonID,GETDATE(),NULL,D.TCNodeID,D.TCNodeType,D.Callmade FROM tblTeleCallerListForDay D INNER JOIN tblReasonCodeMstr R ON R.ReasonCodeID=D.ReasonId AND R.ReasonCodeID IN (1,16) LEFT OUTER JOIN tblStoreListForValidation V ON V.StoreID=D.SToreID 
WHERE D.[Date]=CAST(DATEADD(d,-1,GETDATE()) AS DATE) AND V.StoreID IS NULL 

--- ReasonID=2,14,15,17,18
INSERT INTO tblStoreListForValidation
SELECT DISTINCT D.StoreID,D.reasonID,GETDATE(),NULL,D.TCNodeID,D.TCNodeType,D.Callmade FROM tblTeleCallerListForDay D INNER JOIN #Storewithsamereasonforsomereason S ON S.StoreId=D.StoreId AND S.ReasonId=D.ReasonId LEFT OUTER JOIN tblStoreListForValidation V ON V.StoreID=D.SToreID 
WHERE D.[Date]=CAST(DATEADD(d,-1,GETDATE()) AS DATE) AND V.StoreID IS NULL

--- ReasonID=0 and ISValidContactNo=1
SELECT StoreID,MAX(Date) LAstCallDate INTO #LAstCall FROM tblTeleCallerListForDay(nolock) GROUP BY StoreID

--SELECT * FROM #LAstCall

INSERT INTO tblStoreListForValidation
SELECT DISTINCT D.StoreID,1,GETDATE(),NULL,D.TCNodeID,D.TCNodeType,D.Callmade FROM tblTeleCallerListForDay D INNER JOIN #LAstCall L ON L.StoreId=D.StoreId AND L.LAstCallDate=D.Date  LEFT OUTER JOIN tblStoreListForValidation V ON V.StoreID=D.SToreID 
WHERE D.IsValidContactNo=0 AND D.[Date]=CAST(DATEADD(d,-1,GETDATE()) AS DATE)  AND V.StoreID IS NULL





END
