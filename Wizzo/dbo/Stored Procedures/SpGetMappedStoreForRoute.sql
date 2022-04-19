

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
--[SpGetMappedStoreForRoute]210,170
CREATE PROCEDURE [dbo].[SpGetMappedStoreForRoute] 
@RouteNodeID INT,
@RouteNodeType INT
AS
BEGIN
	CREATE TABLE #StoreList (StoreID INT,StoreName VARCHAR(200),Area VARCHAR(500),PostCode VARCHAR(50),PhoneNo BIGINT,ContactPerson VARCHAR(200),NodeType INT,[LatCode] NUMERIC (18,9),[LongCode] NUMERIC (18,9),flgMapped tinyint)
	
	INSERT INTO #StoreList (StoreID ,StoreName ,Area ,PostCode,PhoneNo,ContactPerson,[LatCode],[LongCode],flgMapped)
	SELECT DISTINCT SM.StoreID,SM.StoreName,ISNULL(AD.StoreAddress1,'NA'),ISNULL(CAST(AD.Pincode AS VARCHAR),'NA'),ISNULL(CAST(CD.MobNo AS VARCHAR),'NA'),ISNULL(CD.FName,'NA'),SM.[Lat Code],SM.[Long Code],1
	FROM tblRouteCoverageStoreMapping RCS INNER JOIN tblStoreMaster SM ON RCS.StoreID=SM.StoreID
	LEFT JOIN tblOutletAddressDet AD ON SM.StoreID=AD.StoreId AND AD.OutAddTypeID=1
	LEFT JOIN tbloutletContactDet CD ON SM.StoreID=CD.StoreId AND CD.OutCnctpersonTypeID=1
	WHERE RCS.RouteID=@RouteNodeID AND RCS.RouteNodeType=@RouteNodeType AND (GETDATE() BETWEEN FromDate AND Todate)
	
	SELECT  DISTINCT StoreID ,StoreName ,Area ,PostCode ,NodeType,[LatCode],[LongCode],flgMapped,PhoneNo,ContactPerson FROM #StoreList --WHERE RouteID IS NULL
order by StoreName

END

