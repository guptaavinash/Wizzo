CREATE proc [dbo].[spGetInvDetailN] 
@flgOrderSource tinyint,
@InvId int
as
begin
if @flgOrderSource=1
begin
select p.SKUCode AS ProductCode,P.Descr as  ProductName,A.Qty AS Quantity,A.Rate,convert(numeric(18,2),A.NetOrderValue) AS [Sales Value] from tblFAOrderDetail A JOIN tblPrdMstrSKULvl p on a.PrdId=p.NodeID where FAOrdId=@InvId
end
else if @flgOrderSource=2
begin
---convert(varchar,A.OrderQty)+' Pcs'
select p.SKUCode AS ProductCode,P.Descr as  ProductName,convert(varchar,A.OrderQty)+' Pcs' AS Quantity,A.FreeQty,convert(numeric(18,2),A.ProductRate) as Rate,convert(numeric(18,2),A.NetLineOrderVal) AS [Sales Value] from tblTCOrderDetail A JOIN tblPrdMstrSKULvl p on a.PrdNodeId=p.NodeID where OrderID=@InvId
end
else if @flgOrderSource=3
begin
select p.SKUCode AS ProductCode,P.Descr as  ProductName,A.OrderQty AS Quantity,A.FreeQty,convert(numeric(18,2),A.ProductRate) Rate,convert(numeric(18,2),A.NetLineOrderVal) AS [Sales Value] from tblOrderDetail A JOIN tblPrdMstrSKULvl p on a.ProductID=p.NodeID where OrderID=@InvId
end

end