
CREATE Proc [dbo].[spPopulateOrderReturn]
@PDA_IMEI varchar(50),
@StoreId int,
@StoreVisitCode VARCHAR(20),
@VisitID INT,
@RouteID INT,
@RouteNodeType SMALLINT,
@OrderReturnDetail [dbo].[OrderReturnDetail] READONLY,
@OrderReturnPhotoDetail OrderReturnPhotoDetail Readonly,
@OrderPDAID VARCHAR(100)
as
begin
BEGIN TRANSACTION	t1

BEGIN TRY
PRINT 'A1'
DECLARE @VisitDate Date
--SET @VisitDate=CONVERT(Date,@ReturnDate,105)
--SET @VisitDate=@ReturnDate

--DECLARE  @VisitID INT
--Select @VisitID = VisitID,@VisitDate=VisitDate FROM [dbo].[tblVisitMaster] WHERE StoreID=@StoreID AND StoreVisitCode=@StoreVisitCode
DECLARE @Channel VARCHAR(100),@OrderReturnDetailN [dbo].[OrderReturnDetail]

INSERT INTO @OrderReturnDetailN 
SELECT * FROM @OrderReturnDetail WHERE Qty>0
PRINT 'A'
if  exists (select * from @OrderReturnDetailN)
begin


	SELECT @RouteNodeType=NodeType FROM tblSecMenuContextMenu WHERE flgRoute=1

 		DECLARE @StoreVisitID INT, @RouteVisitID INT, @OrderReturnID INT, @OrderReturnDetailID INT, @DSRID INT,
		@PersonNodeID INT,@PersonType TINYINT

		--Select @DeviceID = PDAID FROM tblPDAMaster WHERE PDA_IMEI = @PDA_IMEI OR PDA_IMEI_Sec=@PDA_IMEI

PRINT 'B'	


		SELECT        @PersonNodeID = tblSalesPersonMapping.PersonNodeID,@PersonType=tblSalesPersonMapping.PersonType
		FROM            tblSalesPersonMapping WHERE tblSalesPersonMapping.NodeID = @RouteID AND tblSalesPersonMapping.NodeType=@RouteNodeType	
		AND (@VisitDate BETWEEN  tblSalesPersonMapping.FromDate AND tblSalesPersonMapping.ToDate) 
	
	
		SELECT @RouteVisitID=MAX(RouteVisitID) FROM tblTranVisitDetails WHERE RouteID=@RouteID AND RouteType=@RouteNodeType AND
		CAST(VisitForDate AS DATE)=@VisitDate 
PRINT 'C'
		
		
		SELECT @OrderReturnID = OrderReturnID FROM tblOrderReturnMstr WHERE VisitID = @VisitID AND OrderPDAID=@OrderPDAID
		IF ISNULL(@OrderReturnID,0)>0
		BEGIN
			DELETE FROM tblOrderReturnMstr WHERE VisitID = @VisitID AND OrderPDAID=@OrderPDAID
		END

		
PRINT 'D'
	Select *,MRP AS Rate,CONVERT(decimal(18,4),qty*MRP) as NetValue,CONVERT(int,0) as OrderDetailId into #tmpOrderReturn from @OrderReturnDetailN A join VwSFAProductHierarchy B ON A.PrdID=B.SKUNodeID

	Declare @SalesNodeId int,@SalesNodeType int,@Fyid int

	select @SalesNodeId=DBID,@SalesNodeType=DBNodeType from tblstoremaster where storeid=@storeid

	select @Fyid=fyid from  tblFinancialYear where @VisitDate between FYStartDate and FYEndDate

	INSERT INTO tblOrderReturnMstr(VisitID,VisitDate,StoreID,NetValueReturn,NetQtyReturn,OrderPDAID,SalesNodeId,SalesNodeType,SalesPersonNodeId,SalesPersonNodeType,FYID,StatusId,OrderReturnType,ReturnActionDecisionStatusId,ReturnPhysicalStockStatusId,ResolutionDecisionStatusid,ActualResolutionStatusId,StoreVisitCode)

	Select @VisitID,@VisitDate,@StoreId,SUM(NetValue),SUM(Qty),@OrderPDAID,@SalesNodeId,@SalesNodeType,@PersonNodeID,@PersonType,@FYID,1,3,1,1,0,0,@StoreVisitCode from #tmpOrderReturn
	set @OrderReturnID=0
	Declare @SeqNo int,@OrderReturnCode varchar(50)
  	IF @OrderReturnID=0
					BEGIN
						SELECT @OrderReturnID=IDENT_CURRENT('tblOrderReturnMstr')
		
						exec spGenerateTrnSequenceNumber 'tblOrderReturnMstr','OrderReturnCode','OR',@FYID,@SalesNodeId,@SalesNodeType,@SeqNo output,@OrderReturnCode output
						WHILE EXISTS (SELECT OrderReturnCode  FROM tblOrderReturnMstr WHERE OrderReturnCode =@OrderReturnCode)
						BEGIN
							exec spGenerateTrnSequenceNumber 'tblOrderReturnMstr','OrderReturnCode','OR',@FYID,@SalesNodeId,@SalesNodeType,@SeqNo output,@OrderReturnCode output
						END
						Print 'test2'
						UPDATE tblOrderReturnMstr SET OrderReturnCode=@OrderReturnCode,OrderReturnInitTag='OR',OrderReturnSeqNo=@SeqNo WHERE OrderReturnID=@OrderReturnID
					END
					ELSE
					BEGIN
						SELECT @OrderReturnCode = OrderReturnCode FROM tblOrderReturnMstr WHERE OrderReturnID=@OrderReturnID
					END
PRINT 'E'
	INSERT INTO tblOrderReturnDetail (OrderReturnID,PrdID,Qty,Rate,NetValueReturn,Reason,StockStatusId,Tax)
	select @OrderReturnID,PrdID,Qty,Rate,NetValue,Reason,StockStatusId,Tax from  #tmpOrderReturn

	update A SET OrderDetailId=B.OrderReturnDetailID  from #tmpOrderReturn A JOIN tblOrderReturnDetail B ON A.Prdid=b.prdid where B.OrderReturnID=@OrderReturnID

	INSERT INTO  tblOrderReturnPhotoDetail
	select A.OrderDetailId,B.PhotoName,B.PhotoClickedOn,B.flgDelete from #tmpOrderReturn A  inner join @OrderReturnPhotoDetail B on A.PrdID=B.PrdID
PRINT 'F'
end

END TRY
BEGIN CATCH
rollback transaction t1
return
END CATCH
commit transaction t1
end


