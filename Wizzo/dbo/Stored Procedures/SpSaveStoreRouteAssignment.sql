
-- =============================================
-- Author:		Avinash Gupta
-- Create date: 07-Feb-2018
-- Description:	
-- =============================================
-- DROP PROC SpSaveStoreRouteAssignment
CREATE PROCEDURE [dbo].[SpSaveStoreRouteAssignment] 
	@tblStoremapping udt_storemapping ReadOnly,
	@LoginID INT,
	@FromDate SMALLDATETIME,
	@ToDate SMALLDATETIME
AS
BEGIN
	IF @FromDate<=GETDATE() AND @ToDate>GETDATE()
	SET @FromDate=GETDATE()

	--- Making Store Out of Coverage.
	UPDATE RC SET RC.ToDate=DATEADD(d,-1,@FromDate),LoginIDUpd=@LoginID,TimestampUpd=GETDATE() FROM tblRouteCoverageStoreMapping RC INNER JOIN @tblStoremapping M ON M.CurrentRouteNodeID=RC.RouteID AND M.CurrentRouteNodetype=RC.RouteNodeType AND M.StoreID=RC.StoreID WHERE M.flgAction=0 

	-- Adding Stores to the coverage
	INSERT INTO tblRouteCoverageStoreMapping(StoreID,RouteID,RouteNodeType,FromDate,ToDate,LoginIDIns,TimestampIns)
	SELECT DISTINCT M.Storeid,M.NewRouteNodeID,M.NewRouteNodeType,@FromDate,@ToDate,@LoginID,GETDATE() FROM @tblStoremapping M LEFT OUTER JOIN tblRouteCoverageStoreMapping SM ON SM.StoreID=M.storeID AND SM.RouteID=M.NewRouteNodeID AND SM.RouteNodeType=M.NewRouteNodeType WHERE flgAction=1 AND SM.StoreID IS NULL AND ISNULL(M.NewRouteNodeID,0)<>0

	--- Copy Stores To the different routes also.
	INSERT INTO tblRouteCoverageStoreMapping(StoreID,RouteID,RouteNodeType,FromDate,ToDate,LoginIDIns,TimestampIns)
	SELECT DISTINCT M.Storeid,M.NewRouteNodeID,M.NewRouteNodeType,@FromDate,@ToDate,@LoginID,GETDATE() FROM @tblStoremapping M WHERE flgAction=2 AND ISNULL(M.NewRouteNodeID,0)<>0

	--- Transfer Stores from one route to another
	UPDATE RC SET RC.ToDate=DATEADD(d,-1,@FromDate),LoginIDUpd=@LoginID,TimestampUpd=GETDATE() FROM tblRouteCoverageStoreMapping RC INNER JOIN @tblStoremapping M ON M.CurrentRouteNodeID=RC.RouteID AND M.CurrentRouteNodetype=RC.RouteNodeType AND M.StoreID=RC.StoreID WHERE M.flgAction=3 

	INSERT INTO tblRouteCoverageStoreMapping(StoreID,RouteID,RouteNodeType,FromDate,ToDate,LoginIDIns,TimestampIns)
	SELECT DISTINCT M.Storeid,M.NewRouteNodeID,M.NewRouteNodeType,@FromDate,@ToDate,@LoginID,GETDATE() FROM @tblStoremapping M WHERE flgAction=3 AND ISNULL(M.NewRouteNodeID,0)<>0

	UPDATE S SET DBID=D.NewDistributorID,DBnodeType=D.NewDistributorNodeType FROM tblStoreMaster S INNER JOIN @tblStoremapping D ON D.StoreID=S.StoreID WHERE S.DBID<>D.NewDistributorID AND ISNULL(D.NewRouteNodeID,0)<>0

END
