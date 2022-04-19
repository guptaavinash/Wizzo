
CREATE proc [dbo].[spPopulateReceiptMasterForPDA]
@RcptId int,
@StoreVisitCode VARCHAR(200),
--@RcptDate date,
@VisitId int,
@RcvdAmount Amount,--Total Received Money
@BalanceAmt Amount=0,---put 0 amount
@StoreID INT,
--@SalesNodeId int,
--@SalesNodeType int,
--@Fyid int,
@LoginId int=0,--put 0 value
@PaymentDetails PaymentDetails readonly
--@ReceiptAdjustment ReceiptAdjustment readonly,
--@DlvryRouteId int=0,
--@OrderId int=0
as
begin
Declare @ReceiptAdjustment ReceiptAdjustment ,@DlvryRouteId int=0,@OrderId int=0,@SalesNodeId int,
@SalesNodeType int,@VanNodeID INT,@VanNodeType SMALLINT,
@Fyid int

SELECT @RcvdAmount=SUM(RcptAmt) FROM @PaymentDetails
DECLARE @NetSalesAmount Amount=0
DECLARE @PersonNodeID INT,@PersonNodeType INT,@VisitDate DATE

--select @CustomerNodeID=CustomerNodeId,@CustomerNodeType=CustomerNodeType from tblvisitmaster where visitid=@visitid
--SELECT @VisitID=VisitID FROM tblVisitMaster WHERE StoreVisitCode=@StoreVisitCode

IF ISNULL(@VisitId,0)>0
BEGIN
	SELECT @RcptId=RcptId FROM tblReceiptMaster WHERE StoreVisitCode=@StoreVisitCode
	SELECT @NetSalesAmount= NetOrderValue FROM tblOrderMaster WHERE VisitID=@VisitId
	SELECT @PersonNodeID=SalesPersonID,@PersonNodeType=SalesPersonType,@VisitDate=VisitDate FROM tblVisitMaster WHERE VisitID=@VisitId
END
PRINT '@PersonNodeID=' + CAST(@PersonNodeID AS VARCHAR)
SELECT @BalanceAmt=@NetSalesAmount-@RcvdAmount

PRINT '@BalanceAmt=' + CAST(@BalanceAmt AS VARCHAR)

DECLARE @PDACode VARCHAR(100)
SELECT @PDACode=PDACode FROM tblPDACodeMapping WHERE PersonID=@PersonNodeID
SELECT @PDACode=PDACode FROM tblPDACodeMapping_History WHERE PersonID=@PersonNodeID

----DECLARE @PDA_IMEI VARCHAR(20)
----SELECT @PDA_IMEI=CASE ISNULL(P.PDA_IMEI,'') WHEN '' THEN P.PDA_IMEI_Sec ELSE P.PDA_IMEI END  FROM tblPDAMaster P INNER JOIN tblPDA_UserMapMaster U ON U.PDAID=P.PDAID WHERE U.PersonID=@PersonNodeID AND U.PersonType=@PersonNodeType AND GETDATE() BETWEEN U.DateFrom AND U.DateTo
----PRINT '@PDA_IMEI=' + @PDA_IMEI
SELECT * INTO #CoverageArea FROM dbo.fnGetCoverageAreaBasedOnPDACode(@PDACode,GETDATE())
--SELECT * FROM #CoverageArea

DECLARE @WorkingTypeID INT
SELECT @WorkingTypeID=dbo.fnGetWorkingTypeForCoverageArea(CoverageAreaNodeID,CoverageAreaNodetype) FROM #CoverageArea
IF @WorkingTypeID=1 -- Direct
BEGIN
	SELECT @VanNodeID=SH.VanID,@VanNodeType=260  FROM tblSalesHierVanMapping SH INNER JOIN tblSalesPersonMapping SM ON SM.NodeID=SH.SalesNodeID AND SM.NodeType=SH.SalesNodetype INNER JOIN tblMstrPerson P ON P.NodeID=SM.PersonNodeID AND P.NodeType=SM.PersonType WHERE @VisitDate BETWEEN SM.FromDate AND SM.ToDate AND CAST(@VisitDate AS DATE) BETWEEN CAST(SH.Fromdate AS DATE) AND CAST(SH.Todate AS DATE) AND @VisitDate BETWEEN P.FromDate AND P.ToDate AND SM.PersonNodeID=@PersonNodeID AND SM.PersonType=@PersonNodeType

	SELECT @VanNodeID=VanID,@VanNodeType=260 FROM tblVanStockMaster V,(SELECT SalesManNodeId,MAX(TransDate) TransDate FROM tblVanStockMaster WHERE SalesManNodeId=@PersonNodeID AND SalesManNodeType=@PersonNodeType AND CAST(TransDate AS DATE)<=CAST(@VisitDate AS DATE) GROUP BY SalesManNodeId) X WHERE X.TransDate=V.TransDate  AND X.SalesManNodeId=V.SalesManNodeId
