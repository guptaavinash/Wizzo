-- =============================================
-- Author:		Avinash Gupta
-- Create date: 04-Oct-2021
-- Description:	
-- =============================================
CREATE PROCEDURE [dbo].[SpRptContactDetailUpdate] 
	
AS
BEGIN
	CREATE TABLE #tblContactUpdate(PersonID INT,StoreID INT,TeleCallerName VARCHAR(100),StateName VARCHAR(100),City VARCHAR(100),REgion VARCHAR(100),RSMName VARCHAR(100),ASMArea VARCHAR(100),ASMName VARCHAR(100),TSI VARCHAR(200),RouteName VARCHAR(100),StoreCode VARCHAR(50),StoreName VARCHAR(100),REason VARCHAR(50),[Old ContactNumber] VARCHAR(20),[New COnatct Number] VARCHAR(20),DateAdded Date,[Update Date] Date,[Datetime Update] Datetime)

	INSERT INTO #tblContactUpdate(PersonID,StoreID,StateName,City,TSI,StoreCode,StoreName,REason,[Old ContactNumber],[New COnatct Number],DateAdded,[Update Date],[Datetime Update])
	SELECT DISTINCT NodeID,StoreID,Statename,City,TSI,StoreCode,StoreName,REason,[Old Contact Number],[New Contact Number],DatetimeSentForValidation,UpdateDate,[Datetime Update] FROM VwContactUpdateData V WHERE V.flgActive=1

	UPDATE T SET REgion=V.RSMArea,RSMName=RSM,ASMArea=V.ASMArea,ASMName=ASM FROM #tblContactUpdate T INNER JOIN VwCompanyDSRFullDetail V ON V.CompanyDSRID=T.PersonID

	--SELECT * FROM #tblContactUpdate

	UPDATE C SET RouteName=R.Descr FROM #tblContactUpdate C INNER JOIN tblRouteCalendar(nolock) RC ON RC.StoreId=C.StoreID AND RC.SONodeId=C.PersonID  INNER JOIN tblCompanySalesStructureRouteMstr R ON R.NodeID=RC.RouteNodeId AND R.NodeType=RC.RouteNodeType

	SELECT T.StoreId,ReasonId,MAX(Date) LAstStatus INTO #LastREasonCap FROM tblTeleCallerListForDay(nolock) T INNER JOIN #tblContactUpdate C ON C.StoreID=T.StoreId GROUP BY T.StoreId,ReasonId

	UPDATE C SET TeleCallerName=M.TeleCallerName FROM #tblContactUpdate C INNER JOIN tblTeleCallerListForDay T ON T.StoreId=C.StoreID INNER JOIN #LastREasonCap R ON R.StoreID=T.StoreId AND R.ReasonId=T.ReasonId AND R.LAstStatus=T.Date
	
	INNER JOIN [tblTeleCallerMstr] M ON M.TeleCallerId=T.TCNodeId 

	SELECT REgion,RSMName,ASMArea,ASMName,StateName,City,TeleCallerName,TSI,RouteName,StoreCode,StoreName,REason,[Old ContactNumber],[New COnatct Number],FORMAT([Update Date],'dd-MMM') [Update Date],FORMAT([Datetime Update],'dd-MMM-yyyy hh:mm tt')[Datetime Update] FROM #tblContactUpdate
END
