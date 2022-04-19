

--[spRptGetReportlevel]1,3
CREATE PROCEDURE [dbo].[spRptGetReportlevel]
@LoginId INT=0,
@flgType TINYINT=0	--0:All Measures
AS
BEGIN
	DECLARE @LoginUserNodeID INT=0
	DECLARE @LoginUserNodeType TINYINT=0
	DECLARE @SalesAreaNodeType INT=0

	CREATE TABLE #SalesLvl(NodeType INT,NodeTypeDesc VARCHAR(200),flg TINYINT,SalesLvl INT IDENTITY(1,1))

	SELECT @LoginUserNodeID=NodeID,@LoginUserNodeType=NodeType 
	FROM tblSecUserLogin INNER JOIN tblSecUser ON tblSecUser.UserID=tblSecUserLogin.UserID WHERE LoginID=@LoginID
	
	IF @LoginUserNodeID>0
	BEGIN
		SELECT @SalesAreaNodeType=ISNULL(MIN(SP.NodeType),0)
		FROM tblSalesPersonMapping SP
		WHERE SP.PersonNodeID=@LoginUserNodeID AND (GETDATE() BETWEEN SP.FromDate AND SP.ToDate)
	END
	PRINT 'SalesAreaNodeType-' + CAST(@SalesAreaNodeType AS VARCHAR)

	INSERT INTO #SalesLvl(NodeType,NodeTypeDesc,flg)	--
	SELECT NodeType,REPLACE(REPLACE(NodeTypeDesc,'Company ',''),'DBR ','') NodeTypeDesc,0--,CASE NodeType WHEN 95 THEN 1 ELSE 0 END AS Flg
	FROM tblPmstNodeTypes
	WHERE HierTypeId IN(2,5) AND NodeType NOT IN(160,140,170) --AND NodeType>=@SalesAreaNodeType 
	ORDER BY NodeType

	DELETE FROM #SalesLvl WHERE NodeType<@SalesAreaNodeType

	
	UPDATE #SalesLvl SET flg=1 WHERE NodeType=CASE @SalesAreaNodeType WHEN 0 THEN 100 ELSE @SalesAreaNodeType END

	SELECT * FROM #SalesLvl --WHERE NodeType<>150 
	ORDER BY SalesLvl


	--SELECT NodeType,REPLACE(NodeTypeDescr,'DBR ','') NodeTypeDescr,CASE NodeType WHEN 95 THEN 1 ELSE 0 END AS Flg
	--FROM tblPmstNodeTypes
	--WHERE HierTypeId IN(2,5) AND NodeType NOT IN(130,140,170,160,150)

	SELECT DISTINCT RoleId,CASE RoleId WHEN 3 THEN 100 ELSE 150 END AS DefaultNodeType
	FROM tblSecMapUserRoles
END