END
ELSE
BEGIN
	SELECT @VanNodeID=0 ,@VanNodeType=0
END


----SELECT @VanNodeID=SH.VanID,@VanNodeType=260  FROM tblSalesHierVanMapping SH INNER JOIN tblSalesPersonMapping SM ON SM.NodeID=SH.SalesNodeID AND SM.NodeType=SH.SalesNodetype INNER JOIN tblMstrPerson P ON P.NodeID=SM.PersonNodeID AND P.NodeType=SM.PersonType WHERE @VisitDate BETWEEN SM.FromDate AND SM.ToDate AND CAST(@VisitDate AS DATE) BETWEEN CAST(SH.Fromdate AS DATE) AND CAST(SH.Todate AS DATE) AND @VisitDate BETWEEN P.FromDate AND P.ToDate AND SM.PersonNodeID=@PersonNodeID AND SM.PersonType=@PersonNodeType
	
----SELECT @VanNodeID=VanID,@VanNodeType=260 FROM tblVanStockMaster V,(SELECT SalesManNodeId,MAX(TransDate) TransDate FROM tblVanStockMaster WHERE SalesManNodeId=@PersonNodeID AND SalesManNodeType=@PersonNodeType AND CAST(TransDate AS DATE)<=CAST(@VisitDate AS DATE) GROUP BY SalesManNodeId) X WHERE X.TransDate=V.TransDate  AND X.SalesManNodeId=V.SalesManNodeId


SELECT @SalesNodeId=DBID,@SalesNodeType=DBNodeType FROM tblStoremaster WHERE StoreId=@StoreID
			
SELECT @FYID=FYID FROM TBLfINANCIALYEAR WHERE @VisitDate Between FYStartDate and FYEndDate
				


MERGE tblReceiptMaster ReceiptMaster USING (select @RcptId as RcptId,@VisitDate as RcptDate,@visitid as visitid,@RcvdAmount as RcvdAmount, @SalesNodeId as SalesNodeId
 ,@SalesNodeType as SalesNodeType,@Fyid as Fyid,@BalanceAmt as BalanceAmt,@DlvryRouteId as DlvryRouteId,@OrderId AS OrderId,@StoreID as StoreID,@VanNodeID VanNodeID,@VanNodeType VanNodeType,@StoreVisitCode as StoreVisitCode
 ) as ReceiptMasterSrc
  
ON  ReceiptMaster.RcptId = ReceiptMasterSrc.RcptId  
WHEN MATCHED THEN  
  UPDATE  
  SET 
 ReceiptMaster.visitid = ReceiptMasterSrc.visitid  ,
 ReceiptMaster.StoreID = ReceiptMasterSrc.StoreID  ,
  ReceiptMaster.RcvdAmount = ReceiptMasterSrc.RcvdAmount  ,
  ReceiptMaster.BalanceAmt = ReceiptMasterSrc.BalanceAmt  ,
  ReceiptMaster.SalesNodeId = ReceiptMasterSrc.SalesNodeId  ,
   ReceiptMaster.SalesNodeType = ReceiptMasterSrc.SalesNodeType  ,
    ReceiptMaster.VanNodeID = ReceiptMasterSrc.VanNodeID  ,
   ReceiptMaster.VanNodeType = ReceiptMasterSrc.VanNodeType  ,
   ReceiptMaster.Fyid = ReceiptMasterSrc.Fyid  ,
 ReceiptMaster.LoginIDUpd = @LoginId,  
 ReceiptMaster.DlvryRouteId= ReceiptMasterSrc.DlvryRouteId,
 ReceiptMaster.TimeStampUpd = GETDATE()  
WHEN NOT MATCHED BY TARGET THEN  
  INSERT (RcptDate,visitid,StoreID,RcvdAmount, SalesNodeId,SalesNodeType,Fyid,
		LoginIDIns, TimestampIns,DlvryRouteId,BalanceAmt,VanNodeID,VanNodeType,StoreVisitCode)  
  VALUES (ReceiptMasterSrc.RcptDate,ReceiptMasterSrc.visitid,ReceiptMasterSrc.StoreID,ReceiptMasterSrc.RcvdAmount, ReceiptMasterSrc.SalesNodeId,ReceiptMasterSrc.SalesNodeType,ReceiptMasterSrc.Fyid,
  @LoginId,Getdate(),ReceiptMasterSrc.DlvryRouteId,ReceiptMasterSrc.BalanceAmt,@VanNodeID,@VanNodeType,ReceiptMasterSrc.StoreVisitCode );

  Declare @SeqNo int,@RcptCode varchar(50)
  	IF @RcptId=0
					BEGIN
						SELECT @RcptId=IDENT_CURRENT('tblReceiptMaster')
		
						exec spGenerateTrnSequenceNumber 'tblReceiptMaster','RcptNo','RC',@FYID,@SalesNodeId,@SalesNodeType,@SeqNo output,@RcptCode output
						WHILE EXISTS (SELECT RcptNo  FROM tblReceiptMaster WHERE RcptNo =@RcptCode  and SalesNodeId=@SalesNodeId  and SalesNodeType=@SalesNodeType)
						BEGIN
							exec spGenerateTrnSequenceNumber 'tblReceiptMaster','RcptNo','RC',@FYID,@SalesNodeId,@SalesNodeType,@SeqNo output,@RcptCode output
						END
						Print 'test2'
						UPDATE tblReceiptMaster SET RcptNo=@RcptCode,RcptInitTag='RC',RcptSeqNo=@SeqNo WHERE RcptId=@RcptId
					END
					ELSE
					BEGIN
						SELECT @RcptCode = RcptNo FROM tblReceiptMaster WHERE RcptId=@RcptId
					END
