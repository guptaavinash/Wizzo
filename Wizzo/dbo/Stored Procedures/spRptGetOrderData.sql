-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
--EXEC [spRptGetOrderData] '01-Feb-2022','09-Feb-2022'
CREATE PROCEDURE [dbo].[spRptGetOrderData] 
@FromDate DATE,
@ToDate Date
AS
BEGIN
	SELECT DISTINCT aa.OrderCode + '/' + DBr.DistributorCode AS [Order No],vw.RSMArea AS [RSM Area],Vw.RSM,Vw.StateHeadArea AS StateHead,vw.ASMArea AS ASM,MP.Code [ASE /TSI/PSR/SR Erp Id],MP.Descr AS [User],Mp.Designation AS [User Designation],DBr.Descr AS Distributor,DBR.DistributorCode [Distributor Erp Id],dbr.GSTNo AS [Distributor GSTIN],S.Descr AS [Distributor State],R.Descr AS [Route],R.RouteCode AS [Route ErpId],SM.StoreCode AS [Outlets Erp Id],SM.StoreName AS [Outlets Name],OC.FName [Owner's Name],ISNULL(OC.MobNo,OC.LandLineNo1) AS [Owner's No],OC.EMailID AS [Outlet's EmailId],OD.StoreAddress1 AS [Address],SM.Market,Od.City,OD.[State],FORMAT(SM.FileSetIdTimeStamp,'dd-MMM-yyyy') AS [Outlet Created On],
	VM.VisitDate, ISNULL(FORMAT(AA.OrderDate,'dd-MMM-yyyy'),'NA') AS [Order Date],FORMAT(CAST(VM.DeviceVisitStartTS AS DATETIME),'HH:mm') AS [Time], AA.Category AS [PrimaryCategory],CAST(AA.UOMValue AS VARCHAR) + ' ' + AA.UOMType AS SecondaryCategory,AA.SKU AS Product,AA.SKUCode AS [Product ErpId],

	AA.QtyInCase [Qty (StdUnit)],AA.UOM AS [Standard Unit],AA.QtyInPcs AS [Qty (Unit)],'PCS' AS Unit,

	AA.FreeQty AS [Scheme Quantity],CAST(AA.TotLineDiscVal AS DECIMAL(18,2)) AS [Cash Discount],AA.MRP AS [Product MRP],AA.PrdPrice AS Price,CAST(AA.LineOrderVal AS DECIMAL(18,2)) AS [Sale Value],CAST(AA.LineOrderValWDisc AS DECIMAL(18,2)) AS [Net Value],CAST(AA.NetLineOrderVal AS DECIMAL(18,2)) AS [Net Value Tax Inclusive],RE.NoOrderReason AS [No Sales Reason],SM.ShopType AS [Outlets Type],SM.Segmentation AS [Outlets Segmentation],CASE VM.flgTelephoniccall WHEN 1 THEN 'Yes' ELSE 'No' END AS [Is Telephonic],CASE VM.IsGeoValidated WHEN 1 THEN 'On Site' ELSE 'Off Site' END AS [On/Off Site Visit],RIGHT('00' + CAST((DATEDIFF(ss,VM.DeviceVisitStartTS,VM.DeviceVisitEndTS) / 60) % 60 AS VARCHAR),2) + ':' + RIGHT('00' + CAST(DATEDIFF(ss,VM.DeviceVisitStartTS,VM.DeviceVisitEndTS) % 60 AS VARCHAR),2) [Time Spent on Call(MM:SS)],
	CAST(ROUND((AA.OrderQty * AA.ProductGrammage),2) AS FLOAT) OrderQtyInKG--,DATEDIFF(ss,VM.DeviceVisitStartTS,VM.DeviceVisitEndTS) TimeSpentInStore_InSS
	FROM tblVisitMaster(nolock) VM INNER JOIn tblStoreMaster(nolock) SM ON VM.StoreID=SM.StoreID
	INNER JOIN tblCompanySalesStructureRouteMstr(nolock) R ON VM.RouteID=R.NodeID AND VM.RouteType=R.NodeType
	INNER JOIN tblMstrPerson(nolock) MP ON VM.EntryPersonNodeID=MP.NodeID
	INNER JOIN tblSalesPersonMapping(nolock) SP ON MP.NodeID=SP.PersonNodeID AND (VM.VisitDate BETWEEN Sp.FromDate AND Sp.ToDate)
	INNER JOIN VwCompanyDSRFullDetail vw ON SP.NodeID=vw.DSRAreaID AND SP.NodeType=vw.DSRAreaNodeType
	LEFT JOIN tblReasonNoOrder(nolock) RE ON VM.NoOrderReasonID=RE.NoOrderReasonID
	LEFT JOIN tblOutletContactDet(nolock) OC ON Sm.StoreID=Oc.StoreID AND OC.OutCnctpersonTypeID=1
	LEFT JOIN tblOutletAddressDet(nolock) OD ON SM.StoreID=OD.StoreID AND OD.OutAddTypeID=1
	LEFT JOIN tblDBRSalesStructureDBR(nolock) DBR ON SM.DBID=DBR.NodeID AND SM.DBNodeType=Dbr.NodeType
	LEFT JOIN tblLocLvl2(nolock) S ON Dbr.StateId=S.NodeID
	LEFT JOIN (SELECT OM.OrderDate,OM.VisitID,OM.OrderCode,Od.ProductID,vwPrd.Category,vwPrd.SKUCode,vwPrd.SKU,vwprd.UOMValue,vwPrd.UOMType,vwPrd.UOM,OD.OrderQty,OD.FreeQty,C.RelConversionUnits,

	ROUND(CAST(OD.OrderQty AS FLOAT)/C.RelConversionUnits,2) AS QtyInCase,OD.OrderQty AS QtyInPcs,
	
	vwPrd.MRP,Od.TotLineDiscVal, Od.LineOrderVal, OD.LineOrderValWDisc,OD.NetLineOrderVal,CAST(OD.NetLineOrderVal/OD.OrderQty AS DECIMAL(18,2)) AS PrdPrice,
	vwPrd.Grammage ProductGrammage
	FROM tblOrderMaster(nolock) OM INNER JOIN tblOrderDetail(nolock) OD ON OM.OrderID=OD.OrderID INNER JOIN VwSFAProductHierarchy vwPrd ON OD.ProductID=vwPrd.SKUNodeID INNER JOIN tblPrdMstrPackingUnits_ConversionUnits(nolock) C ON OD.ProductID=C.SKUID INNER JOIN tblStoreMaster(nolock) SM ON OM.StoreID=SM.StoreID 
	--INNER JOIN tblPrdSKUSalesMapping M ON vwPrd.SKUNodeID=M.SKUNodeId AND vwPrd.SKUNodeType=M.SKUNodeType AND SM.RegionId=M.PrcLocationId 
	--AND (OM.OrderDate BETWEEN M.FromDate AND M.ToDate AND M.UOMID=3)
	WHERE OM.OrderDate BETWEEN @FromDate AND @ToDate and OM.OrderStatusID <>3) AA 
	ON VM.VisitID=AA.VisitID AND VM.VisitDate=AA.OrderDate WHERE VM.VisitDate BETWEEN @FromDate AND @ToDate

END
