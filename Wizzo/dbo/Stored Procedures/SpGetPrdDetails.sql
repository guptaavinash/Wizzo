-- =============================================  
-- Author:  Avinash Gupta  
-- Create date: 10-Apr-2015  
-- Description: Sp to get the product details and channel mappings  
-- =============================================  
-- [SpGetPrdDetails] 6,10
CREATE PROCEDURE [dbo].[SpGetPrdDetails] --1,2  
 @NodeID INT,  
 @NodeType INT,  
 @HierID INT=0  
AS  
BEGIN  
 DECLARE @tblHier VARCHAR(50)  
 DECLARE @tblDesc VARCHAR(50)  
 DECLARE @FrameID INT  
 DECLARE @HierTypeID INT  
 DECLARE @strSQL VARCHAR(4000)  
  DECLARE @StrLevels VARCHAR(2000)  
  
 IF @NodeID>0  
 BEGIN  
   
  
  EXEC spUTLGetSQLTblSource @NodeType,  @tblHier OUTPUT, @tblDesc OUTPUT, @FrameID OUTPUT, @HierTypeID OUTPUT  
     
    
  SET @strSQL='SELECT Descr FROM ' +  @tblDesc + ' WHERE NodeId=' +  CAST(@NodeID AS varChar(6))  
  print @strSQL  
  EXEC (@strSQL)  
  
  SET @strSQL='SELECT DISTINCT tblProdChannelMapping.ChannelID,tblOutletChannelmaster.ChannelName ChannelName,CONVERT(VARCHAR(11),FromDate,106) AS FromDate FROM tblProdChannelMapping INNER JOIN ' + @tblDesc + ' ON ' + @tblDesc + '.NodeID=tblProdChannelMapping.ProductNodeID  
  AND tblProdChannelMapping.ProductNodeType=' + @tblDesc + '.NodeType  
  INNER JOIN tblOutletChannelmaster ON tblOutletChannelmaster.ChannelName=tblProdChannelMapping.ChannelID WHERE tblProdChannelMapping.ProductNodeID=' + CAST(@NodeID AS VARCHAR)  
  print @strSQL  
  EXEC (@strSQL)  
  --IF @NodeType=3  
  --BEGIN  
  
  --select * from tblPrdMstrHierLvl3
  
  
  -- SELECT NodeID,PrdCode,Descr,ShortDescr,UOMID,MRP,IsCombiPack,Tax,tblPrdMstrBUOMMaster.BUOMName,
  -- IsActive FROM tblPrdMstrHierLvl3  
  -- LEFT OUTER JOIN tblPrdMstrBUOMMaster ON tblPrdMstrHierLvl3.UOMID = tblPrdMstrBUOMMaster.BUOMID  
  --  WHERE NodeID=@NodeID AND NodeType=@NodeType  
  
  -- SELECT [SqNo],[BaseUOMID],tblPrdMstrBUOMMaster.BUOMName,[PackUOMID],CAST([RelConversionUnits] AS DECIMAL(18,2)) AS [RelConversionUnits] , flgRetailUnit ,flgDistInvoice,  
  -- Packing.BUOMName PackName  
  -- FROM tblPrdMstrPackingUnits_ConversionUnits   
  -- INNER JOIN tblPrdMstrBUOMMaster ON tblPrdMstrPackingUnits_ConversionUnits.[BaseUOMID] = tblPrdMstrBUOMMaster.BUOMID  
  -- INNER JOIN tblPrdMstrBUOMMaster Packing  ON tblPrdMstrPackingUnits_ConversionUnits.PackUOMID=Packing.BUOMID  
  -- WHERE SKUID=@NodeID AND NodeType=@NodeType Order By [SqNo]  
  
  -- SELECT SqNo,[PackUnitID],[RptngUnitID],CAST([ConversionFactor] AS DECIMAL(18,2)) AS [ConversionFactor] ,tblPrdMstrBUOMMaster.BUOMName RptngBUOM,Packing.BUOMName PackBUOMName  
  -- FROM tblPrdMstrRptngUnits_ConversionUnits   
  -- INNER JOIN tblPrdMstrBUOMMaster ON tblPrdMstrRptngUnits_ConversionUnits.RptngUnitID = tblPrdMstrBUOMMaster.BUOMID  
  -- INNER JOIN tblPrdMstrBUOMMaster Packing  ON tblPrdMstrRptngUnits_ConversionUnits.[PackUnitID]=Packing.BUOMID  
  -- WHERE SKUID=@NodeID AND NodeType=@NodeType  
  
    
  --END  
  IF @NodeType=30  
  BEGIN  
	PRINT 'A'
   SELECT S.NodeID,S.SKUCode,S.Descr,ShortDescr,UOMID,S.BrandID,0 AS ManufacturerID,[tblPrdBrandMstr].Descr Brand,'' ManufacturerName,
   MRP,CostToRetailer,WholeSalePrice,IsCombiPack,Tax,tblPrdMstrBUOMMaster.BUOMName,
   RetMarginPer,S.IsActive FROM tblPrdMstrSKULvl S  
   LEFT OUTER JOIN tblPrdMstrBUOMMaster ON S.UOMID = tblPrdMstrBUOMMaster.BUOMID  
    LEFT OUTER JOIN [dbo].[tblPrdBrandMstr] ON S.BrandID = [tblPrdBrandMstr].NodeID 
	 --LEFT OUTER JOIN [dbo].[tblManufacturerMstrMain] M ON S.ManufacturerID = M.ManufacturerID 
	-- LEFT OUTER JOIN tblPrdColourMstr C ON C.NodeID=S.ColourID
	-- LEFT OUTER JOIN tblPrdSizeMstr PS ON PS.NodeID=S.SizeID
    WHERE S.NodeID=@NodeID AND S.NodeType=@NodeType  
  
   SELECT [SqNo],[BaseUOMID],tblPrdMstrBUOMMaster.BUOMName,[PackUOMID],CAST([RelConversionUnits] AS DECIMAL(18,2)) AS [RelConversionUnits] , flgRetailUnit ,flgDistInvoice,  
   Packing.BUOMName PackName  
   FROM tblPrdMstrPackingUnits_ConversionUnits   
   INNER JOIN tblPrdMstrBUOMMaster ON tblPrdMstrPackingUnits_ConversionUnits.[BaseUOMID] = tblPrdMstrBUOMMaster.BUOMID  
   INNER JOIN tblPrdMstrBUOMMaster Packing  ON tblPrdMstrPackingUnits_ConversionUnits.PackUOMID=Packing.BUOMID  
     
    
   WHERE SKUID=@NodeID AND NodeType=@NodeType Order By [SqNo]  
   PRINT 'B' 
   SELECT SqNo,[PackUnitID],[RptngUnitID],CAST([ConversionFactor] AS DECIMAL(18,2)) AS [ConversionFactor] ,tblPrdMstrBUOMMaster.BUOMName RptngBUOM,Packing.BUOMName PackBUOMName  
   FROM tblPrdMstrRptngUnits_ConversionUnits   
   INNER JOIN tblPrdMstrBUOMMaster ON tblPrdMstrRptngUnits_ConversionUnits.RptngUnitID = tblPrdMstrBUOMMaster.BUOMID  
   INNER JOIN tblPrdMstrBUOMMaster Packing  ON tblPrdMstrRptngUnits_ConversionUnits.[PackUnitID]=Packing.BUOMID  
  
   WHERE SKUID=@NodeID AND NodeType=@NodeType  
  PRINT 'C'
   SELECT SKUID,ParentSKUID,QtyInParent,flgFree,[Description], tblPrdMstrSKULvl.Descr AS ComboName  FROM tblPrdComposedMapping   
   INNER JOIN tblPrdMstrSKULvl ON tblPrdMstrSKULvl.NodeID = tblPrdComposedMapping.SKUID  
   WHERE ParentSKUID=@NodeID  
  END  
 END  
 ELSE  
 BEGIN  
  SELECT NodeID,SKUCode,Descr,ShortDescr,UOMID,BrandID,0 AS ManufacturerID,MRP,CostToRetailer,IsCombiPack,tblPrdMstrBUOMMaster.BUOMName,RetMarginPer,IsActive
   FROM tblPrdMstrSKULvl  
  LEFT OUTER  JOIN tblPrdMstrBUOMMaster ON tblPrdMstrSKULvl.UOMID = tblPrdMstrBUOMMaster.BUOMID  
 END  
  PRINT 'D'
