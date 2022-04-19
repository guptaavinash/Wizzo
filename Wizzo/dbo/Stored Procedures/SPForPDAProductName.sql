--SPForPDAProductName    '352801088236109','1','140'
--SPForPDAProductName    'E70AABC7-6737-4D28-AAD9-660464562710','1','33'

CREATE PROCEDURE [dbo].[SPForPDAProductName] --'123',0           

@PDACode VARCHAR(50),      

@RouteID INT,

@RouteNodeType INT     



AS          

BEGIN
	PRINT '1=' + FORMAT(GETDATE(),'dd-MMM-yyyy hh:mm:ss tt')

	DECLARE @DeviceID INT

	DECLARE @PersonID INT     

	DECLARE @PersonType INT    

	DECLARE @ChannelId INT=0



	--SELECT @DeviceID = PDAID FROM tblPDAMaster WHERE PDA_IMEI = @IMEINO OR PDA_IMEI_Sec=@IMEINO

	--PRINT 'DeviceID=' + CAST(ISNULL(@DeviceID,0) AS VARCHAR)



	--SELECT @PersonID=PersonID, @PersonType=[PersonType] FROM [dbo].[tblPDA_UserMapMaster] WHERE PDAID=@DeviceID  AND (GETDATE() BETWEEN DateFrom AND DateTo)
	SELECT @PersonID=NodeID,@PersonType=NodeType FROM dbo.fnGetPersonIDfromPDACode(@PDACode) U INNER JOIN tblMstrPerson P ON P.NodeID=U.PersonID

	PRINT 'PersonID=' + CAST(@PersonID AS VARCHAR)          

	PRINT 'PersonType=' + CAST(@PersonType AS VARCHAR)

	

	SELECT P.NodeID,P.NodeType INTO #CoverageArea 

	FROM tblSalesPersonMapping P 

	INNER JOIN [tblSecMenuContextMenu] C ON C.NodeType=P.NodeType 
	WHERE ISNULL(C.flgCoverageArea,0)=1 AND P.PersonNodeID=@PersonID AND P.PersonType=@PersonType AND (GETDATE() BETWEEN P.FromDate AND ISNULL(P.ToDate,GETDATE()))



	  SELECT @ChannelId=A.ChannelID

	  from tblSalesHierChannelMapping(nolock) A INNER JOIN #CoverageArea B ON A.SalesStructureNodID=B.NodeId AND A.SalesStructureNodType=B.NodeType

	  WHERE (GETDATE() BETWEEN A.FromDate AND ISNULL(A.ToDate,GETDATE()))

	  PRINT 'ChannelId=' + CAST(ISNULL(@ChannelId,0) AS VARCHAR)



	  PRINT '2=' + FORMAT(GETDATE(),'dd-MMM-yyyy hh:mm:ss tt')

		--SELECT ProductTypeNodeID AS CatID, A.SKUNodeID AS ProductID,SKUShortDescr AS ProductShortName, CASE UOM WHEN 'ML' THEN 'Lt' WHEN 'Gms' THEN 'Kg' WHEN UOM THEN 'PCS' ELSE UOM  END AS DisplayUnit, 0 AS CalculateKilo,ProductType,Category+'|'+ProductType+'|'+BrandName+'|'+ SKU + '|All' AS SearchField,0 AS ManufacturerID,M.MRP AS ProductMRP, ROUND(CAST(M.StandardRate AS NUMERIC(18,2)),2) AS ProductRLP, M.Tax AS ProductTaxAmount,isnull(M.RetMarginPer,0) AS RetMarginPer,isnull(M.Tax,0) AS Tax,M.StandardRate, M.StandardRateBeforeTax,M.StandardTax,1 AS KGLiter,tblPrdSKUSalesMapping.BusinessSegmentId AS StoreCatNodeId,1 as PrdOrdr 

		--FROM    VwSFAProductHierarchy A  inner Join tblPrdMstrSKULvl M On A.SKUNodeID=M.NodeID inner join tblPrdSKUSalesMapping On tblPrdSKUSalesMapping.SKUNodeID=M.NodeID

		--ORDER BY  ProductType,SKUShortDescr     



	IF ISNULL(@ChannelId,0)=0

		SET @ChannelId=1





	CREATE TABLE #PrdList(CatID INT,ProductID INT,ProductShortName VARCHAR(1000),DisplayUnit VARCHAR(10),CalculateKilo INT,KGLiter FLOAT,ProductType VARCHAR(200),SearchField VARCHAR(1000),ManufacturerID INT,PrdOrdr INT IDENTITY(1,1),RptUnitName VARCHAR(20),PerbaseUnit INT,HSNCode VARCHAR(20),ImageURL VARCHAR(200),flgActive TINYINT,UOMType VARCHAR(100),PcsInBox INT,UOMValue INT)



	INSERT INTO #PrdList(CatID,ProductID,ProductShortName,DisplayUnit,CalculateKilo,KGLiter,ProductType,SearchField,ManufacturerID,HSNCode,ImageURL,flgActive,UOMType,PcsInBox,UOMValue)

	SELECT     CategoryNodeId AS CatID, A.SKUNodeID AS ProductID,SKUShortDescr   AS ProductShortName, CASE UOM WHEN 'ML' THEN 'Lt' WHEN 'Gms' THEN 'Kg' WHEN 'Pieces' THEN 'Pcs' ELSE UOM  END AS DisplayUnit, 0 AS CalculateKilo,isnull(Grammage * 1000,1000) AS KGLiter,Category AS ProductType,Category+'|'+ SKU + '|All' AS SearchField,0 AS ManufacturerID,left(HSNCode,4),'http://www.rajsuperwhite.in/RajTraders_Prd_Photos/' + A.PhotoName,IsActive, CAST(A.UOMValue AS VARCHAR)+ ' ' + A.UOMType ,A.PcsInBox,A.UOMValue

	FROM VwSFAProductHierarchy A ORDER BY A.SKUOrdr
	--INNER JOIN tblPrdSKUSalesMapping B ON A.SKUNodeID=B.SKUNodeID AND A.SKUNodeType=B.SKUNodeType 

	PRINT '3=' + FORMAT(GETDATE(),'dd-MMM-yyyy hh:mm:ss tt')

	UPDATE P SET RptUnitName=U.BUOMName,PerbaseUnit=RU.ConversionFactor FROM #PrdList P INNER JOIN tblPrdMstrRptngUnits_ConversionUnits(nolock) RU ON RU.SKUID=P.ProductID INNER JOIN [dbo].[tblPrdMstrBUOMMaster] U ON U.BUOMID=RU.RptngUnitID

	SELECT * FROM #PrdList ORDER BY PrdOrdr

	PRINT '4=' + FORMAT(GETDATE(),'dd-MMM-yyyy hh:mm:ss tt')

	SELECT NodeID as ProductId,1 AS BusinessSegmentId,0 as SegmentNodeId,M.MRP AS ProductMRP, ROUND(CAST(M.StandardRate AS NUMERIC(18,2)),2) AS ProductRLP, ISNULL(M.StandardTax,0) AS ProductTaxAmount,ISNULL(M.RetMarginPer,0) AS RetMarginPer,isnull(M.Tax,0) AS Tax,ROUND(M.StandardRate,2) StandardRate,ROUND(M.StandardRateBeforeTax,2) StandardRateBeforeTax,ROUND(M.StandardTax,2) StandardTax,S.flgPriceAva ,1 as flgPrdBulkPriceapplicable,10000 as Cutoffvalue,0 StandardRateWholeSale,0 StandardRateBeforeTaxWholeSale,0 StandardTaxWholeSale,HSNCode,M.PrcLocationId RegionID,M.UOMID

	from tblPrdMstrSKULvl(nolock) S INNER JOIN tblPrdSKUSalesMapping(nolock) M ON M.SKUNodeId=S.NodeID AND M.SKUNodeType=S.NodeType  WHERE S.IsActive=1 AND CAST(GETDATE() AS DATE) BETWEEN M.FromDate AND M.ToDate

	ORDER BY UOMValue


	PRINT '5=' + FORMAT(GETDATE(),'dd-MMM-yyyy hh:mm:ss tt')
	SELECT 1 AS DiscountLevel,10000 as cutoffvalue 


	SELECT BUOMID,BUOMName,CASE BUOMName WHEN 'Pieces' THEN 1 ELSE 0 END flgRetailUnit FROM tblPrdMstrBUOMMaster
	SELECT SKUID NodeID,NodeType,BaseUOMID,PackUOMID,RelConversionUnits,flgVanLoading FROM [dbo].[tblPrdMstrPackingUnits_ConversionUnits](nolock)
	UNION
	SELECT DISTINCT SKUID,NodeType,3,3,1,0 FROM  [tblPrdMstrPackingUnits_ConversionUnits](nolock) WHERE BaseUOMID=3

	PRINT '6=' + FORMAT(GETDATE(),'dd-MMM-yyyy hh:mm:ss tt')
	SELECT prdID NodeID,20 NodeType,UOMID BUOMID,flgDistOrder,flgDistInv,flgStoreCheck,flgRetailUnit,flgTransactionData,flgDistributorCheck FROM tblPrdMstrTransactionUOMConfig(nolock)

	SELECT DISTINCT P.CatID,UOMType,RelConversionUnits RelConversionUnits FROM [tblPrdMstrPackingUnits_ConversionUnits] C INNER JOIN #PrdList P ON P.ProductID=C.SKUId WHERE C.BaseUOMID=3 AND P.flgActive=1  ORDER BY CatID,UOMType --- For Pcs Only
	PRINT '7=' + FORMAT(GETDATE(),'dd-MMM-yyyy hh:mm:ss tt')
END        







      
























