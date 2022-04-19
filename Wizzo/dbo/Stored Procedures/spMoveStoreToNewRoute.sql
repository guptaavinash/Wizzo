-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
--[spMoveStoreToNewRoute]0,1701345,140133345
CREATE PROCEDURE [dbo].[spMoveStoreToNewRoute]
@StoreId INT,
@NewRouteId_NodeType INT, --RouteNodeType + RouteNodeId
@OldRouteId_NodeType INT,	 --RouteNodeType + RouteNodeId
@LoginId INT
AS
BEGIN
	DECLARE @NewRouteId INT
	DECLARE @NewRouteNodeType INT
	DECLARE @OldRouteId INT
	DECLARE @OldRouteNodetype INT

	SELECT @NewRouteNodeType=LEFT(@NewRouteId_NodeType,3)
	SELECT @NewRouteId=SUBSTRING(CAST(@NewRouteId_NodeType AS VARCHAR),4,LEN(@NewRouteId_NodeType))
	SELECT @NewRouteId
	SELECT @NewRouteNodeType

	SELECT @OldRouteNodetype=LEFT(@OldRouteId_NodeType,3)
	SELECT @OldRouteId=SUBSTRING(CAST(@OldRouteId_NodeType AS VARCHAR),4,LEN(@OldRouteId_NodeType))
	SELECT @OldRouteId
	SELECT @OldRouteNodetype

	IF EXISTS(SELECT 1 FROM tblRouteCoverageStoreMapping WHERE StoreID=@StoreId AND RouteID=@OldRouteId AND RouteNodeType=@OldRouteNodetype AND ISNULL(Todate,GETDATE())>=GETDATE())
	BEGIN
		UPDATE tblRouteCoverageStoreMapping SET ToDate=DATEADD(dd,-1,GETDATE()),LoginIDUpd=@LoginId,TimestampUpd=GETDATE()
		WHERE StoreID=@StoreId AND RouteID=@OldRouteId AND RouteNodeType=@OldRouteNodetype AND ISNULL(Todate,GETDATE())>=GETDATE()
	END
	
	IF NOT EXISTS(SELECT 1 FROM tblRouteCoverageStoreMapping WHERE StoreID=@StoreId AND RouteID=@NewRouteId AND RouteNodeType=@NewRouteNodeType AND ISNULL(Todate,GETDATE())>=GETDATE())
	BEGIN
		INSERT INTO tblRouteCoverageStoreMapping(StoreID,RouteID,RouteNodeType,FromDate,ToDate,LoginIDIns)
		SELECT @StoreId,@NewRouteId,@NewRouteNodeType,GETDATE(),'31-Dec-2049',@LoginId
	END
	ELSE
	BEGIN
		UPDATE tblRouteCoverageStoreMapping SET ToDate='31-Dec-2049',LoginIDUpd=@LoginId,TimestampUpd=GETDATE()
		WHERE StoreID=@StoreId AND RouteID=@NewRouteId AND RouteNodeType=@NewRouteNodeType AND ISNULL(Todate,GETDATE())>=GETDATE()
	END

END
