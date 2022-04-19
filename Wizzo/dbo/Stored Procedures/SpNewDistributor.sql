-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE SpNewDistributor 
	
AS
BEGIN
	CREATE TABLE #PotentialDistributor([Date] Date,[ASM Name] VARCHAR(200),[City Name] VARCHAR(100),DealerFirmName VARCHAR(200),[Contact Person Name] VARCHAR(200),[Contact Number] BIGINT,REMARKS VARCHAR(500))

	INSERT INTO #PotentialDistributor([Date],[ASM Name],[City Name],DealerFirmName,[Contact Person Name] ,[Contact Number] ,REMARKS)
	SELECT DISTINCT  CreatedDate,PM.Descr,P.City,P.Descr,P.[Contact Person Name],P.[Contact Person Mobile Number],'' FROM tblPotentialDistributor P INNER JOIN tblMstrPerson PM ON PM.NodeID=P.EntryPersonNodeID AND PM.NodeType=P.EntryPersonNodeType

	SELECT FORMAT([Date],'dd-MMM-yy') Date,[ASM Name],[City Name],DealerFirmName,[Contact Person Name] ,[Contact Number] ,REMARKS FROM #PotentialDistributor
END
