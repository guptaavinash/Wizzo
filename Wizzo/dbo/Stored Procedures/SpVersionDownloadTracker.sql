-- =============================================
-- Author:		Avinash Gupta
-- Create date: 05-Feb-2018
-- Description:	
-- =============================================
-- SpVersionDownloadTracker 0,0
CREATE PROCEDURE [dbo].[SpVersionDownloadTracker] 
	@SalesNodeId INT,
	@SalesNodetype SMALLINT
AS
BEGIN
	DECLARE @Date DATE
	SET @date=GETDATE()
	Declare @CmpSales [dbo].[DSRList]
;with cmpSales as
(select NodeId,NodeType from [dbo].[tblCompanySalesStructureHierarchy] where NodeId=@SalesNodeId and NodeType=@SalesNodetype and @Date between VldFrom and VldTo and HierTypeId=2
union all
select NodeId,NodeType from [dbo].[tblCompanySalesStructureHierarchy] where PNodeId=@SalesNodeId and PNodeType=@SalesNodetype and @SalesNodeId=0 and @SalesNodetype=0 and @Date between VldFrom and VldTo and HierTypeId=2
union all
select b.NodeId,b.NodeType from cmpSales A join [dbo].[tblCompanySalesStructureHierarchy] b on a.NodeId=b.pnodeid and a.NodeType=b.pNodeType  and @Date between b.VldFrom and b.VldTo and HierTypeId=2
)
insert into @CmpSales
select NodeId,NodeType  from cmpSales 

;with cmpSales as
(select NodeId,NodeType from [dbo].[tblCompanySalesStructureHierarchy] where NodeId=@SalesNodeId and NodeType=@SalesNodetype and @Date between VldFrom and VldTo and HierTypeId=5
union all
select NodeId,NodeType from [dbo].[tblCompanySalesStructureHierarchy] where PNodeId=@SalesNodeId and PNodeType=@SalesNodetype and @SalesNodeId=0 and @SalesNodetype=0 and @Date between VldFrom and VldTo and HierTypeId=5
union all
select b.NodeId,b.NodeType from cmpSales A join [dbo].[tblCompanySalesStructureHierarchy] b on a.NodeId=b.pNodeId and a.NodeType=b.pNodeType  and @Date between b.VldFrom and b.VldTo and HierTypeId=5
)
insert into @CmpSales
select NodeId,NodeType  from cmpSales

--SELECT * FROM @CmpSales

CREATE TABLE #PersonDownloadStatus (PersonNodeID INT,PersonNodetype SMALLINT,Personname VARCHAR(200),IMEINO VARCHAR(50),ApplicationID INT,Application VARCHAR(100),LastversionDownloaded VARCHAR(10),LastDownloadDate VARCHAR(30),flgStatus TINYINT Default 0)  --flgStatus=0 Defalut Not Applicable,1=Incorrect Version downloaded,2=Correct  Version Downloaded,3=Version Not Downloaded.

INSERT INTO #PersonDownloadStatus(PersonNodeID,PersonNodetype,Personname,IMEINO,ApplicationID,Application)
SELECT DISTINCT SM.PersonNodeID,SM.PersonType,MP.Descr,PU.PDACode,A.ApplicationTypeID,A.Descr FROM tblSalesPersonMapping SM INNER JOIN [dbo].tblPDACodeMapping PU ON PU.PersonID=SM.PersonNodeID INNER JOIN @CmpSales C ON C.NodeID=SM.NodeID AND C.NodeType=SM.NodeType INNER JOIN tblMstrPerson MP ON MP.NodeID=PU.PersonID  CROSS JOIN
  tbl_ApplicationTypeMstr A 	
  WHERE getdate() between SM.FromDate AND Sm.ToDate AND GETDATE() BETWEEN MP.FromDate AND MP.ToDate

  --SELECT * FROM #PersonDownloadStatus