---- Add By Jyoti  
  ;WITH CTE AS   
  (   
  --initialization   
  SELECT NodeID, NodeType, PHierID    
  FROM tblPrdMstrHierarchy    
  WHERE NodeID= @NodeID AND NodeType=@NodeType AND HierID=@HierID  
  UNION ALL   
  --recursive execution   
  SELECT C.NodeID, C.NodeType, C.PHierID   
  FROM tblPrdMstrHierarchy C INNER JOIN CTE O  
  ON C.HierID = O.PHierID   
  )   
  
  SELECT * INTO #cte FROM CTE  
  
  --SELECT * FROM #cte  
  
  ALTER TABLE #cte ADD [Desc] VARCHAR(500)  
    
    
 ---------------End--------------------------  
  
  
 ---- Add By Jyoti  
  SET @strSQL='UPDATE #cte SET [Desc]=T.Descr FROM #cte INNER JOIN tblPrdMstrHierLvl1 T ON T.NodeID=#cte.NodeID AND T.NodeType=#cte.NodeType AND #cte.NodeType=10'  
  PRINT (@strSQL)  
  EXEC (@strSQL)    
  SET @strSQL='UPDATE #cte SET [Desc]=T.Descr FROM #cte INNER JOIN tblPrdMstrHierLvl2 T ON T.NodeID=#cte.NodeID AND T.NodeType=#cte.NodeType AND #cte.NodeType=20'  
  PRINT (@strSQL)  
  EXEC (@strSQL)  
  ----SET @strSQL='UPDATE #cte SET [Desc]=T.Descr FROM #cte INNER JOIN tblPrdMstrHierLvl3 T ON T.NodeID=#cte.NodeID AND T.NodeType=#cte.NodeType AND #cte.NodeType=30'  
  ----PRINT (@strSQL)  
  ----EXEC (@strSQL)  
  SET @strSQL='UPDATE #cte SET [Desc]=T.Descr FROM #cte INNER JOIN tblPrdMstrSKULvl T ON T.NodeID=#cte.NodeID AND T.NodeType=#cte.NodeType AND #cte.NodeType=30'  
  PRINT (@strSQL)  
  EXEC (@strSQL)  
    
    
  --SELECT * FROM #cte   
  SELECT @StrLevels=COALESCE(@StrLevels + '/' ,'') + [Desc] FROM #cte ORDER BY NodeType  
  
  SELECT ISNULL(@StrLevels,'')  
    
     
  ---------------End-------------------------  
END  
  
  
--select * from tblPrdMstrSKULvl  
  
