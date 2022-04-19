create procedure [dbo].[SP_StateEntryForDB]
( 
	@DBID int, @StateID int
)
--SP Created by Varun Jain on 31-Aug-2019 for enetring state ID and DB mapping in the table tblSalesHier_GeoHierMapping
As
Begin
	IF EXISTS (select * from [dbo].[tblSalesHier_GeoHierMapping] where  geonodeid = @StateID and [GeoNodeType] = 310 and SalesAreaNodeID = @DBID and SalesAreaNodetype = 150)
	Print 'This Mapping is Already exist in the table, so cannot insert duplicate entry'
	else
	
			INSERT INTO [dbo].[tblSalesHier_GeoHierMapping]([GeoNodeId],[GeoNodeType],[SalesAreaNodeId],[SalesAreaNodeType],[FromDate],[ToDate],[LoginID],[CreateDate]) VALUES
			(@StateID,310,@DBID,150,GETDATE(),'31-Dec-2049',1,GETDATE())
ENd