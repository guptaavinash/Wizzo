-- =============================================              
-- Author:  Avinash Gupta              
-- Create date: 27Mar2017              
-- Description:               
-- =============================================              

-- [SpGetDistributorTodaysStock] 1,150 ,'354010084603910'             
CREATE PROCEDURE [dbo].[SpGetDistributorTodaysStock]               
 @CustomerNodeID INT,              
 @CustomerNodeType SMALLINT,
 @PDACode varchar(100)               

AS              
BEGIN           
	 DECLARE @CurrentDateMonthYear DATE              
	 DECLARE @Count INT              
	 DECLARE @MaxCount INT           
	 DECLARE @SQL VARCHAR(1000)      
	 DECLARE @ColumnDate VARCHAR(1000)              
	-- DECLARE @DeviceID INT
	 DECLARE @PersonID INT     
	 DECLARE @PersonType INT    
	 DECLARE @ChannelId INT=0

	-- SELECT @DeviceID = PDAID FROM tblPDAMaster WHERE PDA_IMEI = @IMEINO OR PDA_IMEI_Sec=@IMEINO
	-- PRINT '@DeviceID=' + CAST(ISNULL(@DeviceID,0) AS VARCHAR)

	 --SELECT @PersonID=PersonID, @PersonType=[PersonType] FROM [dbo].[tblPDA_UserMapMaster] WHERE PDAID=@DeviceID  AND (GETDATE() BETWEEN DateFrom AND DateTo)
	 SELECT @PersonID=NodeID,@PersonType=NodeType FROM dbo.fnGetPersonIDfromPDACode(@PDACode) U INNER JOIN tblMstrPerson P ON P.NodeID=U.PersonID


	 PRINT 'PersonID=' + CAST(@PersonID AS VARCHAR)          
	 PRINT 'PersonType=' + CAST(@PersonType AS VARCHAR)

	---- SELECT P.NodeID,P.NodeType INTO #CoverageArea 
	---- FROM tblSalesPersonMapping P INNER JOIN tblPDA_UserMapMaster M ON M.PersonID=P.PersonNodeID AND M.PersonType=P.PersonType 
	---- INNER JOIN [tblSecMenuContextMenu] C ON C.NodeType=P.NodeType 
	---- INNER JOIN tblPDAMaster PDA ON PDA.PDAID=M.PDAID
	---- WHERE ISNULL(C.flgCoverageArea,0)=1 AND M.PDAID = @DeviceID AND (CONVERT(VARCHAR, M.DateFrom, 112) <= CONVERT(VARCHAR, GETDATE(), 112)) 
	----AND (CONVERT(VARCHAR, ISNULL(M.DateTo, GETDATE()), 112) >= CONVERT(VARCHAR, GETDATE(), 112)) AND (GETDATE() BETWEEN P.FromDate AND ISNULL(P.ToDate,GETDATE()))

	---- SELECT @ChannelId=A.ChannelID
	---- from tblSalesHierChannelMapping A INNER JOIN #CoverageArea B ON A.SalesStructureNodID=B.NodeId AND A.SalesStructureNodType=B.NodeType
	---- WHERE (GETDATE() BETWEEN A.FromDate AND ISNULL(A.ToDate,GETDATE()))
	---- PRINT 'ChannelId=' + CAST(@ChannelId AS VARCHAR)   
	 
	 ----IF ISNULL(@ChannelId,0)=0
		----SET @ChannelId=1

	 SET @SQL=''              
	 SET @Count=0             
	 SET @MaxCount=12         
	 SET @CurrentDateMonthYear=CAST(GETDATE() AS DATE)              

	CREATE TABLE #tblDayReport(ProductNodeID INT,ProductNodeType SMALLINT,SKUName VARCHAR(500),FlvShortName VARCHAR(200),StockDate varchar(11))              
	CREATE TABLE #tblMonthColumns(DistDayReportCoumnName VARCHAR(30),DistDayReportColumnDisplayName Varchar(200))              

	Insert into #tblMonthColumns(DistDayReportCoumnName,DistDayReportColumnDisplayName) VALUES('ProductNodeID','ProductNodeID')            
    Insert into #tblMonthColumns(DistDayReportCoumnName,DistDayReportColumnDisplayName) VALUES('ProductNodeType','ProductNodeType')        
    Insert into #tblMonthColumns(DistDayReportCoumnName,DistDayReportColumnDisplayName) VALUES('SKUName','SKUName')            
    Insert into #tblMonthColumns(DistDayReportCoumnName,DistDayReportColumnDisplayName) VALUES('FlvShortName','FlvShortName') 
    Insert into #tblMonthColumns(DistDayReportCoumnName,DistDayReportColumnDisplayName) VALUES('StockDate','StockDate')            

	INSERT INTO #tblDayReport(ProductNodeID,ProductNodeType,SKUName,FlvShortName,StockDate)              
	SELECT V.SKUNodeID,V.SKUNodeType,V.Category,V.SKUShortDescr,REPLACE(CONVERT(CHAR(11), GETDATE(), 106),' ','-') AS StockDate
	 FROM [VwSFAProductHierarchy] V
	----FROM [VwSFAProductHierarchy] V INNER JOIN tblPrdSKUSalesMapping B ON V.SKUNodeID=B.SKUNodeID AND V.SKUNodeType=B.SKUNodeType
	----WHERE B.BusinessSegmentId=@ChannelId AND (CONVERT(DATE,GETDATE()) BETWEEN FromDate AND ToDate)
	ORDER BY SKU   

	WHILE @Count<@MaxCount              
	BEGIN              
		SET @SQL='ALTER TABLE #tblDayReport ADD [' + 'LastMonth'+CAST((@Count+1) AS VARCHAR(2)) + '] VARCHAR'              
		EXEC (@SQL)                                          

		SET @SQL='UPDATE R SET StockDate=S.StockDate,[' + 'LastMonth'+CAST((@Count+1) AS VARCHAR(2)) + ']=S.StockQty FROM #tblDayReport R INNER JOIN [dbo].[tblDistributorStockDet] S ON S.ProductNodeID=R.ProductNodeID AND S.ProductNodeType=R.ProductNodeType              
		WHERE CustomerNodeID=' + CAST(@CustomerNodeID AS VARCHAR) + ' AND CustomerNodeType=' + CAST(@CustomerNodeType AS VARCHAR) + ' AND S.StockDate=CAST(GETDATE() AS DATE)'			
		PRINT (@SQL)
		EXEC(@SQL)    

		SET @ColumnDate= SUBSTRING(datename(month, dateadd(month,@MAxCount-(@MAxCount + @Count),@CurrentDateMonthYear)),0,4) +  '-' + SUBSTRING(CAST(YEAR(dateadd(month,@MAxCount-(@MAxCount + @Count),@CurrentDateMonthYear)) AS VARCHAR),3,4)             

		INSERT INTO #tblMonthColumns(DistDayReportCoumnName,DistDayReportColumnDisplayName) 
		VALUES('LastMonth'+CAST((@Count+1) AS VARCHAR(2)),@ColumnDate)            

		SET @Count=@Count +1              
	END       

	SELECT * FROM #tblDayReport             

	SELECT * FROM #tblMonthColumns   

	SELECT  REPLACE(CONVERT(CHAR(11), GETDATE(), 106),' ','-') AS StockDate   
	
	SELECT BUOMID,BUOMName,CASE BUOMName WHEN 'Pieces' THEN 1 ELSE 0 END flgRetailUnit FROM tblPrdMstrBUOMMaster
	SELECT SKUID NodeID,NodeType,BaseUOMID,PackUOMID,RelConversionUnits,flgVanLoading FROM [dbo].[tblPrdMstrPackingUnits_ConversionUnits] 
	SELECT prdID NodeID,20 NodeType,UOMID BUOMID,flgDistOrder,flgDistInv,flgStoreCheck,flgRetailUnit,flgTransactionData,flgDistributorCheck FROM tblPrdMstrTransactionUOMConfig

	

END 

