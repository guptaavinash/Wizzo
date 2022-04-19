







CREATE  PROCEDURE [dbo].[spMakeTreeMenuSub]   
  
  @MenuNode smallint,   
  @UserID INT  
  -- WITH ENCRYPTION
AS  
  
DECLARE @curRec Cursor  
DECLARE @MnuId SMALLINT  
  
  
INSERT INTO #tmpHierTable (HierID, Descr, PHierId, IsLastLevel, OrdrNum) 
SELECT DISTINCT 
                      TOP 100 PERCENT dbo.tblSecMenuHierarchy.MnID, dbo.tblSecMenuHierarchy.MenuDescription, dbo.tblSecMenuHierarchy.MnParentID, 20 AS Expr1, 
                      dbo.tblSecMenuHierarchy.OrderNum
FROM         dbo.tblSecMenuHierarchy INNER JOIN
                      dbo.tblSecMenuHierarchyRoles ON dbo.tblSecMenuHierarchy.MnID = dbo.tblSecMenuHierarchyRoles.MnId INNER JOIN
                      dbo.tblSecMapUserRoles ON dbo.tblSecMenuHierarchyRoles.RoleID = dbo.tblSecMapUserRoles.RoleId
WHERE     (dbo.tblSecMenuHierarchy.MnParentID = @MenuNode) AND (dbo.tblSecMapUserRoles.UserID = @UserID) AND flgMenuActive<>1
ORDER BY dbo.tblSecMenuHierarchy.OrderNum

  
IF EXISTS (SELECT * FROM #tmpHierTable WHERE PHierId=@MenuNode)  
 BEGIN   
  UPDATE #tmpHierTable SET IsLastLevel=10 WHERE HierID=@MenuNode  
 END 

  
SET @curRec = CURSOR FOR  
 select HierID from #tmpHierTable WHERE PHierId=@MenuNode  
  
OPEN @curRec  
  
 FETCH NEXT FROM @curRec INTO @MnuId  
 WHILE @@FETCH_STATUS = 0  
 BEGIN  
  EXEC spMakeTreeMenuSub @MnuId, @UserID  
  
  FETCH NEXT FROM @curRec INTO @MnuId  
 END
