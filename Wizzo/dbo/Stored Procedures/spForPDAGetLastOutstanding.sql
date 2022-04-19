--exec spForPDAGetLastOutstanding '22-Aug-2018' ,'354010084603910',5,170,1
-- [spForPDAGetLastOutstanding] '05-Sep-2018' ,'911560353114284',0,0,1  
CREATE PROCEDURE [dbo].[spForPDAGetLastOutstanding] 
@Date varchar(50),
@PDACode VARCHAR(50),
@RouteID INT,
@RouteNodeType INT,
@flgAllRoutesData  TINYINT,  -- 1:to show all routes, 0: to show only given route 
@CoverageAreaNodeID INT = 0,
@CoverageAreaNodeType SMALLINT  =0
AS
BEGIN
	DECLARE @PersonID INT     
	DECLARE @PersonType INT  
	DECLARE @VisitDate Date
	--DECLARE @DeviceID INT
	
	SET @VisitDate=CONVERT(Date,@Date,105)

	--SELECT @DeviceID = PDAID FROM tblPDAMaster WHERE PDA_IMEI = @PDA_IMEI OR PDA_IMEI_Sec=@PDA_IMEI   
	--SELECT @PersonID=PersonID, @PersonType=[PersonType] FROM [dbo].[tblPDA_UserMapMaster] WHERE PDAID=@DeviceID  AND (GETDATE() BETWEEN DateFrom AND DateTo)
	SELECT @PersonID=NodeID,@PersonType=NodeType FROM dbo.fnGetPersonIDfromPDACode(@PDACode) U INNER JOIN tblMstrPerson P ON P.NodeID=U.PersonID

	-- Get the Default Route Assigned
	DECLARE @SalesAreaNodeID INT,@SalesAreaNodeType INT

	SELECT @SalesAreaNodeID=SalesAreaNodeID,@SalesAreaNodeType=SalesAreaNodeType FROM tblVanStockMaster V,(SELECT SalesManNodeId,MAX(TransDate) TransDate FROM tblVanStockMaster WHERE SalesManNodeId=@PersonID AND SalesManNodeType=@PersonType AND CAST(TransDate AS DATE)<=CAST(GETDATE() AS DATE) GROUP BY SalesManNodeId) X WHERE X.TransDate=V.TransDate AND X.SalesManNodeId=V.SalesManNodeId

	----SELECT DISTINCT V.DSRRouteNodeID,V.DSRRouteNodeType INTO #TodaysCoverageRoutes FROM VwCompanyDSRFullDetail V WHERE V.DSRAreaID=@SalesAreaNodeID AND V.DSRAreaNodeType=@SalesAreaNodeType 
	
	CREATE TABLE #Routes(RouteID INT,RouteNodeType INT) 
	
	----IF @CoverageAreaNodeID>0 AND @coverageAreaNodeType>0   --- Need the Route list for the DSR.
	----BEGIN
	----	INSERT INTO #Routes(RouteID,RouteNodeType)
	----	SELECT DISTINCT DBRRouteID,RouteNodeType
	----	FROM  VwDistributorDSRFullDetail V WHERE DBRCoverageID=@CoverageAreaNodeID AND DBRCoverageNodeType=@coverageAreaNodeType AND V.DBRCoverageID>0
	----	UNION
	----	SELECT DISTINCT DSRRouteNodeID,DSRRouteNodeType
	----	FROM VwCompanyDSRFullDetail V WHERE DSRAreaID=@CoverageAreaNodeID AND DSRAreaNodeType=@coverageAreaNodeType AND V.DSRAreaID>0
	----END
	----ELSE
	----BEGIN
	----	IF @flgAllRoutesData=1
	----	BEGIN
	----		INSERT INTO #Routes(RouteId,RouteNodeType)
	----		SELECT DISTINCT P.NodeID,P.NodeType 
	----		FROM tblSalesPersonMapping P  
	----		INNER JOIN [tblSecMenuContextMenu] C ON C.NodeType=P.NodeType 
	----		WHERE ISNULL(C.flgRoute,0)=1 AND P.PersonNodeID=@PersonID AND P.PersonType=@PersonType AND (GETDATE() BETWEEN P.FromDate AND ISNULL(P.ToDate,GETDATE()))
	----		UNION
	----		---Additing routes for the different coverage area person is going
	----		SELECT DSRRouteNodeID,DSRRouteNodeType FROM #TodaysCoverageRoutes
	----	END
	----	ELSE
	----	BEGIN
	----		INSERT INTO #Routes(NodeId,NodeType)
	----		SELECT @RouteID,@RouteNodeType
	----	END
	----END
	--SELECT * FROM #Routes

	INSERT INTO #Routes
	SELECT distinct CH.NodeID,CH.NodeType 
	FROM tblSalesPersonMapping P
	INNER JOIN tblCompanySalesStructureHierarchy H ON H.NodeID=P.NodeID AND H.NodeType=P.NodeType
	INNER JOIN tblCompanySalesStructureHierarchy CH ON CH.PHierId=H.HierID
	INNER JOIN [tblSecMenuContextMenu] C ON C.NodeType=CH.NodeType 
	WHERE ISNULL(C.flgRoute,0)=1 AND P.PersonNodeID=@PersonID AND P.PersonType=@PersonType  AND (GETDATE() BETWEEN P.FromDate AND ISNULL(P.ToDate,GETDATE()))
	


	----SELECT DISTINCT RouteNodeId,RouteNodeType FROM tblRouteCalendar RC INNER JOIN tblCompanySalesStructureRoute RM ON RM.NodeID=RC.RouteNodeId AND RC.RouteNodeType=RM.NodeType WHERE RC.SONodeId=@PersonID AND RC.SONodeType=@PersonType 
	
	SELECT V.StoreID, MAX(V.VisitID) AS VisitID, 0 AS flgOrder INTO [#LastVisit]
	FROM tblVisitMaster V INNER JOIN #Routes R ON V.RouteId=R.RouteID AND V.RouteType=R.RouteNodeType                         
	WHERE CAST(VisitDate AS DATE)<=@VisitDate 
	GROUP BY V.StoreID

	--SELECT * FROM [#LastVisit]

	----SELECT DISTINCT V.StoreID,SUM(R.BalanceAmt) Outstanding FROM [#LastVisit] V INNER JOIN tblReceiptMaster R ON R.VisitID=V.VisitID GROUP BY  V.StoreID
	--SELECT DISTINCT V.StoreID,1000 Outstanding FROM [#LastVisit] V INNER JOIN tblReceiptMaster R ON R.VisitID=V.VisitID GROUP BY  V.StoreID
	
select a.CustomerNodeId storeid,a.InvCode,a.NetRoundedAmount-isnull(AdjustedAmount,0) as OutStandingAmt,0 as CreditDays,InvDate,0 as flgOverdue into #OutStanding From tblInvMaster a join tblOutletAddressDet b on  a.storeid=b.OutAddID
  join [#LastVisit] c on c.storeid=b.storeid
  --INNER JOIN
  --                       tblInvPaymentStageMap AS f ON A.InvID = f.InvId
  left join (SELECT        B.RefId, sum(B.AdjustedAmount) as AdjustedAmount
FROM            tblReceiptMaster AS A INNER JOIN
                         tblReceiptAdjustment AS B ON A.RcptId = B.RcptId
WHERE        (B.RefType = 1)   group by B.RefId) d on d.refid=a.invid
 where a.flgInvStatus=1

  --SELECT * FROM #OutStanding

  update A SET flgOverdue=1 FROM #OutStanding A where dateadd(dd,creditdays,InvDate)<convert(date,getdate())

  select Storeid,sum(OutStandingAmt) as OutStanding--,sum(case flgOverdue when 1 then OutStandingAmt else 0 end) as OverDue 
  from #OutStanding a group by Storeid 

  select distinct Storeid,InvCode,format(InvDate,'dd-MMM-yy') as InvDate,OutStandingAmt --,case flgOverdue when 1 then OutStandingAmt else 0 end as OverDue 
  from #OutStanding WHERE OutStandingAmt>0

END







