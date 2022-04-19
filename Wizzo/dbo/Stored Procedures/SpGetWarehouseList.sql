-- =============================================

-- Author:		<Author,,Name>

-- Create date: <Create Date,,>

-- Description:	<Description,,>

-- =============================================

-- [SpGetWarehouseList] '314D6CE8-0C6A-4635-9D75-04AC1A56F27A'

CREATE PROCEDURE [dbo].[SpGetWarehouseList] --''

	@PDACode VARCHAR(50)='' 
	--SELECT * FROM tblDBRSalesStructureDBR
AS

BEGIN
DECLARE @DeviceID INT
	CREATE TABLE #SuppList(ident int identity(1,1),NodeID INT,NodeType INT, Descr VARCHAR(200),[lat Code] NUMERIC(26,22),[Long Code] NUMERIC(26,22),flgMapped TINYINT,flgStockManage TINYINT,Address VARCHAR(500),[MapState] VARCHAR(200),City VARCHAR(200),PinCode BIGINT,PhoneNo VARCHAR(20),TaxNumber VARCHAR(20),flgDefault TINYINT,EMailID VARCHAR(500) DEFAULT 'NA')


	--SELECT @DeviceID = PDAID FROM tblPDAMaster WHERE PDA_IMEI = @PDAIMEI OR PDA_IMEI_Sec=@PDAIMEI
	DECLARE @PersonID INT,@PersonType SMALLINT
	SELECT @PersonID=NodeID,@PersonType=NodeType FROM dbo.fnGetPersonIDfromPDACode(@PDACode) U INNER JOIN tblMstrPerson P ON P.NodeID=U.PersonID

	PRINT '@PersonID=' + CAST(ISNULL(@PersonID,0) AS VARCHAR)
	PRINT '@PersonType=' + CAST(ISNULL(@PersonType,0) AS VARCHAR)

	CREATE TABLE #CoverageArea(NodeID INT,NodeType SMALLINT)

		IF @PersonType IN (220,230)
		BEGIN
			INSERT INTO  #CoverageArea
			SELECT DISTINCT P.NodeID,P.NodeType  
			FROM tblSalesPersonMapping P     
			INNER JOIN [dbo].[tblSecMenuContextMenu] S ON S.NodeType=P. NodeType     
			WHERE P.PersonNodeID=@PersonID AND P.PersonType=@PersonType AND (GETDATE() BETWEEN P.FromDate AND ISNULL(P.ToDate,GETDATE())) AND S.flgCoverageArea=1
		END
		ELSE IF @PersonType=210
			INSERT INTO  #CoverageArea
			SELECT DISTINCT V.DSRAreaID,V.DSRAreaNodeType  
			FROM tblSalesPersonMapping P INNER JOIN [dbo].[VwCompanySalesHierarchy] V ON V.ASMAreaID=P.NodeID AND V.ASMAreaNodeType=P.NodeType 
			WHERE P.PersonNodeID=@PersonID AND P.PersonType=@PersonType AND (GETDATE() BETWEEN P.FromDate AND ISNULL(P.ToDate,GETDATE()))  


	SELECT NodeID,Nodetype,REPLACE(dbo.fnGetWorkingTypeForCoverageArea(NodeID,NodeType),0,2) WorkingTypeID INTO #WorkingType FROM #CoverageArea

	--SELECT * FROM #WorkingType

	DECLARE @WorkingTypeID INT
	SELECT @WorkingTypeID=dbo.fnGetWorkingTypeForCoverageArea(NodeID,NodeType) FROM #CoverageArea
	PRINT '@WorkingTypeID=' + CAST(@WorkingTypeID AS VARCHAR)

	INSERT INTO #SuppList(NodeID,NodeType,Descr,flgMapped,[lat Code],[Long Code],[MapState],City,PinCode,PhoneNo,TaxNumber,Address,flgStockManage,EMailID,flgDefault)
	SELECT DISTINCT F.DBRNodeID,F.DBRNodeType,DBR.Descr,1,NULL,NULL,NULL,NULL,NULL,NULL,NULL,Address1,1,NULL,1
	FROM #WorkingType C CROSS Apply dbo.[fnGetDistributorList](C.NodeID,C.NodeType,GETDATE()) F   INNER JOIN tblDBRSalesStructureDBR DBR ON DBR.NodeID=F.DBRNodeId AND DBR.NodeType=F.DBRNodetype 
	WHERE C.WorkingTypeID=2
	--UNION
	--SELECT W.NodeID,W.Nodetype,Descr,ISNULL(flgReMap,1),[Lat Code],[Long Code],MapState,MapCity,MapPinCode,PhoneNo,TaxNumber,Address,0,'',1  FROM tblWarehouseMstr W INNER JOIN [tblCompanySalesStructure_DistributorMapping] DM ON DM.DHNodeID=W.NodeID AND DM.DHNodeType=W.Nodetype INNER JOIN #WorkingType C ON C.NodeID=DM.SHNodeID AND C.NodeType=DM.SHNodeType WHERE 
	--C.WorkingTypeID=1

	----IF @WorkingTypeID=2  --- Distributor Salesman
	----BEGIN
	----	INSERT INTO #SuppList(NodeID,NodeType,Descr,flgMapped,[lat Code],[Long Code],[MapState],City,PinCode,PhoneNo,TaxNumber,Address,flgStockManage,EMailID,flgDefault)
	----	SELECT DISTINCT F.DBRNodeID,F.DBRNodeType,DBR.Descr,ISNULL(DBR.flgReMap,1),[Lat Code],[Long Code],MapState,MapCity,MapPinCode,DBR.PhoneNo,GSTNo,Address1,isnull(DBR.flgWillManageInventory,0)+1,Email,1
	----	 FROM #CoverageArea C CROSS Apply dbo.[fnGetDistributorList](C.NodeID,C.NodeType,GETDATE()) F   INNER JOIN tblDBRSalesStructureDBR DBR ON DBR.NodeID=F.DBRNodeId AND DBR.NodeType=F.DBRNodetype
	----END
	----ELSE
	----BEGIN
	----	INSERT INTO #SuppList(NodeID,NodeType,Descr,flgMapped,[lat Code],[Long Code],[MapState],City,PinCode,PhoneNo,TaxNumber,Address,flgStockManage,EMailID,flgDefault)
	----	SELECT NodeID,Nodetype,Descr,ISNULL(flgReMap,1),[Lat Code],[Long Code],MapState,MapCity,MapPinCode,PhoneNo,TaxNumber,Address,0,'',1  FROM tblWarehouseMstr
	----END
	 
	 SELECT NodeID,NodeType,Descr,ISNULL([lat Code],0.0) AS latCode,ISNULL([Long Code],0.0) AS LongCode,CASE WHEN [Lat Code] IS NOT NULL THEN 1 ELSE 0 END AS flgMapped,ISNULL(Address,'NA') Address,ISNULL(MapState,'NA') State,ISNULL(City,'NA') City,ISNULL(PinCode,0) PinCode,ISNULL(PhoneNo,'NA') PhoneNo,ISNULL(TaxNumber,'NA') TaxNumber,flgStockManage,flgDefault,ISNULL(EMailID,'NA') EMailID,'No' IsDiscountAllow,1 AS IsDiscountApplicable FROM #SuppList  
	   
END
