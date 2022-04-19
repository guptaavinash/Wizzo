
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
--EXEC [SpRptGetStoreListBasedOnHeaderForBeatProfile]48654,140,15
CREATE PROCEDURE [dbo].[SpRptGetStoreListBasedOnHeaderForBeatProfile] 
@SalesAreaNodeId INT,
@SalesAreaNodeType INT,
@HeaderId INT
AS
BEGIN
	SELECT * INTO #tmpBeatProfileData FROM tblRptBeatProfileData WHERE AreaNodeId=@SalesAreaNodeId AND AreaNodeType=@SalesAreaNodeType

	IF @HeaderId=6
		SELECT dbo.ConvertFirstLetterinCapital(B.StoreName) [Store Name] FROM #tmpBeatProfileData A INNER JOIn tblStoreMaster B ON A.StoreId=B.StoreId WHERE IsVisitedOnLastVisit=1 ORDER BY B.StoreName
	ELSE IF @HeaderId=7
		SELECT dbo.ConvertFirstLetterinCapital(B.StoreName) [Store Name] FROM #tmpBeatProfileData A INNER JOIn tblStoreMaster B ON A.StoreId=B.StoreId WHERE IsProductiveOnLastVisit=1 ORDER BY B.StoreName
	ELSE IF @HeaderId=8
		SELECT dbo.ConvertFirstLetterinCapital(B.StoreName) [Store Name] FROM #tmpBeatProfileData A INNER JOIn tblStoreMaster B ON A.StoreId=B.StoreId WHERE ISNULL(SaleOnLastVisit,0)>0 ORDER BY B.StoreName
	ELSE IF @HeaderId=9
		SELECT dbo.ConvertFirstLetterinCapital(B.StoreName) [Store Name] FROM #tmpBeatProfileData A INNER JOIn tblStoreMaster B ON A.StoreId=B.StoreId ORDER BY B.StoreName
	ELSE IF @HeaderId=11
		SELECT dbo.ConvertFirstLetterinCapital(B.StoreName) [Store Name] FROM #tmpBeatProfileData A INNER JOIn tblStoreMaster B ON A.StoreId=B.StoreId WHERE Covered_P4W=1 ORDER BY B.StoreName
	ELSE IF @HeaderId=12
		SELECT dbo.ConvertFirstLetterinCapital(B.StoreName) [Store Name] FROM #tmpBeatProfileData A INNER JOIn tblStoreMaster B ON A.StoreId=B.StoreId WHERE Productive_P4W=1 ORDER BY B.StoreName
	ELSE IF @HeaderId=13
		SELECT dbo.ConvertFirstLetterinCapital(B.StoreName) [Store Name] FROM #tmpBeatProfileData A INNER JOIn tblStoreMaster B ON A.StoreId=B.StoreId WHERE NonProductive_P4W=1 ORDER BY B.StoreName
	ELSE IF @HeaderId=14
		SELECT dbo.ConvertFirstLetterinCapital(B.StoreName) [Store Name] FROM #tmpBeatProfileData A INNER JOIn tblStoreMaster B ON A.StoreId=B.StoreId WHERE NonProductive_P3M=1 ORDER BY B.StoreName
	ELSE IF @HeaderId=15
		SELECT dbo.ConvertFirstLetterinCapital(B.StoreName) [Store Name] FROM #tmpBeatProfileData A INNER JOIn tblStoreMaster B ON A.StoreId=B.StoreId WHERE NonProductive_P4W=1 AND flgStarOutlets=1 ORDER BY B.StoreName
END

--SELECT * FROM tblRptBeatProfileData
