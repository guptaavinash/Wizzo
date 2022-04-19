-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[SpImportHierarchy] 
	
AS
BEGIN
	select A.* from tmpRouteDetails A INNER JOIN (select DSRCode,RouteName from tmpRouteDetails group by DSRCode,RouteName having count(*)>1) B ON A.DSRCode=B.DSRCode AND A. RouteName=B.RouteName order by A.DSRCode,A.RouteName
	
	--SELECT * from tblDBRSalesStructureCoverage ORDER BY 1 DESC

	UPDATE A SET A.DSRAreaId=B.NodeId,A.DSRAreaNodeType=B.NodeType FROM tmpRouteDetails A INNER JOIN tblCompanySalesStructureCoverage B ON A.DSRCode=B.SOERPID 

	UPDATE A SET A.DSRHierId=B.HierId FROM tmpRouteDetails A INNER JOIN tblCompanySalesStructureHierarchy B ON A.DSRAreaId=B.NodeId WHERE B.NodeType=A.DSRAreaNodeType

	INSERT INTO tblCompanySalesStructureRouteMstr(Descr,NodeType,ShortName,LoginIDIns)
	SELECT DISTINCT A.RouteName,140,A.DSRCode,1 FROM tmpRouteDetails A LEFT OUTER JOIN tblCompanySalesStructureRouteMstr B ON A.RouteName=B.Descr AND A.DSRCode=B.ShortName 
	WHERE B.Descr IS NULL AND B.ShortName IS NULL 
	
	UPDATE A SET A.Routeid=B.NodeId,A.RouteNodeType=B.NodeType FROM tmpRouteDetails A INNER JOIN tblCompanySalesStructureRouteMstr B ON A.DSRCode=B.ShortName AND A.RouteName=B.Descr 
	
	--select * from tblCompanySalesStructureHierarchy where NodeType=170 order by 1 desc

	INSERT INTO tblCompanySalesStructureHierarchy(NodeID,NodeType,PNodeID,PNodeType,HierTypeID,PHierId,VldFrom,VldTo)
	SELECT DISTINCT Routeid,RouteNodeType,DSRAreaId,DSRAreaNodeType,2,DSRHierId,GETDATE(),'31-Dec-2050' FROM tmpRouteDetails A LEFT OUTER JOIN tblCompanySalesStructureHierarchy B ON A.Routeid=B.NodeID AND B.NodeType=A.RouteNodeType WHERE  B.NodeId IS NULL AND B.NodeType IS NULL
		
	UPDATE A SET A.RouteHierId=B.HierId FROM tmpRouteDetails A INNER JOIN tblCompanySalesStructureHierarchy B ON A.Routeid=B.NodeId WHERE B.NodeType=A.RouteNodeType
		
	----INSERT INTO tblSalesPersonMapping(PersonNodeID,PersonType,NodeID,NodeType,FromDate,ToDate)
	----SELECT DISTINCT C.DSRId,C.DSRNodeType,A.Routeid,A.RouteNodeType,GETDATE(),'31-Dec-2050' 
	----FROM tmpRouteDetails A INNER JOIN tmpDSRDetails C ON A.DSRCode=C.DSRCode AND A.BranchCode=C.BranchCode
	----LEFT OUTER JOIN tblSalesPersonMapping B ON C.DSRId=B.PersonNodeID AND A.Routeid=B.NodeId AND B.NodeType=A.RouteNodeType AND (CAST(GETDATE() AS DATE) BETWEEN CAST(B.FromDate AS DATE) AND B.toDate)
	----WHERE C.DSRName IS NOT NULL AND C.DSRName<>'Vacant' AND B.PersonNodeID IS NULL AND B.NodeId IS NULL AND B.NodeType IS NULL

	--select * from tblMstrCoverageFrequency
	----UPDATE A SET A.CoverageFrequency='Only 1st Week' FROM tmpRouteDetails A INNER JOIN (SELECT dsrcode,RouteName FROM tmpRouteDetails GROUP BY dsrcode,RouteName HAVING COUNT(DISTINCT [1stDay])=1) B ON A.dsrcode=B.dsrcode AND A.RouteName=B.RouteName WHERE A.CoverageFrequency IS NULL


	UPDATE A SET A.CoverageFrequency='Every Week' FROM tmpRouteDetails A INNER JOIN (SELECT dsrcode,RouteName FROM tmpRouteDetails GROUP BY dsrcode,RouteName HAVING COUNT(DISTINCT [1stDay])=4) B ON A.dsrcode=B.dsrcode AND A.RouteName=B.RouteName WHERE A.CoverageFrequency IS NULL

	UPDATE A SET A.CoverageFrequency='Alternate Week' FROM tmpRouteDetails A INNER JOIN (SELECT dsrcode,RouteName FROM tmpRouteDetails GROUP BY dsrcode,RouteName HAVING COUNT(DISTINCT [1stDay])=2) B ON A.dsrcode=B.dsrcode AND A.RouteName=B.RouteName WHERE A.CoverageFrequency IS NULL

	select distinct CoverageFrequency,CovFrqId from tmpRouteDetails
	--SELECT * FROM tblMstrCoverageFrequency
	UPDATE tmpRouteDetails set CoverageFrequency='Alternate Week' where CoverageFrequency='First,Third,Fifth Week'
	UPDATE tmpRouteDetails set CoverageFrequency='Alternate Week' where CoverageFrequency='Second, Fourth Week'

	update A SET A.CovFrqId=B.CovFrqID FROM tmpRouteDetails A Inner JOIN tblMstrCoverageFrequency B  ON A.CoverageFrequency=B.CovFrq 

	select distinct CoverageFrequency,CovFrqId from tmpRouteDetails
	--ALTER TABLE tmpGTEastData add WeekId int
	
	select *,CAST([1stDay] AS DATE) from tmpRouteDetails where CovFrqId=10 order by [1stDay]
	select * from tmpRouteDetails where CovFrqId=1 order by [1stDay]
	update tmpRouteDetails set [1stDay]=GETDATE() WHERE CovFrqId=1 AND [1stDay] IS NULL
	
	select * from tmpRouteDetails where [1stDay] IS NULL

	SELECT RouteId,RouteNodeType,CovFrqId,MIN([1stDay]) [1stDay] INTO #Details FROM tmpRouteDetails GROUP BY RouteId,RouteNodeType,CovFrqId
	SELECT * FROM #Details

	update A SET A.WeekId=B.WeekId FROM tmpRouteDetails A Inner JOIN 
	(select DISTINCT RouteId,RouteNodeType,A.CovFrqId,[1stDay],MIN(A.WeekId) WeekId FROM tblRoutePlanDetails A INNER JOIN #Details B ON A.CovFrqID=B.CovFrqId
	WHERE weekfrom>= CAST(DATEADD(dd, -(DATEPART(dw, [1stDay])-1), [1stDay]) AS DATE) 
	GROUP BY RouteId,RouteNodeType,A.CovFrqId,[1stDay]) B ON A.RouteId=B.RouteId AND A.RouteNodeType=B.RouteNodeType AND A.CovFrqId=B.CovFrqId

	SELECT DISTINCT Mon FROM tmpRouteDetails 
	SELECT DISTINCT Tue FROM tmpRouteDetails 
	SELECT DISTINCT Wed FROM tmpRouteDetails 
	SELECT DISTINCT Thu FROM tmpRouteDetails 
	SELECT DISTINCT Fri FROM tmpRouteDetails 
	SELECT DISTINCT Sat FROM tmpRouteDetails 
	SELECT DISTINCT Sun FROM tmpRouteDetails 

	UPDATE tmpRouteDetails set Mon=null where Mon='No'
	UPDATE tmpRouteDetails set Tue=null where Tue='No'
	UPDATE tmpRouteDetails set Wed=null where Wed='No'
	UPDATE tmpRouteDetails set Thu=null where Thu='No'
	UPDATE tmpRouteDetails set Fri=null where Fri='No'
	UPDATE tmpRouteDetails set Sat=null where Sat='No'
	UPDATE tmpRouteDetails set Sun=null where Sun='No'

	DECLARE @cur CURSOR,@RouteId INT,@RouteNodeType INT,@Mon VARCHAR(5),@Tue VARCHAR(5),@Wed VARCHAR(5),@Thu VARCHAR(5),@Fri VARCHAR(5),@Sat VARCHAR(5),@Sun VARCHAR(5),@CovFrqId INT,@WeekId INT
	SET @cur = CURSOR FOR
	SELECT DISTINCT RouteId,RouteNodeType,Mon,Tue,Wed,Thu,Fri,Sat,Sun,CovFrqId,WeekId FROM tmpRouteDetails where RouteId IS not null AND CovFrqId IS NOT NULL 
	OPEN @cur
	FETCH NEXT FROM @cur INTO @RouteId,@RouteNodeType,@Mon,@Tue,@Wed,@Thu,@Fri,@Sat,@Sun,@CovFrqId,@WeekId
	WHILE @@FETCH_STATUS=0
	BEGIN
		
		If @Mon IS NOT NULL
		BEGIN			
			INSERT INTO tblRouteCoverage(RouteID,CovFrqID,Weekday,FromDate,ToDate,flgPrimary,LoginIDIns,TimestampIns,LoginIDUpd,TimestampUpd,NodeType,WeekID)
			VALUES(@RouteId,@CovFrqId,1,GETDATE(),'31-Dec-2050',1,1,GETDATE(),NULL,NULL,@RouteNodeType,@WeekId)
		END	
		If @Tue IS NOT NULL
		BEGIN
			INSERT INTO tblRouteCoverage(RouteID,CovFrqID,Weekday,FromDate,ToDate,flgPrimary,LoginIDIns,TimestampIns,LoginIDUpd,TimestampUpd,NodeType,WeekID)
			VALUES(@RouteId,@CovFrqId,2,GETDATE(),'31-Dec-2050',1,1,GETDATE(),NULL,NULL,@RouteNodeType,@WeekId)
		END
		If @Wed IS NOT NULL
		BEGIN
			INSERT INTO tblRouteCoverage(RouteID,CovFrqID,Weekday,FromDate,ToDate,flgPrimary,LoginIDIns,TimestampIns,LoginIDUpd,TimestampUpd,NodeType,WeekID)
			VALUES(@RouteId,@CovFrqId,3,GETDATE(),'31-Dec-2050',1,1,GETDATE(),NULL,NULL,@RouteNodeType,@WeekId)
		END
		If @Thu IS NOT NULL
		BEGIN
			INSERT INTO tblRouteCoverage(RouteID,CovFrqID,Weekday,FromDate,ToDate,flgPrimary,LoginIDIns,TimestampIns,LoginIDUpd,TimestampUpd,NodeType,WeekID)
			VALUES(@RouteId,@CovFrqId,4,GETDATE(),'31-Dec-2050',1,1,GETDATE(),NULL,NULL,@RouteNodeType,@WeekId)
		END
		If @Fri IS NOT NULL
		BEGIN
			INSERT INTO tblRouteCoverage(RouteID,CovFrqID,Weekday,FromDate,ToDate,flgPrimary,LoginIDIns,TimestampIns,LoginIDUpd,TimestampUpd,NodeType,WeekID)
			VALUES(@RouteId,@CovFrqId,5,GETDATE(),'31-Dec-2050',1,1,GETDATE(),NULL,NULL,@RouteNodeType,@WeekId)
		END
		If @Sat IS NOT NULL
		BEGIN
			INSERT INTO tblRouteCoverage(RouteID,CovFrqID,Weekday,FromDate,ToDate,flgPrimary,LoginIDIns,TimestampIns,LoginIDUpd,TimestampUpd,NodeType,WeekID)
			VALUES(@RouteId,@CovFrqId,6,GETDATE(),'31-Dec-2050',1,1,GETDATE(),NULL,NULL,@RouteNodeType,@WeekId)
		END
		If @Sun IS NOT NULL
		BEGIN
			INSERT INTO tblRouteCoverage(RouteID,CovFrqID,Weekday,FromDate,ToDate,flgPrimary,LoginIDIns,TimestampIns,LoginIDUpd,TimestampUpd,NodeType,WeekID)
			VALUES(@RouteId,@CovFrqId,7,GETDATE(),'31-Dec-2050',1,1,GETDATE(),NULL,NULL,@RouteNodeType,@WeekId)
		END
		
		FETCH NEXT FROM @cur INTO @RouteId,@RouteNodeType,@Mon,@Tue,@Wed,@Thu,@Fri,@Sat,@Sun,@CovFrqId,@WeekId
	END
END
