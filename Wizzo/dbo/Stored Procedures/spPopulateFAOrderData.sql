
  CREATE proc [dbo].[spPopulateFAOrderData]
AS
BEGIN
  if OBJECT_ID('tempdb..#OrderData') is not null
  begin
	  drop table #OrderData
  end
  select distinct a.VisitId,OutletERPId,CONVERT(date,time) as OrdDate,ProductERPId,CONVERT(numeric(18,0),Quantity) AS Quantity,CONVERT(NUMERIC(18,2),Price) AS Price,0 as OrderId,0 as StoreId,0 as PrdId into #OrderData from [tmpRawDataLastVisitDetailsAPI] a join [tmpRawDataLastVisitDetailsAPI_Sales] b on a.VisitId=b.VisitId

  
  Update a set StoreId=B.StoreID from #OrderData a join tblStoreMaster B ON a.OutletERPId=B.StoreCode

  Update a set OrderId=B.FAOrdId from #OrderData a join tblFAORDERmASTER B ON a.VisitId=B.FAOrderNo

  INSERT INTO tblFAORDERmASTER

  SELECT VisitId,OrdDate,StoreId,SUM(Quantity*PRICE),GETDATE() FROM #OrderData WHERE OrderId=0
  GROUP BY VisitId,StoreId,OrdDate


  Update a set OrderId=B.FAOrdId from #OrderData a join tblFAORDERmASTER B ON a.VisitId=B.FAOrderNo
  WHERE a.OrderId=0

  DELETE A FROM tblFAOrderDetail A JOIN #OrderData B ON A.FAOrdId=B.OrderId

  Update a set PrdId=B.NodeID from #OrderData a join tblPrdMstrSKULvl B ON a.ProductERPId=B.SKUCode

  INSERT INTO tblFAOrderDetail
  select OrderId,PrdId,Quantity,Price,Quantity*Price from #OrderData


  Declare @VisitId varchar(50)
  select @VisitId=MAX(VisitId) from #OrderData 

  update tblextractmaster set  LastId=@VisitId,TimeStampUpd=GETDATE() where ExtractId=3 and ISNULL(lastid,0)<@VisitId
  END