Delete tblReceiptDetail where [RcptId]=@RcptId
insert into tblReceiptDetail([RcptId],[AdvChqId],[InstrumentModeId],[TrnRefNo],[TrnDate],[RcptAmt],[BankId],[BankAdd],[Remarks],[AttachFilePath],[flgCleared])
select @RcptId,[AdvChqId],[InstrumentMode],[TrnRefNo],[TrnDate],[RcptAmt],[BankId],[BankAdd],[Remarks],[AttachFilePath],CASE WHEN [InstrumentMode]=2 then 0 else 1 end from @PaymentDetails



exec spAdjustReceiptAmount @RcptId

--select @BalanceAmt=@RcvdAmount-isnull(sum(AdjustedAmount),0) from [tblReceiptAdjustment] a  where a.RcptId=@RcptId
--if @BalanceAmt>0
--begin
--if object_id('tempdb..#tmpInv') is not null
--begin
--drop table #tmpInv
--end
--Create table #tmpInv(ident int identity(1,1),RefId int,RefType int,NetAmount numeric(18,2),AlreadyAdjustedAmt numeric(18,2),BalanceAmt numeric(18,2)
--,CurrAdjAmt numeric(18,2),RefDate date)
--insert into #tmpInv
--select A.InvId,1 as RefType,NetRoundedAmount as NetAmount,convert(numeric(18,2),0) as AlreadyAdjustedAmt,convert(numeric(18,2),0) as BalanceAmt,
--convert(numeric(18,2),0) as CurrAdjAmt,InvDate  from tblInvMaster A where a.CustomerNodeId=@storeid and a.flgInvStatus=1
--order by InvDate

--Declare @i int,@cnt int,@RefId int,@RefType int,@AdjAmount numeric(18,2)
--set @i=1
--select @cnt=count(*) from #tmpInv
--if @cnt<@i
--begin
--set @i=0
--end
--while @i<=@cnt
--begin

--select @RefId=RefId,@RefType=RefType from #tmpInv where ident=@i

--select @AdjAmount=isnull(sum(AdjustedAmount),0) from 
--(SELECT         C.AdjustedAmount
--FROM            tblReceiptAdjustment AS C INNER JOIN
--                         tblReceiptMaster ON C.RcptId = tblReceiptMaster.RcptId
--WHERE        (C.RefType = @RefType) AND (tblReceiptMaster.StatusId <> 2)
--and C.[RefId] =@RefId


--) as a

--update #tmpInv set AlreadyAdjustedAmt=@AdjAmount where ident=@i

--Update #tmpInv set BalanceAmt=NetAmount-AlreadyAdjustedAmt where ident=@i

--Update #tmpInv set CurrAdjAmt=case when BalanceAmt>=@BalanceAmt then  @BalanceAmt else BalanceAmt end where ident=@i
--select @BalanceAmt=@BalanceAmt-CurrAdjAmt from #tmpInv where ident=@i

--	if @BalanceAmt=0
--	begin
--		break;
--	end
--set @i=@i+1
--end
--Update tblReceiptMaster set BalanceAmt=@BalanceAmt where [RcptId]=@RcptId
--insert into [tblReceiptAdjustment]([RcptId],[RefType],[RefId],[TotalInvamount],[AdjustedAmount])
--select @RcptId,RefType,RefId,NetAmount,CurrAdjAmt from #tmpInv where ident<=@i

--Update b set flgInvStatus=3 from #tmpInv A join tblInvMaster b on a.refid=b.invid where ident<=@i and flgInvStatus=1 and reftype=1
--and a.BalanceAmt<=a.CurrAdjAmt
--Update b set StatusId=3 from #tmpInv A join tblDebitNoteMstr b on a.refid=b.DebNoteId where ident<=@i and StatusId=1 and reftype=2
--end
end

