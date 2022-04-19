
-- =============================================
-- Author:		Avinash Gupta
-- Create date: 12-May-2015
-- Description:	Sp to assign or manage the person for all the route under the beat.
-- =============================================
CREATE PROCEDURE [dbo].[SpManagePersonMappingForRoutesUnderBeat] 
	@SalesStructureNodeID INT,
	@SalesStructureNodeType INT,
	@PersonNodeID INT=0,
	@PersonType INT,
	@PersonName VARCHAR(400),
	@MobileNo VARCHAR(12),
	@EMail VARCHAR(50),
	@FromDate DATETIME,
	@ToDate DATETIME,
	@LoginID INT,
	@flgPersonMoved TINYINT,  -- 0=Not Moved,1=Moved
	@flgPersonType TINYINT, -- 1=Company ,2=Distributor
	@flgOtherLevelPerson TINYINT=0 -- 0=Assigned Person is from same level,1=Assigned Perosn is from Other Level.

AS
BEGIN
	DECLARE @NodeID INT
	DECLARE @NodeType INT

;WITH CTEAllChilds AS 
	( 
	--initialization 
	SELECT NodeID, NodeType, HierID ,PNodeID,PNodeType
	FROM tblCompanySalesStructureHierarchy  
	WHERE NodeID= @SalesStructureNodeID AND NodeType=@SalesStructureNodeType
	UNION ALL 
	--recursive execution 
	SELECT C.NodeID, C.NodeType, C.HierID ,C.PNodeID,C.PNodeType
	FROM tblCompanySalesStructureHierarchy C INNER JOIN CTEAllChilds O
	ON C.PHierID = O.HierID 
	) 

	SELECT * INTO #cteallchilds FROM CTEAllChilds

	----IF @flgPersonMoved=1 AND @SalesStructureNodeType IN (6)
	----BEGIN
	----	UPDATE tblSalesPersonMapping SET ToDate=DATEADD(d,-1,@FromDate) WHERE PersonNodeID=@PersonNodeID AND NodeType IN (6,7)
	----	AND @FromDate BETWEEN FromDate AND ToDate
	----	--SELECT * FROM tblSalesPersonMapping WHERE PersonNodeID=23 
	----	UPDATE tblSalesPersonMapping SET PersonNodeID=0  WHERE PersonNodeID=@PersonNodeID AND NodeType IN (6,7) AND FromDate>@FromDate
	----END
	----IF @flgPersonMoved=1 AND @SalesStructureNodeType IN (15)
	----BEGIN
	----	UPDATE tblSalesPersonMapping SET ToDate=DATEADD(d,-1,@FromDate) WHERE PersonNodeID=@PersonNodeID AND NodeType IN (15,16)
	----	AND @FromDate BETWEEN FromDate AND ToDate
	----	--SELECT * FROM tblSalesPersonMapping WHERE PersonNodeID=23 
	----	UPDATE tblSalesPersonMapping SET PersonNodeID=0  WHERE PersonNodeID=@PersonNodeID AND NodeType IN (15,16) AND FromDate>@FromDate
	----END

	DECLARE Cur_Routes CURSOR FOR
	SELECT DISTINCT NodeID,NodeType FROM #cteallchilds WHERE PNodeID=@SalesStructureNodeID AND PNodeType=@SalesStructureNodeType

	OPEN Cur_Routes
	FETCH NEXT FROM Cur_Routes INTO @NodeID,@NodeType
	WHILE @@FETCH_STATUS = 0
	BEGIN
		PRINT 'Called'
		EXEC SpManagePersonMapping @NodeID,@NodeType,@PersonNodeID,@PersonType,@PersonName,@MobileNo,@EMail,@FromDate,@ToDate,@LoginID,@flgPersonMoved,@flgPersonType,@flgOtherLevelPerson
		FETCH NEXT FROM Cur_Routes INTO @NodeID,@NodeType
	END
	CLOSE Cur_Routes
	DEALLOCATE Cur_Routes

END






