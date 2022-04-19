
-- =============================================

-- Author:		<Author,,Name>

-- Create date: <Create Date,,>

-- Description:	<Description,,>

-- =============================================


--[spGetManagerDetails]'DC496318-5691-4888-9F21-68BF24F34133'

CREATE PROCEDURE [dbo].[spGetManagerDetails]

	@PDACode VARCHAR(50) 

AS

BEGIN

	DECLARE @PDAID INT

	DECLARE @PersonID INT  

	DECLARE @PersonType INT



	CREATE TABLE #tmpPersonDet(PersonID INT,PersonType INT,PersonName VARCHAR(200),ManagerID INT,ManagerType INT,ManagerName VARCHAR(200))



	--SELECT @PDAID=PDAID FROM [dbo].[tblPDAMaster] WHERE [PDA_IMEI]=@IMEINo OR [PDA_IMEI_Sec]=@IMEINo  

	--PRINT '@PDAID=' + CAST(@PDAID AS VARCHAR)

	--IF @PDAID>0  

	--BEGIN  
		SELECT @PersonID=NodeID,@PersonType=NodeType FROM dbo.fnGetPersonIDfromPDACode(@PDACode) U INNER JOIN tblMstrPerson P ON P.NodeID=U.PersonID
	-- END   

	 SELECT ZnNodeId ZoneID,ZnNodeType ZoneType,Zone,0 AS RSMId,0 AS RSMType,CAST('' AS VARCHAR(200)) AS RSM,0 AS ZHType,CAST('' AS VARCHAR(200)) AS ZH,ASMAreaNodeID ASMAreaID,ASMAreaNodeType ASMAreaType,ASMArea,0 AS ASMId,0 AS ASMType,CAST('' AS VARCHAR(200)) AS ASM,SOAreaNodeId AS SOAreaID,SOAreaNodeType SOAreaType,SOArea,0 AS SOId,0 AS SOType,CAST('' AS VARCHAR(200)) AS SO,0 ComCoverageAreaID,0 ComCoverageAreaType,'' ComCoverageArea,0 AS CSRID,0 AS CSRType,CAST('' AS VARCHAR(200)) AS CSR INTO #PersonDetails
	FROM VwSalesHierarchy



	--RSM Name Update

	UPDATE A SET A.RSM=ISNULL(AA.Descr,'Vacant'),A.RSMId=ISNULL(AA.PersonId,0),A.RSMType=ISNULL(AA.PersonType,0)  FROM #PersonDetails A LEFT JOIN

	(SELECT B.NodeId,B.NodeType,C.Descr,C.NodeID AS PersonId,C.NodeType AS PersonType FROM tblsalesPersonMapping B INNER JOIN tblMstrPerson C ON B.PersonNodeID=C.NodeID AND B.PersonType=C.NodeType WHERE (GETDATE() BETWEEN B.FromDate AND B.ToDate) AND (GETDATE() BETWEEN C.FromDate AND C.ToDate) AND B.NodeType=95) AA

	ON A.ZoneID=AA.NodeId AND A.ZoneType=AA.NodeType

	--ZH Name Update

	--UPDATE A SET A.ZH=ISNULL(AA.Descr,'Vacant'),A.ZHId=ISNULL(AA.PersonId,0),A.ZHType=ISNULL(AA.PersonType,0)  FROM #PersonDetails A LEFT JOIN

	--(SELECT B.NodeId,B.NodeType,C.Descr,C.NodeID AS PersonId,C.NodeType AS PersonType FROM tblsalesPersonMapping B INNER JOIN tblMstrPerson C ON B.PersonNodeID=C.NodeID AND B.PersonType=C.NodeType WHERE (GETDATE() BETWEEN B.FromDate AND B.ToDate) AND (GETDATE() BETWEEN C.FromDate AND C.ToDate) AND B.NodeType=100) AA

	--ON A.ZoneID=AA.NodeId AND A.ZoneType=AA.NodeType

	--ASM Name Update

	UPDATE A SET A.ASM=ISNULL(AA.Descr,'Vacant'),A.ASMId=ISNULL(AA.PersonId,0),A.ASMType=ISNULL(AA.PersonType,0)  FROM #PersonDetails A LEFT JOIN

	(SELECT B.NodeId,B.NodeType,C.Descr,C.NodeID AS PersonId,C.NodeType AS PersonType FROM tblsalesPersonMapping B INNER JOIN tblMstrPerson C ON B.PersonNodeID=C.NodeID AND B.PersonType=C.NodeType WHERE (GETDATE() BETWEEN B.FromDate AND B.ToDate) AND (GETDATE() BETWEEN C.FromDate AND C.ToDate) AND B.NodeType=110) AA

	ON A.ASMAreaID=AA.NodeId AND A.ASMAreaType=AA.NodeType

	--SO Name Update

	UPDATE A SET A.SO=ISNULL(AA.Descr,'Vacant') ,A.SOId=ISNULL(AA.PersonId,0),A.SOType=ISNULL(AA.PersonType,0)  FROM #PersonDetails A LEFT JOIN

	(SELECT B.NodeId,B.NodeType,C.Descr,C.NodeID AS PersonId,C.NodeType AS PersonType FROM tblsalesPersonMapping B INNER JOIN tblMstrPerson C ON B.PersonNodeID=C.NodeID AND B.PersonType=C.NodeType WHERE (GETDATE() BETWEEN B.FromDate AND B.ToDate) AND (GETDATE() BETWEEN C.FromDate AND C.ToDate) AND B.NodeType=120) AA

	ON A.SOAreaID=AA.NodeId AND A.SOAreaType=AA.NodeType

	--CSR Name Update

	UPDATE A SET A.CSR=ISNULL(AA.Descr,'Vacant') ,A.CSRId=ISNULL(AA.PersonId,0),A.CSRType=ISNULL(AA.PersonType,0)  FROM #PersonDetails A LEFT JOIN

	(SELECT B.NodeId,B.NodeType,C.Descr,C.NodeID AS PersonId,C.NodeType AS PersonType FROM tblsalesPersonMapping B INNER JOIN tblMstrPerson C ON B.PersonNodeID=C.NodeID AND B.PersonType=C.NodeType WHERE (GETDATE() BETWEEN B.FromDate AND B.ToDate) AND (GETDATE() BETWEEN C.FromDate AND C.ToDate) AND B.NodeType=130) AA

	ON A.ComCoverageAreaID=AA.NodeId AND A.ComCoverageAreaType=AA.NodeType



	--SELECT * FROM #PersonDetails



	INSERT INTO #tmpPersonDet(PersonID,PersonType,PersonName,ManagerID,ManagerType,ManagerName)

	SELECT DISTINCT @PersonID AS PersonNodeId,@PersonType AS PersonNodeType,Descr AS PersonName,0,0,'Self Working'

	FROM tblMstrPerson

	WHERE NodeID=@PersonID AND NodeType=@PersonType



	 DECLARE @ManagingAreaNodeId INT

	 DECLARE @ManagingAreaNodeType INT



	 IF @PersonType=240 --DSR

	 BEGIN

		SELECT @ManagingAreaNodeId=Map.SHNodeID,@ManagingAreaNodeType=Map.SHNodeType

		FROM tblSalesPersonMapping SP INNER JOIN tblCompanySalesStructure_DistributorMapping Map ON SP.NodeId=Map.DHNodeId AND Sp.NodeType=Map.DHNodeType

		WHERE SP.PersonNodeID=@PersonID AND PersonType=@PersonType AND SP.NodeType=160 AND (GETDATE() BETWEEN SP.FromDate AND SP.ToDate)

		--SELECT @ManagingAreaNodeId

		--SELECT @ManagingAreaNodeType		



		IF @ManagingAreaNodeType=130 --Company Salesman Area

		BEGIN

			INSERT INTO #tmpPersonDet(PersonID,PersonType,PersonName,ManagerID,ManagerType,ManagerName)

			SELECT DISTINCT @PersonID,@PersonType,B.Descr AS PersonName,A.CSRID,A.CSRType,A.CSR

			FROM #PersonDetails A,tblMstrPerson B

			WHERE B.NodeID=@PersonID AND B.NodeType=@PersonType AND A.ComCoverageAreaID=@ManagingAreaNodeId AND A.ComCoverageAreaType=@ManagingAreaNodeType AND A.CSRID<>0 AND A.CSR<>'Vacant'

			UNION

			SELECT DISTINCT @PersonID,@PersonType,B.Descr AS PersonName,A.SOId,A.SOType,A.SO

			FROM #PersonDetails A,tblMstrPerson B

			WHERE B.NodeID=@PersonID AND B.NodeType=@PersonType AND A.ComCoverageAreaID=@ManagingAreaNodeId AND A.ComCoverageAreaType=@ManagingAreaNodeType AND A.SOId<>0 AND A.SO<>'Vacant'

			UNION

			SELECT DISTINCT @PersonID,@PersonType,B.Descr AS PersonName,A.ASMId,A.ASMType,A.ASM

			FROM #PersonDetails A,tblMstrPerson B

			WHERE B.NodeID=@PersonID AND B.NodeType=@PersonType AND A.ComCoverageAreaID=@ManagingAreaNodeId AND A.ComCoverageAreaType=@ManagingAreaNodeType AND A.ASMId<>0 AND A.ASM<>'Vacant'

			UNION

			--SELECT DISTINCT @PersonID,@PersonType,B.Descr AS PersonName,A.ZHId,A.ZHType,A.ZH

			--FROM #PersonDetails A,tblMstrPerson B

			--WHERE B.NodeID=@PersonID AND B.NodeType=@PersonType AND A.ComCoverageAreaID=@ManagingAreaNodeId AND A.ComCoverageAreaType=@ManagingAreaNodeType AND A.ZHId<>0 AND A.ZH<>'Vacant'

			--UNION

			SELECT DISTINCT @PersonID,@PersonType,B.Descr AS PersonName,A.RSMId,A.RSMType,A.RSM

			FROM #PersonDetails A,tblMstrPerson B

			WHERE B.NodeID=@PersonID AND B.NodeType=@PersonType AND A.ComCoverageAreaID=@ManagingAreaNodeId AND A.ComCoverageAreaType=@ManagingAreaNodeType AND A.RSMId<>0 AND A.RSM<>'Vacant'

		END

		ELSE IF @ManagingAreaNodeType=120 --SO Area

		BEGIN

			INSERT INTO #tmpPersonDet(PersonID,PersonType,PersonName,ManagerID,ManagerType,ManagerName)

			SELECT DISTINCT @PersonID,@PersonType,B.Descr AS PersonName,A.SOId,A.SOType,A.SO

			FROM #PersonDetails A,tblMstrPerson B

			WHERE B.NodeID=@PersonID AND B.NodeType=@PersonType AND A.SOAreaID=@ManagingAreaNodeId AND A.SOAreaType=@ManagingAreaNodeType AND A.SOId<>0 AND A.SO<>'Vacant'

			UNION

			SELECT DISTINCT @PersonID,@PersonType,B.Descr AS PersonName,A.ASMId,A.ASMType,A.ASM

			FROM #PersonDetails A,tblMstrPerson B

			WHERE B.NodeID=@PersonID AND B.NodeType=@PersonType AND A.SOAreaID=@ManagingAreaNodeId AND A.SOAreaType=@ManagingAreaNodeType AND A.ASMId<>0 AND A.ASM<>'Vacant'

			UNION

			--SELECT DISTINCT @PersonID,@PersonType,B.Descr AS PersonName,A.ZHId,A.ZHType,A.ZH

			--FROM #PersonDetails A,tblMstrPerson B

			--WHERE B.NodeID=@PersonID AND B.NodeType=@PersonType AND A.SOAreaID=@ManagingAreaNodeId AND A.SOAreaType=@ManagingAreaNodeType AND A.ZHId<>0 AND A.ZH<>'Vacant'

			--UNION

			SELECT DISTINCT @PersonID,@PersonType,B.Descr AS PersonName,A.RSMId,A.RSMType,A.RSM

			FROM #PersonDetails A,tblMstrPerson B

			WHERE B.NodeID=@PersonID AND B.NodeType=@PersonType AND A.SOAreaID=@ManagingAreaNodeId AND A.SOAreaType=@ManagingAreaNodeType AND A.RSMId<>0 AND A.RSM<>'Vacant'

		END

		ELSE IF @ManagingAreaNodeType=110 --ASM Area

		BEGIN

			INSERT INTO #tmpPersonDet(PersonID,PersonType,PersonName,ManagerID,ManagerType,ManagerName)

			SELECT DISTINCT @PersonID,@PersonType,B.Descr AS PersonName,A.ASMId,A.ASMType,A.ASM

			FROM #PersonDetails A,tblMstrPerson B

			WHERE B.NodeID=@PersonID AND B.NodeType=@PersonType AND A.ASMAreaID=@ManagingAreaNodeId AND A.ASMAreaType=@ManagingAreaNodeType AND A.ASMId<>0 AND A.ASM<>'Vacant'

			UNION

			--SELECT DISTINCT @PersonID,@PersonType,B.Descr AS PersonName,A.ZHId,A.ZHType,A.ZH

			--FROM #PersonDetails A,tblMstrPerson B

			--WHERE B.NodeID=@PersonID AND B.NodeType=@PersonType AND A.ASMAreaID=@ManagingAreaNodeId AND A.ASMAreaType=@ManagingAreaNodeType AND A.ZHId<>0 AND A.ZH<>'Vacant'

			--UNION

			SELECT DISTINCT @PersonID,@PersonType,B.Descr AS PersonName,A.RSMId,A.RSMType,A.RSM

			FROM #PersonDetails A,tblMstrPerson B

			WHERE B.NodeID=@PersonID AND B.NodeType=@PersonType AND A.ASMAreaID=@ManagingAreaNodeId AND A.ASMAreaType=@ManagingAreaNodeType AND A.RSMId<>0 AND A.RSM<>'Vacant'

		END

		----ELSE IF @ManagingAreaNodeType=100 --Zone

		----BEGIN

		----	INSERT INTO #tmpPersonDet(PersonID,PersonType,PersonName,ManagerID,ManagerType,ManagerName)

		----	SELECT DISTINCT @PersonID,@PersonType,B.Descr AS PersonName,A.ZHId,A.ZHType,A.ZH

		----	FROM #PersonDetails A,tblMstrPerson B

		----	WHERE B.NodeID=@PersonID AND B.NodeType=@PersonType AND A.ZoneId=@ManagingAreaNodeId AND A.ZoneType=@ManagingAreaNodeType AND A.ZHId<>0 AND A.ZH<>'Vacant'

		----	UNION

		----	SELECT DISTINCT @PersonID,@PersonType,B.Descr AS PersonName,A.RSMId,A.RSMType,A.RSM

		----	FROM #PersonDetails A,tblMstrPerson B

		----	WHERE B.NodeID=@PersonID AND B.NodeType=@PersonType AND A.ZoneId=@ManagingAreaNodeId AND A.ZoneType=@ManagingAreaNodeType AND A.RSMId<>0 AND A.RSM<>'Vacant'

		----END

		ELSE IF @ManagingAreaNodeType=100 --RSM Area

		BEGIN

			INSERT INTO #tmpPersonDet(PersonID,PersonType,PersonName,ManagerID,ManagerType,ManagerName)

			SELECT DISTINCT @PersonID,@PersonType,B.Descr AS PersonName,A.RSMId,A.RSMType,A.RSM

			FROM #PersonDetails A,tblMstrPerson B

			WHERE B.NodeID=@PersonID AND B.NodeType=@PersonType AND A.ZoneID=@ManagingAreaNodeId AND A.ZoneType=@ManagingAreaNodeType AND A.RSMId<>0 AND A.RSM<>'Vacant'

		END

	 END

	 ELSE IF @PersonType=230 --CSR

	 BEGIN

		INSERT INTO #tmpPersonDet(PersonID,PersonType,PersonName,ManagerID,ManagerType,ManagerName)

		SELECT DISTINCT @PersonID,@PersonType,A.CSR AS PersonName,A.SOId,A.SOType,A.SO

		FROM #PersonDetails A

		WHERE A.CSRID=@PersonID AND A.CSRType=@PersonType AND A.SOId<>0 AND A.SO<>'Vacant'

		UNION

		SELECT DISTINCT @PersonID,@PersonType,A.CSR AS PersonName,A.ASMId,A.ASMType,A.ASM

		FROM #PersonDetails A

		WHERE A.CSRID=@PersonID AND A.CSRType=@PersonType AND A.ASMId<>0 AND A.ASM<>'Vacant'

		--UNION

		--SELECT DISTINCT @PersonID,@PersonType,A.CSR AS PersonName,A.ZHId,A.ZHType,A.ZH

		--FROM #PersonDetails A

		--WHERE A.CSRID=@PersonID AND A.CSRType=@PersonType AND A.ZHId<>0 AND A.ZH<>'Vacant'

		UNION

		SELECT DISTINCT @PersonID,@PersonType,A.CSR AS PersonName,A.RSMId,A.RSMType,A.RSM

		FROM #PersonDetails A

		WHERE A.CSRID=@PersonID AND A.CSRType=@PersonType AND A.RSMId<>0 AND A.RSM<>'Vacant'

	 END

	 ELSE IF @PersonType=220 --SO

	 BEGIN

		INSERT INTO #tmpPersonDet(PersonID,PersonType,PersonName,ManagerID,ManagerType,ManagerName)

		SELECT DISTINCT @PersonID,@PersonType,A.SO AS PersonName,A.ASMId,A.ASMType,A.ASM

		FROM #PersonDetails A

		WHERE A.SOId=@PersonID AND A.SOType=@PersonType AND A.ASMId<>0 AND A.ASM<>'Vacant'

		----UNION

		----SELECT DISTINCT @PersonID,@PersonType,A.SO AS PersonName,A.ZHId,A.ZHType,A.ZH

		----FROM #PersonDetails A

		----WHERE A.SOId=@PersonID AND A.SOType=@PersonType AND A.ZHId<>0 AND A.ZH<>'Vacant'

		UNION

		SELECT DISTINCT @PersonID,@PersonType,A.SO AS PersonName,A.RSMId,A.RSMType,A.RSM

		FROM #PersonDetails A

		WHERE A.SOId=@PersonID AND A.SOType=@PersonType AND A.RSMId<>0 AND A.RSM<>'Vacant'

	 END

	 ELSE IF @PersonType=210 --ASM

	 BEGIN

		INSERT INTO #tmpPersonDet(PersonID,PersonType,PersonName,ManagerID,ManagerType,ManagerName)
				
		SELECT DISTINCT @PersonID,@PersonType,A.ASM AS PersonName,A.RSMId,A.RSMType,A.RSM

		FROM #PersonDetails A

		WHERE A.ASMId=@PersonID AND A.ASMType=@PersonType AND A.RSMId<>0 AND A.RSM<>'Vacant'

	 END

	 ----ELSE IF @PersonType=205 --ZH

	 ----BEGIN

		----INSERT INTO #tmpPersonDet(PersonID,PersonType,PersonName,ManagerID,ManagerType,ManagerName)

		----SELECT DISTINCT @PersonID,@PersonType,A.ZH AS PersonName,A.RSMId,A.RSMType,A.RSM

		----FROM #PersonDetails A

		----WHERE A.ZHId=@PersonID AND A.ZHType=@PersonType AND A.RSMId<>0 AND A.RSM<>'Vacant'

	 ----END



	INSERT INTO #tmpPersonDet(PersonID,PersonType,PersonName,ManagerID,ManagerType,ManagerName)

	SELECT DISTINCT @PersonID AS PersonNodeId,@PersonType AS PersonNodeType,Descr AS PersonName,-99,-99,'Other Manager'

	FROM tblMstrPerson

	WHERE NodeID=@PersonID AND NodeType=@PersonType



	 SELECT * FROM #tmpPersonDet WHERE ManagerName<>'NA'

END