SELECT DISTINCT V.VersionSerialNo,VL.ApplicationType,VL.PDACode IMEINo,X.LastTime INTO #lastDownloaded FROM [tblVersionDownloadStatusMstr] VL INNER JOIN [tblVersionMstr] V ON V.VersionID=VL.VersionID ,(SELECT DISTINCT ApplicationType,PDACode,MAX(VersionDownloaddate) LastTime FROM [dbo].[tblVersionDownloadStatusMstr] GROUP BY PDACode,ApplicationType)X WHERE X.ApplicationType=VL.ApplicationType AND X.PDACode=VL.PDACode AND X.LastTime=VL.VersionDownloaddate
PRINT 'A'
--SELECT * FROM #lastDownloaded ORDER BY IMEINo

  UPDATE P SET LastversionDownloaded=L.VersionSerialNo,LastDownloadDate=CONVERT(varchar,L.LastTime, 106) + '(Version-' + L.VersionSerialNo + ')' FROM #PersonDownloadStatus P INNER JOIN #lastDownloaded L ON L.ApplicationType=P.ApplicationID AND L.IMEINo=P.IMEINo
PRINT 'B'
 -- SELECT * FROM #PersonDownloadStatus oRDER by IMEINO

 --@@@@@@ For Current running version for each application
 SELECT DISTINCT VersionID,VersionSerialNo,V.ApplicationType,LastVersionCreationDate,A.Descr + '(Current-V ' + VersionSerialNo + ')' Application INTO #LastVersionCreated FROM [tblVersionMstr] V INNER JOIN tbl_ApplicationTypeMstr A ON A.ApplicationTypeID=V.ApplicationType,(SELECT ApplicationType,MAX(VersionCreationDate) LastVersionCreationDate FROM [tblVersionMstr] GROUP BY ApplicationType) X WHERE X.ApplicationType=V.ApplicationType AND X.LastVersionCreationDate=V.VersionCreationDate

 --- Adding Current version det on application name
 UPDATE P SET P.application=P.application + '(Current-V ' + VersionSerialNo + ')' FROM #PersonDownloadStatus P INNER JOIN #LastVersionCreated L ON L.ApplicationType=P.ApplicationID

 UPDATE P SET flgStatus=3 FROM #PersonDownloadStatus P INNER JOIN tblApplicationApplicabilitymstr A ON A.PersonType=P.PersonNodetype AND A.Applicationtype=P.ApplicationID INNER JOIN tblPDAMaster PDA ON (PDA.PDA_IMEI=P.IMEINO OR PDA.PDA_IMEI_Sec=P.IMEINO) LEFT OUTER JOIN [tblPDAApplicationMapping] AM ON AM.ApplicationType=A.Applicationtype AND AM.PDAID=PDA.PDAID AND GETDATE() BETWEEN AM.Fromdate AND AM.Todate WHERE AM.PDAID IS NULL

 UPDATE p SET flgStatus=1 FROM #PersonDownloadStatus P INNER JOIN #LastVersionCreated L ON L.ApplicationType=P.ApplicationID AND L.VersionSerialNo<>p.LastversionDownloaded AND P.LastversionDownloaded IS NOT NULL

 UPDATE p SET flgStatus=2 FROM #PersonDownloadStatus P INNER JOIN #LastVersionCreated L ON L.ApplicationType=P.ApplicationID AND L.VersionSerialNo=p.LastversionDownloaded AND P.LastversionDownloaded IS NOT NULL

 --SELECT * FROM #LastVersionCreated WHERE ApplicationType=3 AND VersionSerialNo='1.10'
 --SELECT * FROM #PersonDownloadStatus

 UPDATE P SET LastDownloadDate=ISNULL(LastDownloadDate + '^' + CAST(flgStatus AS VARCHAR),'^' + CAST(flgStatus AS VARCHAR)) FROM #PersonDownloadStatus P


  DECLARE @cols AS NVARCHAR(MAX),
	@query  AS NVARCHAR(MAX)

	SELECT @cols = STUFF((SELECT  ',' + QUOTENAME(Application) 
					FROM #LastVersionCreated
			FOR XML PATH(''), TYPE
			).value('.', 'NVARCHAR(MAX)') 
		,1,1,'')

	PRINT '@cols=' + @cols

	SELECT @query = 'SELECT * FROM (
						SELECT PersonNodeID,PersonNodetype,Personname,IMEINo,LastDownloadDate,application FROM #PersonDownloadStatus)X PIVOT (MAX(LastDownloadDate)	for [application] in (' + @cols + ')	) P ORDER BY PersonNodeType,Personname'
	PRINT @query
	EXEC SP_EXECUTESQL @query

END
