

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
--[spInc_CalculateIncentive_PersonWise]202203,138,220
CREATE PROCEDURE [dbo].[spInc_CalculateIncentive_PersonWise]
@RptMonthYear INT,
@PersonNodeId INT,
@PersonNodeType INT
AS
BEGIN
	DECLARE @cur_IncList CURSOR
	DECLARE @cur_IncSlabList CURSOR
	DECLARE @cur_IncSlabRuleList CURSOR
	DECLARE @cur_Weeks CURSOR
	DECLARE @IncId INT
	DECLARE @IncStartDate DATE
	DECLARE @IncEndDate DATE
	DECLARE @IncSlabId INT
	DECLARE @IncSlabStartDate DATE
	DECLARE @IncSlabEndDate DATE
	DECLARE @strSlabRule VARCHAR(100)=''


	CREATE TABLE #IncentiveList(IncId INT,IncDescr VARCHAR(500),KPIId INT,IncStartDate DATE,IncEndDate DATE)
	CREATE TABLE #EligibleSalesmanList(PersonId INT,PersonType INT,PersonName VARCHAR(200))
	PRINT 'A'
	PRINT CONVERT(VARCHAR,GETDATE(),109)

	INSERT INTO #IncentiveList(IncId,IncDescr,KPIId,IncStartDate,IncEndDate)
	SELECT ICM.IncId,ICM.IncentiveName,ICM.KPIId,ICD.IncStartDate,ICD.IncEndDate
	FROM tblIncentiveMaster ICM INNER JOIN tblIncentiveDates ICD ON ICM.IncID=ICD.IncID
	WHERE CONVERT(VARCHAR(6),ICD.IncStartDate,112)<=@RptMonthYear AND CONVERT(VARCHAR(6),ICD.IncEndDate,112)>=@RptMonthYear

	--SELECT * FROM #IncentiveList

	IF EXISTS(SELECT 1 FROM #IncentiveList)
	BEGIN
		INSERT INTO #EligibleSalesmanList(PersonId,PersonType,PersonName)
		SELECT DISTINCT MP.NodeID,MP.NodeType,MP.Descr
		FROM tblMstrPerson MP INNER JOIN tblSalesPersonMapping SP on MP.NodeID=SP.PersonNodeID
		WHERE SP.Nodetype=120 AND CONVERT(VARCHAR(6),SP.FromDate,112)<=@RptMonthYear AND CONVERT(VARCHAR(6),SP.ToDate,112)>=@RptMonthYear AND SP.PersonNodeID=@PersonNodeId
		--SELECT * FROm #EligibleSalesmanList

		PRINT 'b'
		PRINT CONVERT(VARCHAR,GETDATE(),109)

		CREATE TABLE #SlabRuleList(IncSlabRuleId INT,MsrId INT,TimeGranualrityId INT,CalcSequence INT,CutoffVal INT,UomId INT,PayoutAmount MONEY,DependentSlabRuleId INT)
		DECLARE @IncSlabRuleId INT
		DECLARE @MsrId INT
		DECLARE @TimeGranualrityId INT
		DECLARE @CalcSequence INT
		DECLARE @CutoffVal INT
		DECLARE @UomId INT
		DECLARE @PayoutAmount MONEY
		DECLARE @DependentSlabRuleId INT

		DECLARE @LastDateOfReportingMonth DATE
		DECLARE @FirstDateOfReportingMonth DATE
		CREATE TABLE #tmpDays(Dt DATE, WeekNo INT,WeekEnding DATE,WeekStart DATE,[Weekday] INT,RptMonthYear INT, DayNo INT IDENTITY(1,1))
		CREATE TABLE #ApplicableMaterialList(IncSlabRuleId INT,MaterialNodeId INT,MaterialNodeType INT)

		SELECT @LastDateOfReportingMonth=DATEADD(s,-1,DATEADD(mm, DATEDIFF(m,0,CAST(CAST(@RptMonthYear AS VARCHAR) + '01' AS DATE))+1,0))
		SELECT @FirstDateOfReportingMonth=CAST(CAST(@RptMonthYear AS VARCHAR) + '01' AS DATE)
		--SELECT @FirstDateOfReportingMonth
		--SELECT @LastDateOfReportingMonth
		PRINT 'C'
		PRINT CONVERT(VARCHAR,GETDATE(),109)
		TRUNCATE TABLE #tmpDays
		WHILE @FirstDateOfReportingMonth<=@LastDateOfReportingMonth AND @FirstDateOfReportingMonth<=CAST(GETDATE() AS DATE)
		BEGIN
			INSERT INTO #tmpDays(Dt)
			SELECT @FirstDateOfReportingMonth

			SELECT @FirstDateOfReportingMonth= DATEADD(dd,1,@FirstDateOfReportingMonth)
		END
		PRINT 'C2'
		PRINT CONVERT(VARCHAR,GETDATE(),109)
		SET DATEFIRST 1
		UPDATE #tmpDays SET WeekNo=DATEPART(WEEK, Dt)  -  DATEPART(WEEK, DATEADD(MM, DATEDIFF(MM,0,Dt), 0))+ 1
		UPDATE #tmpDays SET WeekEnding=[dbo].[fncUTLGetWeekEndDate] (Dt)
		UPDATE #tmpDays SET WeekStart=DATEADD(dd,-6,WeekEnding)
		SET DATEFIRST 7
		PRINT 'C3'
		PRINT CONVERT(VARCHAR,GETDATE(),109)
		DECLARE @WeekStartDate Date
		DECLARE @WeekEndDate Date
		DECLARE @WeekNo INT
		DECLARE @Dt DATE
		--SELECT * FROM #tmpDays
		--SELECT DISTINCT WeekNo,WeekStart,WeekEnding FROM #tmpDays

		SET @cur_Weeks=CURSOR FOR
		SELECT DISTINCT WeekNo,WeekStart,WeekEnding FROM #tmpDays --WHERE CONVERT(VARCHAR(6),WeekEnding,112)=@RptMonthYear
		OPEN @cur_Weeks
		FETCH NEXT FROM @cur_Weeks INTO @WeekNo,@WeekStartDate,@WeekEndDate
		WHILE @@FETCH_STATUS=0
		BEGIN
			SELECT @Dt=@WeekStartDate
			--SELECT @Dt    
			WHILE @Dt<=@WeekEndDate
			BEGIN
				IF NOT EXISTS(SELECT 1 FROM #tmpDays WHERE Dt=@Dt)
				BEGIN
					INSERT INTO #tmpDays(Dt,WeekNo,WeekEnding,WeekStart)
					SELECT @Dt,@WeekNo,@WeekEndDate,@WeekStartDate
				END
				SET @Dt=DATEADD(d,1,@Dt)
			END
			FETCH NEXT FROM @cur_Weeks INTO @WeekNo,@WeekStartDate,@WeekEndDate
		END
		DEALLOCATE @cur_Weeks

		UPDATE #tmpDays SET [Weekday]=DATEPART(dd,Dt)
		UPDATE #tmpDays SET RptMonthYear=CONVERT(VARCHAR(6),Dt,112)
		--SELECT * FROM #tmpDays ORDER BY Dt
		SELECT WeekEnding INTO #WeekList FROM #tmpDays GROUP BY WeekEnding HAVING COUNT(Dt)=7
		--SELECT * FROM #WeekList
		PRINT 'D'
		PRINT CONVERT(VARCHAR,GETDATE(),109)
		SELECT V.*,C.RelConversionUnits INTO #PrdHier FROM VwSFAProductHierarchy V LEFT OUTER JOIN tblPrdMstrPackingUnits_ConversionUnits C ON C.SKUId=V.SKUNodeID WHERE BaseUOMID=3

		CREATE TABLE #Orders(VisitId INT,OrderDate DATE,SalesPersonId INT,SalesPersonType INT,StoreId INT,ProductId INT,OrderQty INT,OrderQtyInCase FLOAT,CaseSize INT,WeekEnding Date,RptMonthYear INT)
	
		SELECT OM.VisitId,OM.OrderDate,OM.SalesPersonId,OM.SalesPersonType,OM.StoreId,OM.OrderId,[dbo].[fncUTLGetWeekEndDate] (OrderDate) WeekEnding,CONVERT(VARCHAR(6),OrderDate,112) RptMonthYear INTO #OrderList
		FROm tblOrderMaster OM INNER JOIN #EligibleSalesmanList C ON OM.SalesPersonID=C.PersonId
		INNER JOIN #tmpDays ON OM.OrderDate=#tmpDays.Dt
		WHERE ISNULL(OM.OrderStatusID,0)<>3

		INSERT INTO #Orders(VisitId,OrderDate,SalesPersonId,SalesPersonType,StoreId,ProductId,OrderQty,OrderQtyInCase,CaseSize,WeekEnding,RptMonthYear)
		SELECT OM.VisitId,OM.OrderDate,OM.SalesPersonId,OM.SalesPersonType,OM.StoreId,OD.ProductId,OD.OrderQty,
		CAST(OD.OrderQty AS FLOAT)/#PrdHier.RelConversionUnits,#PrdHier.RelConversionUnits
		,OM.WeekEnding,OM.RptMonthYear
		FROm #OrderList OM INNER JOIN tblOrderDetail OD ON OM.OrderId=OD.OrderId
		INNER JOIN #PrdHier ON OD.ProductId=#PrdHier.SKUNodeId WHERE YEAR(OM.OrderDate) * 100 + MONTH(OM.OrderDate)=@RptMonthYear
	
		--SELECT * FROM #Orders

		--FROm tblOrderMaster OM INNER JOIN tblOrderDetail OD ON OM.OrderId=OD.OrderId
		--INNER JOIN #EligibleSalesmanList C ON OM.SalesPersonID=C.PersonId
		--INNER JOIN #tmpDays ON OM.OrderDate=#tmpDays.Dt
		--INNER JOIN #PrdHier ON OD.ProductId=#PrdHier.SKUNodeId
		--WHERE ISNULL(OM.OrderStatusID,0)<>3
		--SELECT * FROM #Orders ORDER BY ProductId--OrderDate
		PRINT 'E'
		PRINT CONVERT(VARCHAR,GETDATE(),109)
		CREATE TABLE #Invoice(VisitId INT,OrderDate DATE,OrderId INT,InvDate DATE,SalesPersonId INT,SalesPersonType INT,StoreId INT,ProductId INT,InvQty INT,InvQtyInCase FLOAT,CaseSize INT,WeekEnding Date,RptMonthYear INT)
	
		----INSERT INTO #Invoice(VisitId,OrderDate,OrderId,InvDate,SalesPersonId,SalesPersonType,StoreId,ProductId,InvQty,InvQtyInCase,CaseSize,WeekEnding,RptMonthYear)
		----SELECT OM.VisitId,OM.OrderDate,OM.OrderId,IM.InvDate,OM.SalesPersonId,OM.SalesPersonType,OM.StoreId,ID.ProductId,ID.InvQty,ID.InvQty/CAST(#PrdHier.CaseSize AS FLOAT),#PrdHier.CaseSize,[dbo].[fncUTLGetWeekEndDate] (OM.OrderDate),CONVERT(VARCHAR(6),OM.OrderDate,112)
		----FROm tblOrderMaster OM --INNER JOIN tblOrderDetail OD ON OM.OrderId=OD.OrderId
		----INNER JOIN tblInvoiceMaster IM ON OM.OrderId=IM.OrderId 
		----INNER JOIN tblInvoiceDetail ID ON IM.InvId=ID.InvId
		----INNER JOIN #EligibleSalesmanList C ON OM.SalesPersonID=C.PersonId
		----INNER JOIN #tmpDays ON OM.OrderDate=#tmpDays.Dt
		----INNER JOIN #PrdHier ON ID.ProductId=#PrdHier.SKUNodeId
		----WHERE ISNULL(IM.flgInvStatus,0)<>2

		--SELECT * FROM #Invoice ORDER BY ProductId--OrderDate
		PRINT 'F'
		PRINT CONVERT(VARCHAR,GETDATE(),109)

		CREATE TABLE #BaseDataForMeasure2(VisitId INT,OrderDate DATE,SalesPersonId INT,SalesPersonType INT,StoreId INT,ProductId INT,OrderQty INT,WeekEnding Date,RptMonthYear INT)
		CREATE TABLE #BaseDataForMeasure7(VisitId INT,OrderDate DATE,SalesPersonId INT,SalesPersonType INT,StoreId INT,ProductId INT,OrderQty INT,WeekEnding Date,RptMonthYear INT)
		CREATE TABLE #BaseDataForMeasure3(VisitId INT,OrderDate DATE,SalesPersonId INT,SalesPersonType INT,StoreId INT,ProductId INT,OrderQty INT,WeekEnding Date,RptMonthYear INT)
		CREATE TABLE #BaseDataForMeasure4(InvDate DATE,OrderDate DATE,SalesPersonId INT,SalesPersonType INT,InvQty INT,InvQtyInCase FLOAT,WeekEnding Date,RptMonthYear INT,WeeklyAch FLOAT,MonthlyAch FLOAT,flgDailyAch TINYINT,flgWeeklyAch TINYINT,flgMonthlyAch TINYINT)
		CREATE TABLE #BaseDataForMeasure5(VisitId INT,OrderDate DATE,SalesPersonId INT,SalesPersonType INT,StoreId INT,ProductId INT,CaseSize INT,OrderQty INT,OrderQtyInCase FLOAT,WeekEnding Date,RptMonthYear INT)
		CREATE TABLE #LastVisit(SalesPersonId INT,SalesPersonType INT,StoreId INT,LastVisitDate DATE,VisitId INT)
		CREATE TABLE #BaseDataForMeasure6(SalesPersonId INT,SalesPersonType INT,POSMaterialDetID INT,StoreId INT,Visitid INT,MaterialId INT,CurrentStockQty INT,VisitDate DATE,WeekEnding Date,RptMonthYear INT)

		--SELECT * FROM #IncentiveList

		DECLARE @Count INT=0
		DECLARE @MaterialNodeType INT
		SET @cur_IncList=CURSOR FOR
		SELECT IncId,IncStartDate,IncEndDate FROM #IncentiveList --WHERE IncId IN(7,8)
		ORDER BY IncId
		OPEN @cur_IncList
		FETCH NEXT FROM @cur_IncList INTO @IncId,@IncStartDate, @IncEndDate
		WHILE @@FETCH_STATUS=0
		BEGIN
		----SELECT IncSlabId,FromDate,ToDate,strSlabRule FROM tblIncentive_SlabMaster 
		----WHERE IncId=@IncId AND CONVERT(VARCHAR(6),FromDate,112)<=@RptMonthYear AND CONVERT(VARCHAR(6),ToDate,112)>=@RptMonthYear ORDER BY IncSlabId


		SET @cur_IncSlabList=CURSOR FOR
		SELECT IncSlabId,FromDate,ToDate,strSlabRule FROM tblIncentive_SlabMaster 
		WHERE IncId=@IncId AND CONVERT(VARCHAR(6),FromDate,112)<=@RptMonthYear AND CONVERT(VARCHAR(6),ToDate,112)>=@RptMonthYear ORDER BY IncSlabId
		OPEN @cur_IncSlabList
		FETCH NEXT FROM @cur_IncSlabList INTO @IncSlabId,@IncSlabStartDate, @IncSlabEndDate,@strSlabRule
		WHILE @@FETCH_STATUS=0
		BEGIN
			--SELECT @IncSlabId AS IncSlabId,@IncSlabStartDate AS IncSlabStartDate,@IncSlabEndDate AS IncSlabEndDate,@strSlabRule AS strSlabRule
			--TRUNCATE TABLE #SlabRuleList
			--INSERT INTO #SlabRuleList(IncSlabRuleId,MsrId,TimeGranualrityId,CalcSequence,CutoffVal,UomId,PayoutAmount,DependentSlabRuleId)
			--SELECT IncSlabRuleId,MsrId,TimeGranualrityId,CalcSequence,CutoffVal,UomId,PayoutAmount,DependentSlabRuleId
			--FROM tblIncentive_SlabRuleDetail
			--WHERE IncSlabID=@IncSlabId
			--SELECT * FROM #SlabRuleList

			--SET @cur_IncSlabRuleList=CURSOR FOR
			--SELECT IncSlabRuleId,MsrId,TimeGranualrityId,CalcSequence,CutoffVal,UomId,PayoutAmount,DependentSlabRuleId FROM #SlabRuleList
			--OPEN @cur_IncSlabRuleList
			--FETCH NEXT FROM @cur_IncSlabRuleList INTO @IncSlabRuleId,@MsrId,@TimeGranualrityId,@CalcSequence,@CutoffVal,@UomId,@PayoutAmount,@DependentSlabRuleId
			--WHILE @@FETCH_STATUS=0
			--BEGIN
			
			SELECT @IncSlabRuleId=IncSlabRuleId,@MsrId=MsrId,@TimeGranualrityId=TimeGranualrityId,@CalcSequence=CalcSequence,@CutoffVal=CutoffVal,@UomId=UomId, @PayoutAmount=PayoutAmount,@DependentSlabRuleId=DependentSlabRuleId
			FROM tblIncentive_SlabRuleDetail
			WHERE IncSlabID=@IncSlabId AND CalcSequence=1 AND DependentSlabRuleId IS NULL

			--SELECT IncSlabRuleId,MsrId,TimeGranualrityId,CalcSequence,CutoffVal,UomId,PayoutAmount,DependentSlabRuleId FROM tblIncentive_SlabRuleDetail
			--WHERE IncSlabID=@IncSlabId AND CalcSequence=1 AND DependentSlabRuleId IS NULL

			TRUNCATE TABLE #ApplicableMaterialList

			SELECT @MaterialNodeType=0
			SELECT @MaterialNodeType=MaterialNodeType FROM  tblIncentive_SlabRuleMaterialDetail	WHERE IncSlabRuleId=@IncSlabRuleId

			IF @MaterialNodeType=62
			BEGIN
				INSERT INTO #ApplicableMaterialList(IncSlabRuleId,MaterialNodeId,MaterialNodeType)
				SELECT A.IncSlabRuleId,B.SKUNodeId,B.SKUNodeType
				FROM  tblIncentive_SlabRuleMaterialDetail A INNER JOIN #PrdHier B ON A.MaterialNodeId=B.PrdWeightTypeId
				WHERE A.IncSlabRuleId=@IncSlabRuleId AND A.MaterialNodeType=62
			END
			ELSE-- IF MaterialNodeType=51
			BEGIN
				INSERT INTO #ApplicableMaterialList(IncSlabRuleId,MaterialNodeId,MaterialNodeType)
				SELECT IncSlabRuleId,MaterialNodeId,MaterialNodeType
				FROM  tblIncentive_SlabRuleMaterialDetail
				WHERE IncSlabRuleId=@IncSlabRuleId
			END

			
			
			SELECT @Count=MAX(CalcSequence) FROM tblIncentive_SlabRuleDetail WHERE IncSlabID=@IncSlabId AND DependentSlabRuleId IS NULL
			--SELECT @Count

			IF @MsrId=100
			BEGIN				
				SET DATEFIRST 1
				SELECT DISTINCT RCM.RouteId,D.Dt,dbo.[fnGetPlannedVist](RCM.RouteId,D.Dt) AS FlgPlanned,0 AS PersonId,0 AS PersonType,0 AS IsVisited INTO #tmpRoute
				FROM tblRouteCoverage RCM CROSS JOIN #tmpDays D 
				WHERE D.RptMonthyear=@RptMonthYear ORDER BY RouteId,Dt
				DELETE FROM #tmpRoute WHERE FlgPlanned=0
				SET DATEFIRST 7

				UPDATE A SET A.PersonId =B.PersonNodeId,A.PersonType=B.PersonType FROm #tmpRoute A INNER JOIN tblSalesPersonMapping B ON A.RouteId= B.NodeId
				WHERE B.Nodetype=11 AND (A.Dt BETWEEN B.FromDate AND B.ToDate)

				UPDATE A SET A.IsVisited=1 FROM #tmpRoute A INNER JOIN tblVisitMaster B ON A.Dt=B.VisitDate AND A.PersonId=B.SalesPersonId
				UPDATE A SET A.IsVisited=1 FROM #tmpRoute A INNER JOIN tblReasonDetailForNoVisit B ON A.Dt=B.VisitDate AND A.PersonId=B.PersonNodeid WHERE IsVisited=0

				--SELECT * FROM #tmpRoute order by dt
				--SELECT DISTINCT PersonId,Dt,IsVisitEd FROM #tmpRoute WHERE PersonId>0 --and IsVisited=1
				--ORDER BY PersonId,Dt
					
				SELECT DISTINCT PersonId,PersonType INTO #PersonList_NotVisitedAllDay FROM #tmpRoute WHERE PersonId>0 and IsVisited=0
				--SELECT * FROM #PersonList_NotVisitedAllDay
					
				SELECT DISTINCT A.PersonId,A.PersonType INTO #PersonList_VisitedAllDay
				FROM #tmpRoute A LEFT OUTER JOIN #PersonList_NotVisitedAllDay B ON A.PersonId=B.PersonId WHERE A.PersonId>0 and B.PersonId IS NULL
				--SELECT * FROM #PersonList_VisitedAllDay
			END
			ELSE IF @MsrId=2
			BEGIN
				
				--SELECT @IncSlabId
				--SELECT @CalcSequence
				--SELECT * FROM #ApplicableMaterialList

				--WHILE EXISTS(SELECT 1 FROM tblIncentive_SlabRuleDetail WHERE IncSlabID=@IncSlabId AND DependentSlabRuleId IS NULL)
				WHILE @CalcSequence<=@Count
				BEGIN
					TRUNCATE TABLE #BaseDataForMeasure2

					SELECT @IncSlabRuleId=IncSlabRuleId,@MsrId=MsrId,@TimeGranualrityId=TimeGranualrityId,@CalcSequence=CalcSequence,@CutoffVal=CutoffVal,@UomId=UomId, @PayoutAmount=PayoutAmount,@DependentSlabRuleId=DependentSlabRuleId
					FROM tblIncentive_SlabRuleDetail
					WHERE IncSlabID=@IncSlabId AND CalcSequence=@CalcSequence AND DependentSlabRuleId IS NULL

					--SELECT IncSlabRuleId,MsrId,TimeGranualrityId,CalcSequence,CutoffVal,UomId,PayoutAmount,DependentSlabRuleId FROM tblIncentive_SlabRuleDetail
					--WHERE IncSlabID=@IncSlabId AND CalcSequence=@CalcSequence AND DependentSlabRuleId IS NULL

					TRUNCATE TABLE #ApplicableMaterialList

					SELECT @MaterialNodeType=0
					SELECT @MaterialNodeType=MaterialNodeType FROM  tblIncentive_SlabRuleMaterialDetail	WHERE IncSlabRuleId=@IncSlabRuleId

					IF @MaterialNodeType=62
					BEGIN
						INSERT INTO #ApplicableMaterialList(IncSlabRuleId,MaterialNodeId,MaterialNodeType)
						SELECT A.IncSlabRuleId,B.SKUNodeId,B.SKUNodeType
						FROM  tblIncentive_SlabRuleMaterialDetail A INNER JOIN #PrdHier B ON A.MaterialNodeId=B.PrdWeightTypeId
						WHERE A.IncSlabRuleId=@IncSlabRuleId AND A.MaterialNodeType=62
					END
					ELSE-- IF MaterialNodeType=51
					BEGIN
						INSERT INTO #ApplicableMaterialList(IncSlabRuleId,MaterialNodeId,MaterialNodeType)
						SELECT IncSlabRuleId,MaterialNodeId,MaterialNodeType
						FROM  tblIncentive_SlabRuleMaterialDetail
						WHERE IncSlabRuleId=@IncSlabRuleId
					END
					--SELECT * FROM #ApplicableMaterialList
					IF @TimeGranualrityId=1 --once
					BEGIN
						IF EXISTS(SELECT 1 FROM #ApplicableMaterialList)
						BEGIN
							INSERT INTO #BaseDataForMeasure2(VisitId,OrderDate,SalesPersonId,SalesPersonType,StoreId,ProductId,OrderQty,WeekEnding,RptMonthYear)
							SELECT OM.VisitId,OM.OrderDate,OM.SalesPersonId,OM.SalesPersonType,OM.StoreId,OD.ProductId,Od.OrderQty,[dbo].[fncUTLGetWeekEndDate] (OrderDate),CONVERT(VARCHAR(6),OrderDate,112)
							FROm tblOrderMaster OM INNER JOIN tblOrderDetail OD ON OM.OrderId=OD.OrderId
							INNER JOIN #EligibleSalesmanList C ON OM.SalesPersonID=C.PersonId
							INNER JOIN #ApplicableMaterialList ON OD.ProductId=#ApplicableMaterialList.MaterialNodeId
							WHERE ISNULL(OM.OrderStatusID,0)<>3 AND CONVERT(VARCHAR,OM.OrderDate,112)>=CONVERT(VARCHAR,@IncSlabStartDate,112) AND CONVERT(VARCHAR,OM.OrderDate,112)<=CONVERT(VARCHAR,@IncSlabEndDate,112)
						END
						ELSE
						BEGIN
							INSERT INTO #BaseDataForMeasure2(VisitId,OrderDate,SalesPersonId,SalesPersonType,StoreId,ProductId,OrderQty,WeekEnding,RptMonthYear)
							SELECT OM.VisitId,OM.OrderDate,OM.SalesPersonId,OM.SalesPersonType,OM.StoreId,OD.ProductId,Od.OrderQty,[dbo].[fncUTLGetWeekEndDate] (OrderDate),CONVERT(VARCHAR(6),OrderDate,112)
							FROm tblOrderMaster OM INNER JOIN tblOrderDetail OD ON OM.OrderId=OD.OrderId
							INNER JOIN #EligibleSalesmanList C ON OM.SalesPersonID=C.PersonId
							WHERE ISNULL(OM.OrderStatusID,0)<>3 AND CONVERT(VARCHAR,OM.OrderDate,112)>=CONVERT(VARCHAR,@IncSlabStartDate,112) AND CONVERT(VARCHAR,OM.OrderDate,112)<=CONVERT(VARCHAR,@IncSlabEndDate,112)
						END
					END
					ELSE
					BEGIN
						IF EXISTS(SELECT 1 FROM #ApplicableMaterialList)
						BEGIN
							INSERT INTO #BaseDataForMeasure2(VisitId,OrderDate,SalesPersonId,SalesPersonType,StoreId,ProductId,OrderQty,WeekEnding,RptMonthYear)
							SELECT OM.VisitId,OM.OrderDate,OM.SalesPersonId,OM.SalesPersonType,OM.StoreId,OM.ProductId,OM.OrderQty,OM.WeekEnding,Om.RptMonthYear
							FROm #Orders OM INNER JOIN #ApplicableMaterialList ON OM.ProductId=#ApplicableMaterialList.MaterialNodeId
						END
						ELSE
						BEGIN
							INSERT INTO #BaseDataForMeasure2(VisitId,OrderDate,SalesPersonId,SalesPersonType,StoreId,ProductId,OrderQty,WeekEnding,RptMonthYear)
							SELECT OM.VisitId,OM.OrderDate,OM.SalesPersonId,OM.SalesPersonType,OM.StoreId,OM.ProductId,OM.OrderQty,OM.WeekEnding,Om.RptMonthYear
							FROm #Orders OM
						END					
					END

					--SELECT * FROM #BaseDataForMeasure2 ORDER BY OrderDate
				
					IF @TimeGranualrityId=1
					BEGIN
						DELETE A FROM tblPayoutdetail A INNER JOIN #BaseDataForMeasure2 B ON A.PersonNodeId=B.SalesPersonId 
						WHERE IncSlabRuleId=@IncSlabRuleId AND TimeGranualrityId=@TimeGranualrityId AND TimeGranualrityValue=FORMAT(@IncSlabStartDate,'dd-MMM-yy') + ' to ' + FORMAT(@IncSlabEndDate,'dd-MMM-yy')
				
						INSERT INTO tblPayoutdetail(IncSlabRuleId,IncSlabID,PersonNodeId,PersonNodeType,TimeGranualrityId,TimeGranualrityValue,CutoffVal,AchVal,flgPayoutAcheived, PayoutValue)
						SELECT @IncSlabRuleId AS IncSlabRuleId,@IncSlabId AS IncSlabId,SalesPersonId,SalesPersonType,@TimeGranualrityId AS TimeGranualrityId,FORMAT(@IncSlabStartDate,'dd-MMM-yy') + ' to ' + FORMAT(@IncSlabEndDate,'dd-MMM-yy') AS TimeGranualrityValue,@CutoffVal AS CutoffVal,COUNT(DISTINCT StoreId) AS AchVal,CASE WHEN ISNULL(COUNT(DISTINCT StoreId),0)>=ISNULL(@CutoffVal,0) THEN 1 ELSE 0 END AS flgPayoutAcheived, @PayoutAmount AS PayoutAmount
						FROM #BaseDataForMeasure2
						GROUP BY SalesPersonId,SalesPersonType
						ORDER BY SalesPersonId
					END
					ELSE IF @TimeGranualrityId=2
					BEGIN
						DELETE A FROM tblPayoutdetail A INNER JOIN #BaseDataForMeasure2 B ON A.PersonNodeId=B.SalesPersonId AND A.TimeGranualrityValue=CONVERT(VARCHAR,B.OrderDate,112)
						WHERE A.IncSlabRuleId=@IncSlabRuleId AND A.TimeGranualrityId=@TimeGranualrityId AND B.RptMonthYear=@RptMonthYear
				
						INSERT INTO tblPayoutdetail(IncSlabRuleId,IncSlabID,PersonNodeId,PersonNodeType,TimeGranualrityId,TimeGranualrityValue,CutoffVal,AchVal,flgPayoutAcheived, PayoutValue)
						SELECT @IncSlabRuleId AS IncSlabRuleId,@IncSlabId AS IncSlabId,SalesPersonId,SalesPersonType,@TimeGranualrityId AS TimeGranualrityId,CONVERT(VARCHAR,OrderDate,112) AS TimeGranualrityValue,@CutoffVal AS CutoffVal,COUNT(DISTINCT StoreId) AS AchVal,CASE WHEN ISNULL(COUNT(DISTINCT StoreId),0)>=ISNULL(@CutoffVal,0) THEN 1 ELSE 0 END AS flgPayoutAcheived,@PayoutAmount AS PayoutAmount
						FROM #BaseDataForMeasure2
						WHERE RptMonthYear=@RptMonthYear
						GROUP BY SalesPersonId,SalesPersonType,CONVERT(VARCHAR,OrderDate,112)
						ORDER BY SalesPersonId
					END
					ELSE IF @TimeGranualrityId=3
					BEGIN
						DELETE A FROM tblPayoutdetail A INNER JOIN #BaseDataForMeasure2 B ON A.PersonNodeId=B.SalesPersonId 
						WHERE A.IncSlabRuleId=@IncSlabRuleId AND A.TimeGranualrityId=@TimeGranualrityId AND A.TimeGranualrityValue IN(SELECT CONVERT(VARCHAR,WeekEnding,112) FROM #WeekList)

						INSERT INTO tblPayoutdetail(IncSlabRuleId,IncSlabID,PersonNodeId,PersonNodeType,TimeGranualrityId,TimeGranualrityValue,CutoffVal,AchVal,flgPayoutAcheived, PayoutValue)
						SELECT @IncSlabRuleId AS IncSlabRuleId,@IncSlabId AS IncSlabId,SalesPersonId,SalesPersonType,@TimeGranualrityId AS TimeGranualrityId,CONVERT(VARCHAR,#BaseDataForMeasure2.WeekEnding,112) AS TimeGranualrityValue,@CutoffVal AS CutoffVal,COUNT(DISTINCT StoreId) AS AchVal,CASE WHEN ISNULL(COUNT(DISTINCT StoreId),0)>=ISNULL(@CutoffVal,0) THEN 1 ELSE 0 END AS flgPayoutAcheived,@PayoutAmount AS PayoutAmount
						FROM #BaseDataForMeasure2 INNER JOIN #WeekList ON #BaseDataForMeasure2.WeekEnding=#WeekList.WeekEnding
						GROUP BY SalesPersonId,SalesPersonType,CONVERT(VARCHAR,#BaseDataForMeasure2.WeekEnding,112)
						ORDER BY SalesPersonId
					END
					ELSE IF @TimeGranualrityId=4
					BEGIN
						DELETE A FROM tblPayoutdetail A INNER JOIN #BaseDataForMeasure2 B ON A.PersonNodeId=B.SalesPersonId 
						WHERE A.IncSlabRuleId=@IncSlabRuleId AND A.TimeGranualrityId=@TimeGranualrityId AND A.TimeGranualrityValue=@RptMonthYear

						INSERT INTO tblPayoutdetail(IncSlabRuleId,IncSlabID,PersonNodeId,PersonNodeType,TimeGranualrityId,TimeGranualrityValue,CutoffVal,AchVal,flgPayoutAcheived, PayoutValue)
						SELECT @IncSlabRuleId AS IncSlabRuleId,@IncSlabId AS IncSlabId,SalesPersonId,SalesPersonType,@TimeGranualrityId AS TimeGranualrityId,RptMonthYear AS TimeGranualrityValue,@CutoffVal AS CutoffVal,COUNT(DISTINCT StoreId) AS AchVa,CASE WHEN ISNULL(COUNT(DISTINCT StoreId),0)>=ISNULL(@CutoffVal,0) THEN 1 ELSE 0 END AS flgPayoutAcheivedl,@PayoutAmount AS PayoutAmount
						FROM #BaseDataForMeasure2
						WHERE RptMonthYear=@RptMonthYear
						GROUP BY SalesPersonId,SalesPersonType,RptMonthYear
						ORDER BY SalesPersonId
					END

					IF EXISTS(SELECT 1 FROM tblIncentive_SlabRuleDetail WHERE DependentSlabRuleId=@IncSlabRuleId)
					BEGIN
						--SELECT IncSlabRuleId,MsrId,TimeGranualrityId,CalcSequence,CutoffVal,UomId,PayoutAmount,DependentSlabRuleId FROM tblIncentive_SlabRuleDetail
						--WHERE IncSlabID=@IncSlabId AND CalcSequence=@CalcSequence AND DependentSlabRuleId=@IncSlabRuleId

						SELECT @IncSlabRuleId=IncSlabRuleId,@MsrId=MsrId,@TimeGranualrityId=TimeGranualrityId,@CalcSequence=CalcSequence,@CutoffVal=CutoffVal,@UomId=UomId, @PayoutAmount=PayoutAmount,@DependentSlabRuleId=DependentSlabRuleId
						FROM tblIncentive_SlabRuleDetail
						WHERE IncSlabID=@IncSlabId AND CalcSequence=@CalcSequence AND DependentSlabRuleId=@IncSlabRuleId
					
						TRUNCATE TABLE #ApplicableMaterialList
						INSERT INTO #ApplicableMaterialList(IncSlabRuleId,MaterialNodeId,MaterialNodeType)
						SELECT IncSlabRuleId,MaterialNodeId,MaterialNodeType
						FROM  tblIncentive_SlabRuleMaterialDetail
						WHERE IncSlabRuleId=@IncSlabRuleId

						--SELECT * FROM #ApplicableMaterialList
					
						IF @MsrId=6
						BEGIN						
							TRUNCATE TABLE #BaseDataForMeasure6
							TRUNCATE TABLE #LastVisit
							INSERT INTO #LastVisit(SalesPersonId,SalesPersonType,StoreId,LastVisitDate,VisitId)
							SELECT VM.SalesPersonId,VM.SalesPersonType,VM.StoreId,MAX(VM.VisitDate) AS LastVisitDate,0 AS VisitId --INTO #LastVisit
							FROM tblVisitMaster VM INNER JOIN #BaseDataForMeasure2 ON VM.SalesPersonId=#BaseDataForMeasure2.SalesPersonId AND VM.StoreId=#BaseDataForMeasure2.StoreId
							WHERE CONVERT(VARCHAR,VisitDate,112)>=CONVERT(VARCHAR,@IncSlabStartDate,112) AND CONVERT(VARCHAR,VisitDate,112)<=CONVERT(VARCHAR,@IncSlabEndDate,112)
							GROUP BY VM.SalesPersonId,VM.SalesPersonType,VM.StoreId

							UPDATE #LastVisit Set VisitId=VM.VisitId FROM #LastVisit INNER JOIN tblVisitMaster VM ON #LastVisit.SalesPersonId=VM.SalesPersonId AND #LastVisit.SalesPersonType=VM.SalesPersonType AND #LastVisit.StoreId=VM.StoreId AND #LastVisit.LastVisitDate=VM.VisitDate

							--SELECT * FROM #LastVisit ORDER BY LastVisitDate						

							TRUNCATE TABLE #BaseDataForMeasure6

							INSERT INTO #BaseDataForMeasure6(SalesPersonId,SalesPersonType,POSMaterialDetID,StoreId,Visitid,MaterialId,CurrentStockQty,VisitDate,WeekEnding,RptMonthYear)
							SELECT #LastVisit.SalesPersonId,#LastVisit.SalesPersonType,POS.POSMaterialDetID,POS.StoreId,POS.Visitid,POS.MaterialId,POS.CurrentStockQty,#LastVisit.LastVisitDate,[dbo].[fncUTLGetWeekEndDate] (#LastVisit.LastVisitDate),CONVERT(VARCHAR(6),#LastVisit.LastVisitDate,112)
							FROM tblStore_POSMaterialDet POS INNER JOIN #LastVisit ON POS.VisitId=#LastVisit.VisitId
							INNER JOIN #ApplicableMaterialList ON POS.MaterialId=#ApplicableMaterialList.MaterialNodeId
							WHERE POS.CurrentStockQty>0

							--SELECT * FROM #BaseDataForMeasure6

							IF @TimeGranualrityId=1
							BEGIN
								DELETE A FROM tblPayoutdetail A INNER JOIN #BaseDataForMeasure6 B ON A.PersonNodeId=B.SalesPersonId 
								WHERE IncSlabRuleId=@IncSlabRuleId AND TimeGranualrityId=@TimeGranualrityId AND TimeGranualrityValue=FORMAT(@IncSlabStartDate,'dd-MMM-yy') + ' to ' + FORMAT(@IncSlabEndDate,'dd-MMM-yy')
				
								INSERT INTO tblPayoutdetail(IncSlabRuleId,IncSlabID,PersonNodeId,PersonNodeType,TimeGranualrityId,TimeGranualrityValue,CutoffVal,AchVal,flgPayoutAcheived, PayoutValue)
								SELECT @IncSlabRuleId AS IncSlabRuleId,@IncSlabId AS IncSlabId,SalesPersonId,SalesPersonType,@TimeGranualrityId AS TimeGranualrityId,FORMAT(@IncSlabStartDate,'dd-MMM-yy') + ' to ' + FORMAT(@IncSlabEndDate,'dd-MMM-yy') AS TimeGranualrityValue,@CutoffVal AS CutoffVal,SUM(CurrentStockQty) AS AchVal,CASE WHEN ISNULL(SUM(CurrentStockQty),0)>=ISNULL(@CutoffVal,0) THEN 1 ELSE 0 END AS flgPayoutAcheived, @PayoutAmount AS PayoutAmount
								FROM #BaseDataForMeasure6
								GROUP BY SalesPersonId,SalesPersonType
								ORDER BY SalesPersonId
							END
							ELSE IF @TimeGranualrityId=2
							BEGIN
								DELETE A FROM tblPayoutdetail A INNER JOIN #BaseDataForMeasure6 B ON A.PersonNodeId=B.SalesPersonId AND A.TimeGranualrityValue=CONVERT(VARCHAR,B.VisitDate,112)
								WHERE A.IncSlabRuleId=@IncSlabRuleId AND A.TimeGranualrityId=@TimeGranualrityId AND B.RptMonthYear=@RptMonthYear
				
								INSERT INTO tblPayoutdetail(IncSlabRuleId,IncSlabID,PersonNodeId,PersonNodeType,TimeGranualrityId,TimeGranualrityValue,CutoffVal,AchVal,flgPayoutAcheived, PayoutValue)
								SELECT @IncSlabRuleId AS IncSlabRuleId,@IncSlabId AS IncSlabId,SalesPersonId,SalesPersonType,@TimeGranualrityId AS TimeGranualrityId,CONVERT(VARCHAR,VisitDate,112) AS TimeGranualrityValue,@CutoffVal AS CutoffVal,SUM(CurrentStockQty) AS AchVal,CASE WHEN ISNULL(SUM(CurrentStockQty),0)>=ISNULL(@CutoffVal,0) THEN 1 ELSE 0 END AS flgPayoutAcheived,@PayoutAmount AS PayoutAmount
								FROM #BaseDataForMeasure6
								WHERE RptMonthYear=@RptMonthYear
								GROUP BY SalesPersonId,SalesPersonType,CONVERT(VARCHAR,VisitDate,112)
								ORDER BY SalesPersonId
							END
							ELSE IF @TimeGranualrityId=3
							BEGIN
								DELETE A FROM tblPayoutdetail A INNER JOIN #BaseDataForMeasure6 B ON A.PersonNodeId=B.SalesPersonId 
								WHERE A.IncSlabRuleId=@IncSlabRuleId AND A.TimeGranualrityId=@TimeGranualrityId AND A.TimeGranualrityValue IN(SELECT CONVERT(VARCHAR,WeekEnding,112) FROM #WeekList)

								INSERT INTO tblPayoutdetail(IncSlabRuleId,IncSlabID,PersonNodeId,PersonNodeType,TimeGranualrityId,TimeGranualrityValue,CutoffVal,AchVal,flgPayoutAcheived, PayoutValue)
								SELECT @IncSlabRuleId AS IncSlabRuleId,@IncSlabId AS IncSlabId,SalesPersonId,SalesPersonType,@TimeGranualrityId AS TimeGranualrityId,CONVERT(VARCHAR,#BaseDataForMeasure6.WeekEnding,112) AS TimeGranualrityValue,@CutoffVal AS CutoffVal,SUM(CurrentStockQty) AS AchVal,CASE WHEN ISNULL(SUM(CurrentStockQty),0)>=ISNULL(@CutoffVal,0) THEN 1 ELSE 0 END AS flgPayoutAcheived,@PayoutAmount AS PayoutAmount
								FROM #BaseDataForMeasure6 INNER JOIN #WeekList ON #BaseDataForMeasure6.WeekEnding=#WeekList.WeekEnding
								GROUP BY SalesPersonId,SalesPersonType,CONVERT(VARCHAR,#BaseDataForMeasure6.WeekEnding,112)
								ORDER BY SalesPersonId
							END
							ELSE IF @TimeGranualrityId=4
							BEGIN
								DELETE A FROM tblPayoutdetail A INNER JOIN #BaseDataForMeasure6 B ON A.PersonNodeId=B.SalesPersonId 
								WHERE A.IncSlabRuleId=@IncSlabRuleId AND A.TimeGranualrityId=@TimeGranualrityId AND A.TimeGranualrityValue=@RptMonthYear

								INSERT INTO tblPayoutdetail(IncSlabRuleId,IncSlabID,PersonNodeId,PersonNodeType,TimeGranualrityId,TimeGranualrityValue,CutoffVal,AchVal,flgPayoutAcheived, PayoutValue)
								SELECT @IncSlabRuleId AS IncSlabRuleId,@IncSlabId AS IncSlabId,SalesPersonId,SalesPersonType,@TimeGranualrityId AS TimeGranualrityId,RptMonthYear AS TimeGranualrityValue,@CutoffVal AS CutoffVal,SUM(CurrentStockQty) AS AchVa,CASE WHEN ISNULL(SUM(CurrentStockQty),0)>=ISNULL(@CutoffVal,0) THEN 1 ELSE 0 END AS flgPayoutAcheivedl,@PayoutAmount AS PayoutAmount
								FROM #BaseDataForMeasure6
								WHERE RptMonthYear=@RptMonthYear
								GROUP BY SalesPersonId,SalesPersonType,RptMonthYear
								ORDER BY SalesPersonId
							END
						END
					END

					SELECT @CalcSequence +=1
				END

				
			END
			ELSE IF @MsrId=7
			BEGIN
				--SELECT  * FROM #ApplicableMaterialList				
				TRUNCATE TABLE #BaseDataForMeasure7

				IF @TimeGranualrityId=1 --once
				BEGIN
					IF EXISTS(SELECT 1 FROM #ApplicableMaterialList)
					BEGIN
						INSERT INTO #BaseDataForMeasure7(VisitId,OrderDate,SalesPersonId,SalesPersonType,StoreId,ProductId,OrderQty,WeekEnding,RptMonthYear)
						SELECT OM.VisitId,OM.OrderDate,OM.SalesPersonId,OM.SalesPersonType,OM.StoreId,OD.ProductId,Od.OrderQty,[dbo].[fncUTLGetWeekEndDate] (OrderDate),CONVERT(VARCHAR(6),OrderDate,112)
						FROm tblOrderMaster OM INNER JOIN tblOrderDetail OD ON OM.OrderId=OD.OrderId
						INNER JOIN #EligibleSalesmanList C ON OM.SalesPersonID=C.PersonId
						INNER JOIN #ApplicableMaterialList ON OD.ProductId=#ApplicableMaterialList.MaterialNodeId
						WHERE ISNULL(OM.OrderStatusID,0)<>3 AND CONVERT(VARCHAR,OM.OrderDate,112)>=CONVERT(VARCHAR,@IncSlabStartDate,112) AND CONVERT(VARCHAR,OM.OrderDate,112)<=CONVERT(VARCHAR,@IncSlabEndDate,112)

						DELETE #BaseDataForMeasure7 FROM #BaseDataForMeasure7 INNER JOIN
						(SELECT DISTINCT OM.VisitID
						FROm tblOrderMaster OM INNER JOIN tblOrderDetail OD ON OM.OrderId=OD.OrderId
						WHERE ISNULL(OM.OrderStatusID,0)<>3 AND CONVERT(VARCHAR,OM.OrderDate,112)>=CONVERT(VARCHAR,@IncSlabStartDate,112) AND CONVERT(VARCHAR,OM.OrderDate,112)<=CONVERT(VARCHAR,@IncSlabEndDate,112) AND OD.ProductId NOT IN(SELECT MaterialNodeId FROM #ApplicableMaterialList WHERE MaterialNodeType=4)) AA ON #BaseDataForMeasure7.VisitId=AA.VisitID
					END
					ELSE
					BEGIN
						INSERT INTO #BaseDataForMeasure7(VisitId,OrderDate,SalesPersonId,SalesPersonType,StoreId,ProductId,OrderQty,WeekEnding,RptMonthYear)
						SELECT OM.VisitId,OM.OrderDate,OM.SalesPersonId,OM.SalesPersonType,OM.StoreId,OD.ProductId,Od.OrderQty,[dbo].[fncUTLGetWeekEndDate] (OrderDate),CONVERT(VARCHAR(6),OrderDate,112)
						FROm tblOrderMaster OM INNER JOIN tblOrderDetail OD ON OM.OrderId=OD.OrderId
						INNER JOIN #EligibleSalesmanList C ON OM.SalesPersonID=C.PersonId
						WHERE ISNULL(OM.OrderStatusID,0)<>3 AND CONVERT(VARCHAR,OM.OrderDate,112)>=CONVERT(VARCHAR,@IncSlabStartDate,112) AND CONVERT(VARCHAR,OM.OrderDate,112)<=CONVERT(VARCHAR,@IncSlabEndDate,112)
					END
				END
				ELSE
				BEGIN
					IF EXISTS(SELECT 1 FROM #ApplicableMaterialList)
					BEGIN
						INSERT INTO #BaseDataForMeasure7(VisitId,OrderDate,SalesPersonId,SalesPersonType,StoreId,ProductId,OrderQty,WeekEnding,RptMonthYear)
						SELECT OM.VisitId,OM.OrderDate,OM.SalesPersonId,OM.SalesPersonType,OM.StoreId,OM.ProductId,OM.OrderQty,OM.WeekEnding,Om.RptMonthYear
						FROm #Orders OM INNER JOIN #ApplicableMaterialList ON OM.ProductId=#ApplicableMaterialList.MaterialNodeId
						LEFT OUTER JOIN (SELECT DISTINCT VisitId FROM #Orders WHERE ProductId NOT IN(SELECT MaterialNodeId FROM #ApplicableMaterialList WHERE MaterialNodeType=4)) AA ON OM.VisitId=AA.VisitId WHERE AA.VisitId IS NULL
					END
					ELSE
					BEGIN
						INSERT INTO #BaseDataForMeasure7(VisitId,OrderDate,SalesPersonId,SalesPersonType,StoreId,ProductId,OrderQty,WeekEnding,RptMonthYear)
						SELECT OM.VisitId,OM.OrderDate,OM.SalesPersonId,OM.SalesPersonType,OM.StoreId,OM.ProductId,OM.OrderQty,OM.WeekEnding,Om.RptMonthYear
						FROm #Orders OM
					END					
				END
				--SELECT * FROM #BaseDataForMeasure7 ORDER BY OrderDate
				
				IF @TimeGranualrityId=1
				BEGIN
					DELETE A FROM tblPayoutdetail A INNER JOIN #BaseDataForMeasure7 B ON A.PersonNodeId=B.SalesPersonId 
					WHERE IncSlabRuleId=@IncSlabRuleId AND TimeGranualrityId=@TimeGranualrityId AND TimeGranualrityValue=FORMAT(@IncSlabStartDate,'dd-MMM-yy') + ' to ' + FORMAT(@IncSlabEndDate,'dd-MMM-yy')
				
					INSERT INTO tblPayoutdetail(IncSlabRuleId,IncSlabID,PersonNodeId,PersonNodeType,TimeGranualrityId,TimeGranualrityValue,CutoffVal,AchVal,flgPayoutAcheived, PayoutValue)
					SELECT @IncSlabRuleId AS IncSlabRuleId,@IncSlabId AS IncSlabId,SalesPersonId,SalesPersonType,@TimeGranualrityId AS TimeGranualrityId,FORMAT(@IncSlabStartDate,'dd-MMM-yy') + ' to ' + FORMAT(@IncSlabEndDate,'dd-MMM-yy') AS TimeGranualrityValue,@CutoffVal AS CutoffVal,COUNT(DISTINCT StoreId) AS AchVal,CASE WHEN ISNULL(COUNT(DISTINCT StoreId),0)>=ISNULL(@CutoffVal,0) THEN 1 ELSE 0 END AS flgPayoutAcheived, @PayoutAmount AS PayoutAmount
					FROM #BaseDataForMeasure7
					GROUP BY SalesPersonId,SalesPersonType
					ORDER BY SalesPersonId
				END
				ELSE IF @TimeGranualrityId=2
				BEGIN
					DELETE A FROM tblPayoutdetail A INNER JOIN #BaseDataForMeasure7 B ON A.PersonNodeId=B.SalesPersonId AND A.TimeGranualrityValue=CONVERT(VARCHAR,B.OrderDate,112)
					WHERE A.IncSlabRuleId=@IncSlabRuleId AND A.TimeGranualrityId=@TimeGranualrityId AND B.RptMonthYear=@RptMonthYear
				
					INSERT INTO tblPayoutdetail(IncSlabRuleId,IncSlabID,PersonNodeId,PersonNodeType,TimeGranualrityId,TimeGranualrityValue,CutoffVal,AchVal,flgPayoutAcheived, PayoutValue)
					SELECT @IncSlabRuleId AS IncSlabRuleId,@IncSlabId AS IncSlabId,SalesPersonId,SalesPersonType,@TimeGranualrityId AS TimeGranualrityId,CONVERT(VARCHAR,OrderDate,112) AS TimeGranualrityValue,@CutoffVal AS CutoffVal,COUNT(DISTINCT StoreId) AS AchVal,CASE WHEN ISNULL(COUNT(DISTINCT StoreId),0)>=ISNULL(@CutoffVal,0) THEN 1 ELSE 0 END AS flgPayoutAcheived,@PayoutAmount AS PayoutAmount
					FROM #BaseDataForMeasure7
					WHERE RptMonthYear=@RptMonthYear
					GROUP BY SalesPersonId,SalesPersonType,CONVERT(VARCHAR,OrderDate,112)
					ORDER BY SalesPersonId
				END
				ELSE IF @TimeGranualrityId=3
				BEGIN
					DELETE A FROM tblPayoutdetail A INNER JOIN #BaseDataForMeasure7 B ON A.PersonNodeId=B.SalesPersonId 
					WHERE A.IncSlabRuleId=@IncSlabRuleId AND A.TimeGranualrityId=@TimeGranualrityId AND A.TimeGranualrityValue IN(SELECT CONVERT(VARCHAR,WeekEnding,112) FROM #WeekList)

					INSERT INTO tblPayoutdetail(IncSlabRuleId,IncSlabID,PersonNodeId,PersonNodeType,TimeGranualrityId,TimeGranualrityValue,CutoffVal,AchVal,flgPayoutAcheived, PayoutValue)
					SELECT @IncSlabRuleId AS IncSlabRuleId,@IncSlabId AS IncSlabId,SalesPersonId,SalesPersonType,@TimeGranualrityId AS TimeGranualrityId,CONVERT(VARCHAR,#BaseDataForMeasure7.WeekEnding,112) AS TimeGranualrityValue,@CutoffVal AS CutoffVal,COUNT(DISTINCT StoreId) AS AchVal,CASE WHEN ISNULL(COUNT(DISTINCT StoreId),0)>=ISNULL(@CutoffVal,0) THEN 1 ELSE 0 END AS flgPayoutAcheived,@PayoutAmount AS PayoutAmount
					FROM #BaseDataForMeasure7 INNER JOIN #WeekList ON #BaseDataForMeasure7.WeekEnding=#WeekList.WeekEnding
					GROUP BY SalesPersonId,SalesPersonType,CONVERT(VARCHAR,#BaseDataForMeasure7.WeekEnding,112)
					ORDER BY SalesPersonId
				END
				ELSE IF @TimeGranualrityId=4
				BEGIN
					DELETE A FROM tblPayoutdetail A INNER JOIN #BaseDataForMeasure7 B ON A.PersonNodeId=B.SalesPersonId 
					WHERE A.IncSlabRuleId=@IncSlabRuleId AND A.TimeGranualrityId=@TimeGranualrityId AND A.TimeGranualrityValue=@RptMonthYear

					INSERT INTO tblPayoutdetail(IncSlabRuleId,IncSlabID,PersonNodeId,PersonNodeType,TimeGranualrityId,TimeGranualrityValue,CutoffVal,AchVal,flgPayoutAcheived, PayoutValue)
					SELECT @IncSlabRuleId AS IncSlabRuleId,@IncSlabId AS IncSlabId,SalesPersonId,SalesPersonType,@TimeGranualrityId AS TimeGranualrityId,RptMonthYear AS TimeGranualrityValue,@CutoffVal AS CutoffVal,COUNT(DISTINCT StoreId) AS AchVa,CASE WHEN ISNULL(COUNT(DISTINCT StoreId),0)>=ISNULL(@CutoffVal,0) THEN 1 ELSE 0 END AS flgPayoutAcheivedl,@PayoutAmount AS PayoutAmount
					FROM #BaseDataForMeasure7
					WHERE RptMonthYear=@RptMonthYear
					GROUP BY SalesPersonId,SalesPersonType,RptMonthYear
					ORDER BY SalesPersonId
				END
				
			END
			ELSE IF @MsrId=3 -- productive Calls
			BEGIN
				--SELECT  * FROM #ApplicableMaterialList
				
				TRUNCATE TABLE #BaseDataForMeasure3

				IF @TimeGranualrityId=1 --once
				BEGIN
					IF EXISTS(SELECT 1 FROM #ApplicableMaterialList)
					BEGIN
						INSERT INTO #BaseDataForMeasure3(VisitId,OrderDate,SalesPersonId,SalesPersonType,StoreId,ProductId,OrderQty,WeekEnding,RptMonthYear)
						SELECT OM.VisitId,OM.OrderDate,OM.SalesPersonId,OM.SalesPersonType,OM.StoreId,OD.ProductId,Od.OrderQty,[dbo].[fncUTLGetWeekEndDate] (OrderDate),CONVERT(VARCHAR(6),OrderDate,112)
						FROm tblOrderMaster OM INNER JOIN tblOrderDetail OD ON OM.OrderId=OD.OrderId
						INNER JOIN #EligibleSalesmanList C ON OM.SalesPersonID=C.PersonId
						INNER JOIN #ApplicableMaterialList ON OD.ProductId=#ApplicableMaterialList.MaterialNodeId
						WHERE ISNULL(OM.OrderStatusID,0)<>3 AND CONVERT(VARCHAR,OM.OrderDate,112)>=CONVERT(VARCHAR,@IncSlabStartDate,112) AND CONVERT(VARCHAR,OM.OrderDate,112)<=CONVERT(VARCHAR,@IncSlabEndDate,112)
					END
					ELSE
					BEGIN
						INSERT INTO #BaseDataForMeasure3(VisitId,OrderDate,SalesPersonId,SalesPersonType,StoreId,ProductId,OrderQty,WeekEnding,RptMonthYear)
						SELECT OM.VisitId,OM.OrderDate,OM.SalesPersonId,OM.SalesPersonType,OM.StoreId,OD.ProductId,Od.OrderQty,[dbo].[fncUTLGetWeekEndDate] (OrderDate),CONVERT(VARCHAR(6),OrderDate,112)
						FROm tblOrderMaster OM INNER JOIN tblOrderDetail OD ON OM.OrderId=OD.OrderId
						INNER JOIN #EligibleSalesmanList C ON OM.SalesPersonID=C.PersonId
						WHERE ISNULL(OM.OrderStatusID,0)<>3 AND CONVERT(VARCHAR,OM.OrderDate,112)>=CONVERT(VARCHAR,@IncSlabStartDate,112) AND CONVERT(VARCHAR,OM.OrderDate,112)<=CONVERT(VARCHAR,@IncSlabEndDate,112)
					END
				END
				ELSE
				BEGIN
					IF EXISTS(SELECT 1 FROM #ApplicableMaterialList)
					BEGIN
						INSERT INTO #BaseDataForMeasure3(VisitId,OrderDate,SalesPersonId,SalesPersonType,StoreId,ProductId,OrderQty,WeekEnding,RptMonthYear)
						SELECT OM.VisitId,OM.OrderDate,OM.SalesPersonId,OM.SalesPersonType,OM.StoreId,OM.ProductId,OM.OrderQty,OM.WeekEnding,Om.RptMonthYear
						FROm #Orders OM INNER JOIN #ApplicableMaterialList ON OM.ProductId=#ApplicableMaterialList.MaterialNodeId
					END
					ELSE
					BEGIN
						INSERT INTO #BaseDataForMeasure3(VisitId,OrderDate,SalesPersonId,SalesPersonType,StoreId,ProductId,OrderQty,WeekEnding,RptMonthYear)
						SELECT OM.VisitId,OM.OrderDate,OM.SalesPersonId,OM.SalesPersonType,OM.StoreId,OM.ProductId,OM.OrderQty,OM.WeekEnding,Om.RptMonthYear
						FROm #Orders OM
					END					
				END
				--SELECT * FROM #BaseDataForMeasure3 ORDER BY OrderDate
				
				IF @TimeGranualrityId=1
				BEGIN
					DELETE A FROM tblPayoutdetail A INNER JOIN #BaseDataForMeasure3 B ON A.PersonNodeId=B.SalesPersonId 
					WHERE IncSlabRuleId=@IncSlabRuleId AND TimeGranualrityId=@TimeGranualrityId AND TimeGranualrityValue=FORMAT(@IncSlabStartDate,'dd-MMM-yy') + ' to ' + FORMAT(@IncSlabEndDate,'dd-MMM-yy')
				
					INSERT INTO tblPayoutdetail(IncSlabRuleId,IncSlabID,PersonNodeId,PersonNodeType,TimeGranualrityId,TimeGranualrityValue,CutoffVal,AchVal,flgPayoutAcheived, PayoutValue)
					SELECT @IncSlabRuleId AS IncSlabRuleId,@IncSlabId AS IncSlabId,SalesPersonId,SalesPersonType,@TimeGranualrityId AS TimeGranualrityId,FORMAT(@IncSlabStartDate,'dd-MMM-yy') + ' to ' + FORMAT(@IncSlabEndDate,'dd-MMM-yy') AS TimeGranualrityValue,@CutoffVal AS CutoffVal,COUNT(DISTINCT VisitId) AS AchVal,CASE WHEN ISNULL(COUNT(DISTINCT VisitId),0)>=ISNULL(@CutoffVal,0) THEN 1 ELSE 0 END AS flgPayoutAcheived, @PayoutAmount AS PayoutAmount
					FROM #BaseDataForMeasure3
					GROUP BY SalesPersonId,SalesPersonType
					ORDER BY SalesPersonId

					--UPDATE tblPayoutdetail SET flgPayoutAcheived=1 WHERE AchVal>=CutoffVal AND TimeGranualrityId=@TimeGranualrityId AND TimeGranualrityValue=FORMAT(@IncSlabStartDate,'dd-MMM-yy') + ' to ' + FORMAT(@IncSlabEndDate,'dd-MMM-yy')
				END
				ELSE IF @TimeGranualrityId=2
				BEGIN
					DELETE A FROM tblPayoutdetail A INNER JOIN #BaseDataForMeasure3 B ON A.PersonNodeId=B.SalesPersonId AND A.TimeGranualrityValue=CONVERT(VARCHAR,B.OrderDate,112)
					WHERE A.IncSlabRuleId=@IncSlabRuleId AND A.TimeGranualrityId=@TimeGranualrityId AND B.RptMonthYear=@RptMonthYear
				
					INSERT INTO tblPayoutdetail(IncSlabRuleId,IncSlabID,PersonNodeId,PersonNodeType,TimeGranualrityId,TimeGranualrityValue,CutoffVal,AchVal,flgPayoutAcheived, PayoutValue)
					SELECT @IncSlabRuleId AS IncSlabRuleId,@IncSlabId AS IncSlabId,SalesPersonId,SalesPersonType,@TimeGranualrityId AS TimeGranualrityId,CONVERT(VARCHAR,OrderDate,112) AS TimeGranualrityValue,@CutoffVal AS CutoffVal,COUNT(DISTINCT VisitId) AS AchVal,CASE WHEN ISNULL(COUNT(DISTINCT VisitId),0)>=ISNULL(@CutoffVal,0) THEN 1 ELSE 0 END AS flgPayoutAcheived,@PayoutAmount AS PayoutAmount
					FROM #BaseDataForMeasure3
					WHERE RptMonthYear=@RptMonthYear
					GROUP BY SalesPersonId,SalesPersonType,CONVERT(VARCHAR,OrderDate,112)
					ORDER BY SalesPersonId

					--UPDATE tblPayoutdetail SET flgPayoutAcheived=1 WHERE AchVal>=CutoffVal AND TimeGranualrityId=@TimeGranualrityId AND TimeGranualrityValue=@RptMonthYear
				END
				ELSE IF @TimeGranualrityId=3
				BEGIN
					DELETE A FROM tblPayoutdetail A INNER JOIN #BaseDataForMeasure3 B ON A.PersonNodeId=B.SalesPersonId 
					WHERE A.IncSlabRuleId=@IncSlabRuleId AND A.TimeGranualrityId=@TimeGranualrityId AND A.TimeGranualrityValue IN(SELECT CONVERT(VARCHAR,WeekEnding,112) FROM #WeekList)

					INSERT INTO tblPayoutdetail(IncSlabRuleId,IncSlabID,PersonNodeId,PersonNodeType,TimeGranualrityId,TimeGranualrityValue,CutoffVal,AchVal,flgPayoutAcheived, PayoutValue)
					SELECT @IncSlabRuleId AS IncSlabRuleId,@IncSlabId AS IncSlabId,SalesPersonId,SalesPersonType,@TimeGranualrityId AS TimeGranualrityId,CONVERT(VARCHAR,#BaseDataForMeasure3.WeekEnding,112) AS TimeGranualrityValue,@CutoffVal AS CutoffVal,COUNT(DISTINCT VisitId) AS AchVal,CASE WHEN ISNULL(COUNT(DISTINCT VisitId),0)>=ISNULL(@CutoffVal,0) THEN 1 ELSE 0 END AS flgPayoutAcheived,@PayoutAmount AS PayoutAmount
					FROM #BaseDataForMeasure3 INNER JOIN #WeekList ON #BaseDataForMeasure3.WeekEnding=#WeekList.WeekEnding
					GROUP BY SalesPersonId,SalesPersonType,CONVERT(VARCHAR,#BaseDataForMeasure3.WeekEnding,112)
					ORDER BY SalesPersonId

					--UPDATE tblPayoutdetail SET flgPayoutAcheived=1 WHERE AchVal>=CutoffVal AND TimeGranualrityId=@TimeGranualrityId AND TimeGranualrityValue IN(SELECT CONVERT(VARCHAR,WeekEnding,112) FROM #WeekList)
				END
				ELSE IF @TimeGranualrityId=4
				BEGIN
					DELETE A FROM tblPayoutdetail A INNER JOIN #BaseDataForMeasure3 B ON A.PersonNodeId=B.SalesPersonId 
					WHERE A.IncSlabRuleId=@IncSlabRuleId AND A.TimeGranualrityId=@TimeGranualrityId AND A.TimeGranualrityValue=@RptMonthYear

					INSERT INTO tblPayoutdetail(IncSlabRuleId,IncSlabID,PersonNodeId,PersonNodeType,TimeGranualrityId,TimeGranualrityValue,CutoffVal,AchVal,flgPayoutAcheived, PayoutValue)
					SELECT @IncSlabRuleId AS IncSlabRuleId,@IncSlabId AS IncSlabId,SalesPersonId,SalesPersonType,@TimeGranualrityId AS TimeGranualrityId,RptMonthYear AS TimeGranualrityValue,@CutoffVal AS CutoffVal,COUNT(DISTINCT VisitId) AS AchVa,CASE WHEN ISNULL(COUNT(DISTINCT VisitId),0)>=ISNULL(@CutoffVal,0) THEN 1 ELSE 0 END AS flgPayoutAcheivedl,@PayoutAmount AS PayoutAmount
					FROM #BaseDataForMeasure3
					WHERE RptMonthYear=@RptMonthYear
					GROUP BY SalesPersonId,SalesPersonType,RptMonthYear
					ORDER BY SalesPersonId

					--UPDATE tblPayoutdetail SET flgPayoutAcheived=1 WHERE AchVal>=CutoffVal AND TimeGranualrityId=@TimeGranualrityId AND TimeGranualrityValue=@RptMonthYear
				END
				
			END
			ELSE IF @MsrId=4 -- Delivered
			BEGIN
				--SELECT  * FROM #ApplicableMaterialList
				--SELECT * FROM #Invoice
				
				WHILE @CalcSequence<=@Count
				BEGIN
					--SELECT @CalcSequence CalcSequence
					--SELECT @Count Counterval
					TRUNCATE TABLE #BaseDataForMeasure4;

					SELECT @IncSlabRuleId=IncSlabRuleId,@MsrId=MsrId,@TimeGranualrityId=TimeGranualrityId,@CalcSequence=CalcSequence,@CutoffVal=CutoffVal,@UomId=UomId, @PayoutAmount=PayoutAmount,@DependentSlabRuleId=DependentSlabRuleId
					FROM tblIncentive_SlabRuleDetail
					WHERE IncSlabID=@IncSlabId AND CalcSequence=@CalcSequence AND DependentSlabRuleId IS NULL

					----SELECT IncSlabRuleId,MsrId,TimeGranualrityId,CalcSequence,CutoffVal,UomId, PayoutAmount,DependentSlabRuleId
					----FROM tblIncentive_SlabRuleDetail
					----WHERE IncSlabID=@IncSlabId AND CalcSequence=@CalcSequence AND DependentSlabRuleId IS NULL

					TRUNCATE TABLE #ApplicableMaterialList

					SELECT @MaterialNodeType=0
					SELECT @MaterialNodeType=MaterialNodeType FROM  tblIncentive_SlabRuleMaterialDetail	WHERE IncSlabRuleId=@IncSlabRuleId

					IF @MaterialNodeType=62
					BEGIN
						INSERT INTO #ApplicableMaterialList(IncSlabRuleId,MaterialNodeId,MaterialNodeType)
						SELECT A.IncSlabRuleId,B.SKUNodeId,B.SKUNodeType
						FROM  tblIncentive_SlabRuleMaterialDetail A INNER JOIN #PrdHier B ON A.MaterialNodeId=B.PrdWeightTypeId
						WHERE A.IncSlabRuleId=@IncSlabRuleId AND A.MaterialNodeType=62
					END
					ELSE
					BEGIN
						INSERT INTO #ApplicableMaterialList(IncSlabRuleId,MaterialNodeId,MaterialNodeType)
						SELECT IncSlabRuleId,MaterialNodeId,MaterialNodeType
						FROM  tblIncentive_SlabRuleMaterialDetail
						WHERE IncSlabRuleId=@IncSlabRuleId
					END

					--SELECT @IncSlabRuleId IncSlabRuleId
					--SELECT * FROM #ApplicableMaterialList

					--SET @TimeGranualrityId=1
					IF @TimeGranualrityId=1 --once
					BEGIN
						IF EXISTS(SELECT 1 FROM #ApplicableMaterialList)
						BEGIN
							INSERT INTO #BaseDataForMeasure4(OrderDate,SalesPersonId,SalesPersonType,InvQty,InvQtyInCase,WeekEnding,RptMonthYear)
							SELECT OM.OrderDate,OM.SalesPersonId,OM.SalesPersonType,SUM(OD.OrderQty),SUM(OD.OrderQty)/CAST(#PrdHier.CaseSize AS FLOAT),[dbo].[fncUTLGetWeekEndDate] (OM.OrderDate),CONVERT(VARCHAR(6),OM.OrderDate,112)
							FROm tblOrderMaster OM INNER JOIN tblOrderDetail OD ON OM.OrderId=OD.OrderId
							INNER JOIN #EligibleSalesmanList C ON OM.SalesPersonID=C.PersonId
							INNER JOIN #ApplicableMaterialList ON OD.ProductId=#ApplicableMaterialList.MaterialNodeId
							INNER JOIN #PrdHier ON OD.ProductId=#PrdHier.SKUNodeId
							WHERE ISNULL(OM.OrderStatusID,0)<>3 AND CONVERT(VARCHAR,OM.OrderDate,112)>=CONVERT(VARCHAR,@IncSlabStartDate,112) AND CONVERT(VARCHAR,OM.OrderDate,112)<=CONVERT(VARCHAR,@IncSlabEndDate,112)
						END
						ELSE
						BEGIN
							INSERT INTO #BaseDataForMeasure4(OrderDate,SalesPersonId,SalesPersonType,InvQty,InvQtyInCase,WeekEnding,RptMonthYear)
							SELECT OM.OrderDate,OM.SalesPersonId,OM.SalesPersonType,SUM(OD.OrderQty),SUM(OD.OrderQty)/CAST(#PrdHier.CaseSize AS FLOAT),[dbo].[fncUTLGetWeekEndDate] (OM.OrderDate),CONVERT(VARCHAR(6),OM.OrderDate,112)
							FROm tblOrderMaster OM INNER JOIN tblOrderDetail OD ON OM.OrderId=OD.OrderId
							INNER JOIN #EligibleSalesmanList C ON OM.SalesPersonID=C.PersonId
							INNER JOIN #PrdHier ON OD.ProductId=#PrdHier.SKUNodeId
							WHERE ISNULL(OM.OrderStatusID,0)<>3 AND CONVERT(VARCHAR,OM.OrderDate,112)>=CONVERT(VARCHAR,@IncSlabStartDate,112) AND CONVERT(VARCHAR,OM.OrderDate,112)<=CONVERT(VARCHAR,@IncSlabEndDate,112)
						END
					END
					ELSE
					BEGIN
						IF EXISTS(SELECT 1 FROM #ApplicableMaterialList)
						BEGIN
							--SELECT 'Data Insertion'
							INSERT INTO #BaseDataForMeasure4(OrderDate,SalesPersonId,SalesPersonType,InvQty,InvQtyInCase,WeekEnding,RptMonthYear)
							SELECT OM.OrderDate,OM.SalesPersonId,OM.SalesPersonType,SUM(OM.OrderQty),SUM(OM.OrderQtyInCase),OM.WeekEnding,OM.RptMonthYear
							FROm #Orders OM INNER JOIN #ApplicableMaterialList ON OM.ProductId=#ApplicableMaterialList.MaterialNodeId
							GROUP BY OM.OrderDate,OM.SalesPersonId,OM.SalesPersonType,OM.WeekEnding,OM.RptMonthYear
						END
						ELSE
						BEGIN
							INSERT INTO #BaseDataForMeasure4(OrderDate,SalesPersonId,SalesPersonType,InvQty,InvQtyInCase,WeekEnding,RptMonthYear)
							SELECT OM.OrderDate,OM.SalesPersonId,OM.SalesPersonType,SUM(OM.OrderQty),SUM(OM.OrderQtyInCase),OM.WeekEnding,OM.RptMonthYear
							FROm #Orders OM
							GROUP BY OM.OrderDate,OM.SalesPersonId,OM.SalesPersonType,OM.WeekEnding,OM.RptMonthYear
						END					
					END
					--SELECT * FROM #BaseDataForMeasure4 order by SalesPersonId,OrderDate
					--SELECT * FROM #ApplicableMaterialList
					IF @TimeGranualrityId=4
					BEGIN
						UPDATE A SET A.MonthlyAch=CASE @UomId WHEN 1 THEN AA.InvQtyInCase ELSE AA.InvQty END FROM #BaseDataForMeasure4 A INNER JOIN
						(SELECT RptMonthYear,SalesPersonId,SUM(InvQty) InvQty,SUM(InvQtyInCase) InvQtyInCase
						FROM #BaseDataForMeasure4 GROUP BY RptMonthYear,SalesPersonId,SalesPersonType) AA ON A.RptMonthYear=AA.RptMonthYear AND A.SalesPersonId=AA.SalesPersonId

						IF @CalcSequence>1
							UPDATE B SET flgMonthlyAch=1 FROM #BaseDataForMeasure4 B,(SELECT PersonNodeId,PersonNodeType,TimeGranualrityId,TimeGranualrityValue,IncSlabID FROM tblPayoutdetail WHERE SlabSeq=@CalcSequence-1 AND flgPayoutAcheived=0 AND TimeGranualrityId=@TimeGranualrityId AND TimeGranualrityValue=@RptMonthYear) X WHERE X.PersonNodeId=B.SalesPersonId AND X.PersonNodeType=B.SalesPersonType AND  MonthlyAch>=@CutoffVal
						ELSE
							UPDATE #BaseDataForMeasure4 SET flgMonthlyAch=1 WHERE MonthlyAch>=@CutoffVal 

						UPDATE #BaseDataForMeasure4 SET flgMonthlyAch=0 WHERE flgMonthlyAch IS NULL

						DELETE A FROM tblPayoutdetail A INNER JOIN #BaseDataForMeasure4 B ON A.PersonNodeId=B.SalesPersonId 
						WHERE A.IncSlabRuleId=@IncSlabRuleId AND A.TimeGranualrityId=@TimeGranualrityId AND A.TimeGranualrityValue=@RptMonthYear

						INSERT INTO tblPayoutdetail(IncSlabRuleId,IncSlabID,PersonNodeId,PersonNodeType,SlabSeq,TimeGranualrityId,TimeGranualrityValue,CutoffVal,AchVal,flgPayoutAcheived, PayoutValue)
						SELECT DISTINCT @IncSlabRuleId AS IncSlabRuleId,@IncSlabId AS IncSlabId,SalesPersonId,SalesPersonType,@CalcSequence,@TimeGranualrityId AS TimeGranualrityId,RptMonthYear AS TimeGranualrityValue,@CutoffVal AS CutoffVal,MonthlyAch AS AchVal,flgMonthlyAch AS flgPayoutAcheived,@PayoutAmount * MonthlyAch AS PayoutAmount
						FROM #BaseDataForMeasure4
						WHERE RptMonthYear=@RptMonthYear
						ORDER BY SalesPersonId

					END


					-----BEGIN  -- Code NOt Needeed in Raj
					
					------IF @TimeGranualrityId=4
					------BEGIN
					------	UPDATE A SET A.MonthlyAch=CASE @UomId WHEN 16 THEN AA.InvQtyInCase ELSE AA.InvQty END FROM #BaseDataForMeasure4 A INNER JOIN
					------	(SELECT RptMonthYear,SalesPersonId,SUM(InvQty) InvQty,SUM(InvQtyInCase) InvQtyInCase
					------	FROM #BaseDataForMeasure4 GROUP BY RptMonthYear,SalesPersonId,SalesPersonType) AA ON A.RptMonthYear=AA.RptMonthYear AND A.SalesPersonId=AA.SalesPersonId

					------	UPDATE #BaseDataForMeasure4 SET flgMonthlyAch=1 WHERE MonthlyAch>=@CutoffVal
					------	UPDATE #BaseDataForMeasure4 SET flgMonthlyAch=0 WHERE flgMonthlyAch IS NULL

					------	DELETE A FROM tblPayoutdetail A INNER JOIN #BaseDataForMeasure4 B ON A.PersonNodeId=B.SalesPersonId 
					------	WHERE A.IncSlabRuleId=@IncSlabRuleId AND A.TimeGranualrityId=@TimeGranualrityId AND A.TimeGranualrityValue=@RptMonthYear

					------	INSERT INTO tblPayoutdetail(IncSlabRuleId,IncSlabID,PersonNodeId,PersonNodeType,TimeGranualrityId,TimeGranualrityValue,CutoffVal,AchVal,flgPayoutAcheived, PayoutValue)
					------	SELECT DISTINCT @IncSlabRuleId AS IncSlabRuleId,@IncSlabId AS IncSlabId,SalesPersonId,SalesPersonType,@TimeGranualrityId AS TimeGranualrityId,RptMonthYear AS TimeGranualrityValue,@CutoffVal AS CutoffVal,MonthlyAch AS AchVal,flgMonthlyAch AS flgPayoutAcheived,@PayoutAmount AS PayoutAmount
					------	FROM #BaseDataForMeasure4
					------	WHERE RptMonthYear=@RptMonthYear
					------	ORDER BY SalesPersonId

					------END
				
					------IF EXISTS(SELECT 1 FROM tblIncentive_SlabRuleDetail WHERE IncSlabID=@IncSlabId AND TimeGranualrityId=3)
					------BEGIN
					------	SELECT @IncSlabRuleId=IncSlabRuleId,@MsrId=MsrId,@TimeGranualrityId=TimeGranualrityId,@CalcSequence=CalcSequence,@CutoffVal=CutoffVal,@UomId=UomId, @PayoutAmount=PayoutAmount,@DependentSlabRuleId=DependentSlabRuleId
					------	FROM tblIncentive_SlabRuleDetail
					------	WHERE IncSlabID=@IncSlabId AND TimeGranualrityId=3

					------	UPDATE A SET A.WeeklyAch=CASE @UomId WHEN 16 THEN AA.InvQtyInCase ELSE AA.InvQty END FROM #BaseDataForMeasure4 A INNER JOIN
					------	(SELECT WeekEnding,SalesPersonId,SUM(InvQty) InvQty,SUM(InvQtyInCase) InvQtyInCase
					------	FROM #BaseDataForMeasure4 GROUP BY WeekEnding,SalesPersonId,SalesPersonType) AA ON A.WeekEnding=AA.WeekEnding AND A.SalesPersonId=AA.SalesPersonId
					------	--SELECT @CutoffVal AS CutoffVal
					------	--SELECT @PayoutAmount AS PayoutAmount

					------	UPDATE #BaseDataForMeasure4 SET flgWeeklyAch=1 WHERE WeeklyAch>=@CutoffVal AND flgMonthlyAch<>1
					------	UPDATE #BaseDataForMeasure4 SET flgWeeklyAch=0 WHERE flgWeeklyAch IS NULL

					------	DELETE A FROM tblPayoutdetail A INNER JOIN #BaseDataForMeasure4 B ON A.PersonNodeId=B.SalesPersonId 
					------	WHERE A.IncSlabRuleId=@IncSlabRuleId AND A.TimeGranualrityId=@TimeGranualrityId AND A.TimeGranualrityValue IN(SELECT CONVERT(VARCHAR,WeekEnding,112) FROM #WeekList)

					------	INSERT INTO tblPayoutdetail(IncSlabRuleId,IncSlabID,PersonNodeId,PersonNodeType,TimeGranualrityId,TimeGranualrityValue,CutoffVal,AchVal,flgPayoutAcheived, PayoutValue)
					------	SELECT DISTINCT @IncSlabRuleId AS IncSlabRuleId,@IncSlabId AS IncSlabId,SalesPersonId,SalesPersonType,@TimeGranualrityId AS TimeGranualrityId,CONVERT(VARCHAR,#BaseDataForMeasure4.WeekEnding,112) AS TimeGranualrityValue,@CutoffVal AS CutoffVal,WeeklyAch AS AchVal,flgWeeklyAch AS flgPayoutAcheived,@PayoutAmount AS PayoutAmount
					------	FROM #BaseDataForMeasure4 INNER JOIN #WeekList ON #BaseDataForMeasure4.WeekEnding=#WeekList.WeekEnding
					------	--WHERE RptMonthYear=@RptMonthYear
					------	ORDER BY SalesPersonId
					------END

					------IF EXISTS(SELECT 1 FROM tblIncentive_SlabRuleDetail WHERE IncSlabID=@IncSlabId AND TimeGranualrityId=2)
					------BEGIN
					------	SELECT @IncSlabRuleId=IncSlabRuleId,@MsrId=MsrId,@TimeGranualrityId=TimeGranualrityId,@CalcSequence=CalcSequence,@CutoffVal=CutoffVal,@UomId=UomId, @PayoutAmount=PayoutAmount,@DependentSlabRuleId=DependentSlabRuleId
					------	FROM tblIncentive_SlabRuleDetail
					------	WHERE IncSlabID=@IncSlabId AND TimeGranualrityId=2
										
					------	--SELECT @CutoffVal AS CutoffVal
					------	--SELECT @PayoutAmount AS PayoutAmount
					------	UPDATE #BaseDataForMeasure4 SET flgDailyAch=1 WHERE InvQty>=@CutoffVal AND (flgMonthlyAch=0 AND flgWeeklyAch=0)
					------	UPDATE #BaseDataForMeasure4 SET flgDailyAch=0 WHERE flgDailyAch IS NULL

					------	DELETE A FROM tblPayoutdetail A INNER JOIN #BaseDataForMeasure4 B ON A.PersonNodeId=B.SalesPersonId AND A.TimeGranualrityValue=CONVERT(VARCHAR,B.OrderDate,112)
					------	WHERE A.IncSlabRuleId=@IncSlabRuleId AND A.TimeGranualrityId=@TimeGranualrityId AND B.RptMonthYear=@RptMonthYear

					------	INSERT INTO tblPayoutdetail(IncSlabRuleId,IncSlabID,PersonNodeId,PersonNodeType,TimeGranualrityId,TimeGranualrityValue,CutoffVal,AchVal,flgPayoutAcheived, PayoutValue)
					------	SELECT DISTINCT @IncSlabRuleId AS IncSlabRuleId,@IncSlabId AS IncSlabId,SalesPersonId,SalesPersonType,@TimeGranualrityId AS TimeGranualrityId,CONVERT(VARCHAR,#BaseDataForMeasure4.OrderDate,112) AS TimeGranualrityValue,@CutoffVal AS CutoffVal,InvQty AS AchVal,flgDailyAch AS flgPayoutAcheived,@PayoutAmount AS PayoutAmount
					------	FROM #BaseDataForMeasure4
					------	WHERE RptMonthYear=@RptMonthYear
					------	ORDER BY SalesPersonId

					------END
					
					------END
					SELECT @CalcSequence +=1
				END
				--SELECT * FROM #BaseDataForMeasure4 ORDER BY SalesPersonId,OrderDate				
			END
			ELSE IF @MsrId=5 -- Primary Sales
			BEGIN
				--SELECT  * FROM #ApplicableMaterialList
				
				TRUNCATE TABLE #BaseDataForMeasure5

				IF @TimeGranualrityId=1 --once
				BEGIN
					IF EXISTS(SELECT 1 FROM #ApplicableMaterialList)
					BEGIN
						INSERT INTO #BaseDataForMeasure5(VisitId,OrderDate,SalesPersonId,SalesPersonType,StoreId,ProductId,OrderQty,OrderQtyInCase,CaseSize,WeekEnding,RptMonthYear)
						SELECT OM.VisitId,OM.OrderDate,OM.SalesPersonId,OM.SalesPersonType,OM.StoreId,OD.ProductId,OD.OrderQty,OD.OrderQty/CAST(#PrdHier.CaseSize AS FLOAT),#PrdHier.CaseSize,[dbo].[fncUTLGetWeekEndDate] (OrderDate),CONVERT(VARCHAR(6),OrderDate,112)
						FROm tblOrderMaster OM INNER JOIN tblOrderDetail OD ON OM.OrderId=OD.OrderId
						INNER JOIN #EligibleSalesmanList C ON OM.SalesPersonID=C.PersonId
						INNER JOIN #ApplicableMaterialList ON OD.ProductId=#ApplicableMaterialList.MaterialNodeId
						INNER JOIN #PrdHier ON OD.ProductId=#PrdHier.SKUNodeId
						WHERE ISNULL(OM.OrderStatusID,0)<>3 AND CONVERT(VARCHAR,OM.OrderDate,112)>=CONVERT(VARCHAR,@IncSlabStartDate,112) AND CONVERT(VARCHAR,OM.OrderDate,112)<=CONVERT(VARCHAR,@IncSlabEndDate,112)
					END
					ELSE
					BEGIN
						INSERT INTO #BaseDataForMeasure5(VisitId,OrderDate,SalesPersonId,SalesPersonType,StoreId,ProductId,OrderQty,OrderQtyInCase,CaseSize,WeekEnding,RptMonthYear)
						SELECT OM.VisitId,OM.OrderDate,OM.SalesPersonId,OM.SalesPersonType,OM.StoreId,OD.ProductId,Od.OrderQty,OD.OrderQty/CAST(#PrdHier.CaseSize AS FLOAT),#PrdHier.CaseSize,[dbo].[fncUTLGetWeekEndDate] (OrderDate),CONVERT(VARCHAR(6),OrderDate,112)
						FROm tblOrderMaster OM INNER JOIN tblOrderDetail OD ON OM.OrderId=OD.OrderId
						INNER JOIN #EligibleSalesmanList C ON OM.SalesPersonID=C.PersonId
						INNER JOIN #PrdHier ON OD.ProductId=#PrdHier.SKUNodeId
						WHERE ISNULL(OM.OrderStatusID,0)<>3 AND CONVERT(VARCHAR,OM.OrderDate,112)>=CONVERT(VARCHAR,@IncSlabStartDate,112) AND CONVERT(VARCHAR,OM.OrderDate,112)<=CONVERT(VARCHAR,@IncSlabEndDate,112)
					END
				END
				ELSE
				BEGIN
					IF EXISTS(SELECT 1 FROM #ApplicableMaterialList)
					BEGIN
						INSERT INTO #BaseDataForMeasure5(VisitId,OrderDate,SalesPersonId,SalesPersonType,StoreId,ProductId,OrderQty,OrderQtyInCase,CaseSize,WeekEnding,RptMonthYear)
						SELECT OM.VisitId,OM.OrderDate,OM.SalesPersonId,OM.SalesPersonType,OM.StoreId,OM.ProductId,OM.OrderQty,OM.OrderQty/CAST(CaseSize AS FLOAT),OM.CaseSize,OM.WeekEnding,Om.RptMonthYear
						FROm #Orders OM INNER JOIN #ApplicableMaterialList ON OM.ProductId=#ApplicableMaterialList.MaterialNodeId
					END
					ELSE
					BEGIN
						INSERT INTO #BaseDataForMeasure5(VisitId,OrderDate,SalesPersonId,SalesPersonType,StoreId,ProductId,OrderQty,OrderQtyInCase,CaseSize,WeekEnding,RptMonthYear)
						SELECT OM.VisitId,OM.OrderDate,OM.SalesPersonId,OM.SalesPersonType,OM.StoreId,OM.ProductId,OM.OrderQty,OM.OrderQty/CAST(CaseSize AS FLOAT),OM.CaseSize,OM.WeekEnding,Om.RptMonthYear
						FROm #Orders OM
					END					
				END
				--SELECT * FROM #BaseDataForMeasure5 ORDER BY OrderDate
				
				IF @TimeGranualrityId=1
				BEGIN
					DELETE A FROM tblPayoutdetail A INNER JOIN #BaseDataForMeasure5 B ON A.PersonNodeId=B.SalesPersonId 
					WHERE IncSlabRuleId=@IncSlabRuleId AND TimeGranualrityId=@TimeGranualrityId AND TimeGranualrityValue=FORMAT(@IncSlabStartDate,'dd-MMM-yy') + ' to ' + FORMAT(@IncSlabEndDate,'dd-MMM-yy')
				
					INSERT INTO tblPayoutdetail(IncSlabRuleId,IncSlabID,PersonNodeId,PersonNodeType,TimeGranualrityId,TimeGranualrityValue,CutoffVal,AchVal,flgPayoutAcheived, PayoutValue)
					SELECT @IncSlabRuleId AS IncSlabRuleId,@IncSlabId AS IncSlabId,SalesPersonId,SalesPersonType,@TimeGranualrityId AS TimeGranualrityId,FORMAT(@IncSlabStartDate,'dd-MMM-yy') + ' to ' + FORMAT(@IncSlabEndDate,'dd-MMM-yy') AS TimeGranualrityValue,@CutoffVal AS CutoffVal,CASE @UomId WHEN 16 THEN SUM(OrderQty)/CAST(MAX(CaseSize) AS FLOAT) ELSE SUM(OrderQty) END AS AchVal,CASE WHEN @UomId=16 AND ISNULL(SUM(OrderQty)/CAST(MAX(CaseSize) AS FLOAT),0)>=ISNULL(@CutoffVal,0) THEN 1 WHEN @UomId<>16 AND ISNULL(SUM(OrderQty),0)>=ISNULL(@CutoffVal,0) THEN 1 ELSE 0 END AS flgPayoutAcheived, @PayoutAmount AS PayoutAmount
					FROM #BaseDataForMeasure5
					GROUP BY SalesPersonId,SalesPersonType
					ORDER BY SalesPersonId
				END
				ELSE IF @TimeGranualrityId=2
				BEGIN
					DELETE A FROM tblPayoutdetail A INNER JOIN #BaseDataForMeasure5 B ON A.PersonNodeId=B.SalesPersonId AND A.TimeGranualrityValue=CONVERT(VARCHAR,B.OrderDate,112)
					WHERE A.IncSlabRuleId=@IncSlabRuleId AND A.TimeGranualrityId=@TimeGranualrityId AND B.RptMonthYear=@RptMonthYear
				
					INSERT INTO tblPayoutdetail(IncSlabRuleId,IncSlabID,PersonNodeId,PersonNodeType,TimeGranualrityId,TimeGranualrityValue,CutoffVal,AchVal,flgPayoutAcheived, PayoutValue)
					SELECT @IncSlabRuleId AS IncSlabRuleId,@IncSlabId AS IncSlabId,SalesPersonId,SalesPersonType,@TimeGranualrityId AS TimeGranualrityId,CONVERT(VARCHAR,OrderDate,112) AS TimeGranualrityValue,@CutoffVal AS CutoffVal,CASE @UomId WHEN 16 THEN SUM(OrderQty)/CAST(MAX(CaseSize) AS FLOAT) ELSE SUM(OrderQty) END AS AchVal,CASE WHEN @UomId=16 AND ISNULL(SUM(OrderQty)/CAST(MAX(CaseSize) AS FLOAT),0)>=ISNULL(@CutoffVal,0) THEN 1 WHEN @UomId<>16 AND ISNULL(SUM(OrderQty),0)>=ISNULL(@CutoffVal,0) THEN 1 ELSE 0 END AS flgPayoutAcheived,@PayoutAmount AS PayoutAmount
					FROM #BaseDataForMeasure5
					WHERE RptMonthYear=@RptMonthYear
					GROUP BY SalesPersonId,SalesPersonType,CONVERT(VARCHAR,OrderDate,112)
					ORDER BY SalesPersonId
				END
				ELSE IF @TimeGranualrityId=3
				BEGIN
					DELETE A FROM tblPayoutdetail A INNER JOIN #BaseDataForMeasure5 B ON A.PersonNodeId=B.SalesPersonId 
					WHERE A.IncSlabRuleId=@IncSlabRuleId AND A.TimeGranualrityId=@TimeGranualrityId AND A.TimeGranualrityValue IN(SELECT CONVERT(VARCHAR,WeekEnding,112) FROM #WeekList)

					INSERT INTO tblPayoutdetail(IncSlabRuleId,IncSlabID,PersonNodeId,PersonNodeType,TimeGranualrityId,TimeGranualrityValue,CutoffVal,AchVal,flgPayoutAcheived, PayoutValue)
					SELECT @IncSlabRuleId AS IncSlabRuleId,@IncSlabId AS IncSlabId,SalesPersonId,SalesPersonType,@TimeGranualrityId AS TimeGranualrityId,CONVERT(VARCHAR,#BaseDataForMeasure5.WeekEnding,112) AS TimeGranualrityValue,@CutoffVal AS CutoffVal,CASE @UomId WHEN 16 THEN SUM(OrderQty)/CAST(MAX(CaseSize) AS FLOAT) ELSE SUM(OrderQty) END AS AchVal,CASE WHEN @UomId=16 AND ISNULL(SUM(OrderQty)/CAST(MAX(CaseSize) AS FLOAT),0)>=ISNULL(@CutoffVal,0) THEN 1 WHEN @UomId<>16 AND ISNULL(SUM(OrderQty),0)>=ISNULL(@CutoffVal,0) THEN 1 ELSE 0 END AS flgPayoutAcheived,@PayoutAmount AS PayoutAmount
					FROM #BaseDataForMeasure5 INNER JOIN #WeekList ON #BaseDataForMeasure5.WeekEnding=#WeekList.WeekEnding
					GROUP BY SalesPersonId,SalesPersonType,CONVERT(VARCHAR,#BaseDataForMeasure5.WeekEnding,112)
					ORDER BY SalesPersonId
				END
				ELSE IF @TimeGranualrityId=4
				BEGIN
					DELETE A FROM tblPayoutdetail A INNER JOIN #BaseDataForMeasure5 B ON A.PersonNodeId=B.SalesPersonId 
					WHERE A.IncSlabRuleId=@IncSlabRuleId AND A.TimeGranualrityId=@TimeGranualrityId AND A.TimeGranualrityValue=@RptMonthYear

					INSERT INTO tblPayoutdetail(IncSlabRuleId,IncSlabID,PersonNodeId,PersonNodeType,TimeGranualrityId,TimeGranualrityValue,CutoffVal,AchVal,flgPayoutAcheived, PayoutValue)
					SELECT @IncSlabRuleId AS IncSlabRuleId,@IncSlabId AS IncSlabId,SalesPersonId,SalesPersonType,@TimeGranualrityId AS TimeGranualrityId,RptMonthYear AS TimeGranualrityValue,@CutoffVal AS CutoffVal,CASE @UomId WHEN 16 THEN SUM(OrderQty)/CAST(MAX(CaseSize) AS FLOAT) ELSE SUM(OrderQty) END AS AchVal,CASE WHEN @UomId=16 AND ISNULL(SUM(OrderQty)/CAST(MAX(CaseSize) AS FLOAT),0)>=ISNULL(@CutoffVal,0) THEN 1 WHEN @UomId<>16 AND ISNULL(SUM(OrderQty),0)>=ISNULL(@CutoffVal,0) THEN 1 ELSE 0 END AS flgPayoutAcheived,@PayoutAmount AS PayoutAmount
					FROM #BaseDataForMeasure5
					WHERE RptMonthYear=@RptMonthYear
					GROUP BY SalesPersonId,SalesPersonType,RptMonthYear
					ORDER BY SalesPersonId

					--SELECT @IncSlabRuleId AS IncSlabRuleId,@IncSlabId AS IncSlabId,SalesPersonId,SalesPersonType,@TimeGranualrityId AS TimeGranualrityId,RptMonthYear AS TimeGranualrityValue,@CutoffVal AS CutoffVal,CASE @UomId WHEN 16 THEN SUM(OrderQtyInCase) ELSE SUM(OrderQty) END AS AchVal,CASE WHEN @UomId=16 AND ISNULL(SUM(OrderQtyInCase),0)>=ISNULL(@CutoffVal,0) THEN 1 WHEN @UomId<>16 AND ISNULL(SUM(OrderQty),0)>=ISNULL(@CutoffVal,0) THEN 1 ELSE 0 END AS flgPayoutAcheived,@PayoutAmount AS PayoutAmount
					--FROM #BaseDataForMeasure5
					--WHERE RptMonthYear=@RptMonthYear
					--GROUP BY SalesPersonId,SalesPersonType,RptMonthYear
					--ORDER BY SalesPersonId
				END
				
			END
			--	FETCH NEXT FROM @cur_IncSlabRuleList INTO @IncSlabRuleId,@MsrId,@TimeGranualrityId,@CalcSequence,@CutoffVal,@UomId,@PayoutAmount,@DependentSlabRuleId
			--END
			--DEALLOCATE @cur_IncSlabRuleList

			IF @IncId=100
			BEGIN
				DELETE A FROM tblPayoutdetail A INNER JOIN #PersonList_VisitedAllDay B ON A.PersonNodeId=B.PersonId 
				WHERE TimeGranualrityId=@TimeGranualrityId AND TimeGranualrityValue=@RptMonthYear
				DELETE A FROM tblPayoutdetail A INNER JOIN #PersonList_NotVisitedAllDay B ON A.PersonNodeId=B.PersonId
				WHERE TimeGranualrityId=@TimeGranualrityId AND TimeGranualrityValue=@RptMonthYear

				INSERT INTO tblPayoutdetail(IncSlabRuleId,IncSlabID,PersonNodeId,PersonNodeType,flgattendenceRule,TimeGranualrityId,TimeGranualrityValue,PayoutValue)
				SELECT @IncSlabRuleId,@IncSlabId,PersonId,PersonType,1,@TimeGranualrityId,@RptMonthYear,0
				FROM #PersonList_VisitedAllDay A 

				INSERT INTO tblPayoutdetail(IncSlabRuleId,IncSlabID,PersonNodeId,PersonNodeType,flgattendenceRule,TimeGranualrityId,TimeGranualrityValue,PayoutValue)
				SELECT @IncSlabRuleId,@IncSlabId,PersonId,PersonType,0,@TimeGranualrityId,@RptMonthYear,0
				FROM #PersonList_NotVisitedAllDay
			END
			FETCH NEXT FROM @cur_IncSlabList INTO @IncSlabId,@IncSlabStartDate, @IncSlabEndDate,@strSlabRule
		END
		DEALLOCATE @cur_IncSlabList

		FETCH NEXT FROM @cur_IncList INTO @IncId,@IncStartDate, @IncEndDate
	END
		DEALLOCATE @cur_IncList

		PRINT 'G'
		PRINT CONVERT(VARCHAR,GETDATE(),109)

		SELECT R.IncSlabRuleID,R.IncSlabID,S.IncId,R.DependentSlabRuleId INTO #tmpslabRuleList
		FROM tblIncentive_SlabRuleDetail R INNER JOIN tblIncentive_SlabMaster S On R.IncSlabID=S.IncSlabID
		INNER JOIN #IncentiveList I ON S.IncId=I.IncId
		WHERE CONVERT(VARCHAR(6),FromDate,112)<=@RptMonthYear AND CONVERT(VARCHAR(6),ToDate,112)>=@RptMonthYear

		--SELECT * FROM #tmpslabRuleList

		PRINT 'H'
		PRINT CONVERT(VARCHAR,GETDATE(),109)

		DELETE A FROM tblPayoutMaster A INNER JOIN (SELECT DISTINCT P.PersonNodeId,P.TimeGranualrityId,P.TimeGranualrityValue FROM tblPayoutdetail P INNER JOIN #tmpslabRuleList T ON P.IncSlabRuleId=T.IncSlabRuleID AND P.IncSlabID=T.IncSlabID) AA ON A.PersonNodeId=AA.PersonNodeId AND A.TimeGranualrityId=AA.TimeGranualrityId AND A.TimeGranualrityValue=AA.TimeGranualrityValue
		WHERE A.PersonNodeId=@PersonNodeId

		PRINT 'I'
		PRINT CONVERT(VARCHAR,GETDATE(),109)

		INSERT INTO tblPayoutMaster(PersonNodeId,PersonNodeType,TimeGranualrityId,TimeGranualrityValue,PayoutValue)
		SELECT P.PersonNodeId,P.PersonNodeType,P.TimeGranualrityId,P.TimeGranualrityValue,SUM(P.PayoutValue) PayoutValue
		FROM tblPayoutdetail P INNER JOIN #tmpslabRuleList T ON P.IncSlabRuleId=T.IncSlabRuleID AND P.IncSlabID=T.IncSlabID
		WHERE P.flgPayoutAcheived=1 AND T.DependentSlabRuleId IS NULL AND P.PersonNodeId=@PersonNodeId
		GROUP BY P.PersonNodeId,P.PersonNodeType,P.TimeGranualrityId,P.TimeGranualrityValue

		INSERT INTO tblPayoutMaster(PersonNodeId,PersonNodeType,TimeGranualrityId,TimeGranualrityValue,PayoutValue)
		SELECT P.PersonNodeId,P.PersonNodeType,P.TimeGranualrityId,P.TimeGranualrityValue,SUM(P.PayoutValue) PayoutValue
		FROM tblPayoutDetail P INNER JOIN #tmpslabRuleList PT ON P.IncSlabRuleId=PT.IncSlabRuleID AND P.IncSlabID=PT.IncSlabID INNER JOIN 
		tblPayoutDetail DP ON DP.PersonNodeId=P.PersonNodeId AND DP.PersonNodeType=P.PersonNodeType AND DP.TimeGranualrityId=P.TimeGranualrityId AND DP.TimeGranualrityValue=P.TimeGranualrityValue INNER JOIN #tmpslabRuleList T ON DP.IncSlabRuleId=T.IncSlabRuleID AND DP.IncSlabID=T.IncSlabID ,
		(SELECT S.IncSlabRuleID,X.Items DependentIncSlabRuleID FROM tblIncentive_SlabRuleDetail S CROSS APPLY dbo.Split(DependentSlabRuleStr,'|') X WHERE S.DependentSlabRuleStr IS NOT NULL )  D WHERE D.DependentIncSlabRuleID=DP.IncSlabRuleId AND DP.flgPayoutAcheived=1 AND PT.DependentSlabRuleId IS NOT NULL AND P.PersonNodeId=@PersonNodeId
		GROUP BY P.PersonNodeId,P.PersonNodeType,P.TimeGranualrityId,P.TimeGranualrityValue

		----INSERT INTO tblPayoutMaster(PersonNodeId,PersonNodeType,TimeGranualrityId,TimeGranualrityValue,PayoutValue)
		----SELECT P.PersonNodeId,P.PersonNodeType,P.TimeGranualrityId,P.TimeGranualrityValue,SUM(P.PayoutValue) PayoutValue
		----FROM tblPayoutdetail P INNER JOIN #tmpslabRuleList T ON P.IncSlabRuleId=T.IncSlabRuleID AND P.IncSlabID=T.IncSlabID
		----WHERE P.flgPayoutAcheived=1 AND T.DependentSlabRuleId IS NULL AND T.IncSlabRuleID NOT IN(SELECT DISTINCT DependentSlabRuleId FROM #tmpslabRuleList WHERE DependentSlabRuleId IS NOT NULL) AND P.PersonNodeId=@PersonNodeId
		----GROUP BY P.PersonNodeId,P.PersonNodeType,P.TimeGranualrityId,P.TimeGranualrityValue

		----PRINT 'J'
		----PRINT CONVERT(VARCHAR,GETDATE(),109)

		----SELECT P.PersonNodeId,P.PersonNodeType,P.TimeGranualrityId,P.TimeGranualrityValue,SUM(P.PayoutValue) PayoutValue INTO #dependentSlab
		----FROM tblPayoutdetail P INNER JOIN #tmpslabRuleList T ON P.IncSlabRuleId=T.IncSlabRuleID AND P.IncSlabID=T.IncSlabID
		----WHERE P.flgPayoutAcheived=1 AND T.DependentSlabRuleId IS NOT NULL AND P.PersonNodeId=@PersonNodeId --AND T.IncSlabRuleID NOT IN(SELECT DISTINCT DependentSlabRuleId FROM #tmpslabRuleList WHERE DependentSlabRuleId IS NOT NULL)
		----GROUP BY P.PersonNodeId,P.PersonNodeType,P.TimeGranualrityId,P.TimeGranualrityValue

		----PRINT 'K'
		----PRINT CONVERT(VARCHAR,GETDATE(),109)

		----INSERT INTO tblPayoutMaster(PersonNodeId,PersonNodeType,TimeGranualrityId,TimeGranualrityValue,PayoutValue)
		----SELECT P.PersonNodeId,P.PersonNodeType,P.TimeGranualrityId,P.TimeGranualrityValue,SUM(P.PayoutValue) PayoutValue
		----FROM tblPayoutdetail P INNER JOIN #tmpslabRuleList T ON P.IncSlabRuleId=T.IncSlabRuleID AND P.IncSlabID=T.IncSlabID
		----INNER JOIN #dependentSlab D ON P.PersonNodeId=D.PersonNodeId AND P.PersonNodeType=D.PersonNodeType AND P.TimeGranualrityId=D.TimeGranualrityId AND P.TimeGranualrityValue=D.TimeGranualrityValue
		----WHERE P.flgPayoutAcheived=1 AND T.DependentSlabRuleId IS NULL AND T.IncSlabRuleID IN(SELECT DISTINCT DependentSlabRuleId FROM #tmpslabRuleList WHERE DependentSlabRuleId IS NOT NULL) AND P.PersonNodeId=@PersonNodeId
		----GROUP BY P.PersonNodeId,P.PersonNodeType,P.TimeGranualrityId,P.TimeGranualrityValue
	END
END
