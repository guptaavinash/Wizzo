

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
--exec spPDAGetIncentiveSummary @strDate='20-Jul-2018',@IMENumber='358958066686533'
--[spPDAGetIncentiveSummary]'26-Jul-2018','866460037433264'
CREATE PROCEDURE [dbo].[spPDAGetIncentiveSummary]
@strDate VARCHAR(20), 
@IMENumber VARCHAR(100)
AS
BEGIN
	DECLARE @Date DATE
	DECLARE @PersonID INT  
	DECLARE @PersonType INT  
	DECLARE @PDAID INT=0

	DECLARE @IncId INT
	DECLARE @IncStartDate DATE
	DECLARE @IncEndDate DATE
	DECLARE @IncSlabId INT
	DECLARE @IncSlabStartDate DATE
	DECLARE @IncSlabEndDate DATE
	DECLARE @strSlabRule VARCHAR(100)=''
	DECLARE @cur_IncList CURSOR
	DECLARE @cur_IncSlabList CURSOR
	DECLARE @cur_IncSlabRuleList CURSOR
	DECLARE @IncSlabRuleId INT
	DECLARE @MsrId INT
	DECLARE @TimeGranualrityId INT
	DECLARE @CalcSequence INT
	DECLARE @CutoffVal INT
	DECLARE @UomId INT
	DECLARE @PayoutAmount FLOAT
	DECLARE @DependentSlabRuleId INT
	DECLARE @WeekEnding DATE
	DECLARE @RptMonthYear INT
	DECLARE @TimeGranualrityValue VARCHAR(50)=''
	DECLARE @TimePeriod VARCHAR(50)=''
	DECLARE @MonthName VARCHAR(20)=''
	DECLARE @Counter INT=0
	Select @Date = REPLACE(CONVERT(VARCHAR, convert(datetime,@strDate,105), 106),' ','-')   
	--Select @Date = GETDATE()
	PRINT '@Date=' + CAST(@Date AS VARCHAR)  
	SELECT @MonthName=LEFT(DATENAME(m,@Date),3)
	--SELECT @MonthName
	SELECT @WeekEnding=[dbo].[fncUTLGetWeekEndDate] (@Date)
	SELECT @RptMonthYear=CONVERT(VARCHAR(6),@Date,112)
	--SELECT @WeekEnding
	--SELECt @RptMonthYear

	CREATE TABLE #RoutesForPerson (RouteID INT,RouteNodeType TINYINT)

	--SELECT @PDAID=PDAID FROM [dbo].[tblPDAMaster] WHERE [PDA_IMEI]=@IMENumber OR [PDA_IMEI_Sec]=@IMENumber  
	--PRINT '@PDAID=' + CAST(@PDAID AS VARCHAR)

	-- IF @PDAID>0  
	--BEGIN  
	--	SELECT @PersonID=PersonID, @PersonType=[PersonType] 
	--	FROM [dbo].[tblPDA_UserMapMaster] WHERE PDAID=@PDAID  AND (@Date BETWEEN DateFrom AND DateTo)
	 SELECT @PersonID=NodeID,@PersonType=NodeType FROM dbo.fnGetPersonIDfromPDACode(@IMENumber) U INNER JOIN tblMstrPerson P ON P.NodeID=U.PersonID

		PRINT 'PersonID=' + CAST(@PersonID AS VARCHAR)
		PRINT 'PersonType=' + CAST(@PersonType AS VARCHAR)

		 INSERT INTO #RoutesForPerson(RouteID,RouteNodeType)
		  SELECT R.NodeID,R.NodeType FROM tblSalesPersonMapping PM INNER JOIN tblDBRSalesStructureRouteMstr R ON R.NodeID=PM.NodeID  
		  AND R.NodeType=PM.NodeType  
		  WHERE PersonNodeID=@PersonID AND PersonType=@PersonType AND @Date BETWEEN FROMDATE AND TODATE  
	 --END   
	 --SELECT * FROM #RoutesForPerson
	 
	CREATE TABLE #IncentiveListForPerson(IncId INT,IncentiveName VARCHAR(500),KPIId INT,IncStartDate DATE,IncEndDate DATE,OutputType TINYINT,flgAcheived TINYINT DEFAULT 0 NOT NULL,Earning VARCHAR(20) DEFAULT 0 NOT NULL)
	--CREATE TABLE #tmpIncRslt(IncId INT,Descr VARCHAR(500) DEFAULT '' NOT NULL,TimePeriod VARCHAR(20) DEFAULT '' NOT NULL,Tgt INT DEFAULT 0 NOT NULL,Ach INT DEFAULT 0 NOT NULL,Shortfall VARCHAR(20) DEFAULT 0 NOT NULL,PayoutAmount INT DEFAULT 0 NOT NULL,MonthTotal INT DEFAULT 0 NOT NULL)
	CREATE TABLE #tmpIncRslt(IncId INT,TimeGranualrityId INT,Descr VARCHAR(500) DEFAULT '' NOT NULL,Category VARCHAR(200) DEFAULT '' NOT NULL,TimePeriod VARCHAR(100) DEFAULT '' NOT NULL,Tgt INT DEFAULT 0 NOT NULL,Ach VARCHAR(20),DayEarned VARCHAR(10) DEFAULT '' NOT NULL,Shortfall VARCHAR(20) DEFAULT 0 NOT NULL,ActPayout VARCHAR(50) DEFAULT 0 NOT NULL,PossiblePayout VARCHAR(50) DEFAULT 0 NOT NULL)
	CREATE TABLE #tmpColumnMapping(IncId INT,ReportColumnName VARCHAR(200),DisplayColumnName VARCHAR(200),Ordr INT)

	CREATE TABLE #tmpPastData(IncId INT,TimePeriod VARCHAR(50),NoAcheived INT DEFAULT 0 NOT NULL,PayoutAcheived FLOAT DEFAULT 0 NOT NULL)
	CREATE TABLE #tmpPastColumnMapping(IncId INT,ReportColumnName VARCHAR(200),DisplayColumnName VARCHAR(200),Ordr INT)
	CREATE TABLE #tmpDaysInWeek(WorkingDay DATE,flgAcheived TINYINT,flgPlanned TINYINT)

	INSERT INTO #IncentiveListForPerson(IncId,IncentiveName,KPIId,IncStartDate,IncEndDate)
	SELECT ICM.IncId,ICM.IncentiveName,ICM.KPIId,ICD.IncStartDate,ICD.IncEndDate
	FROM tblIncentiveMaster ICM INNER JOIN tblIncentiveDates ICD ON ICM.IncID=ICD.IncID
	WHERE (@Date BETWEEN  ICD.IncStartDate AND ICD.IncEndDate)
	--SELECT * FROM #IncentiveListForPerson

	IF ISNULL(@PersonID,0)>0 
	BEGIN
		IF EXISTS(SELECT 1 FROM #IncentiveListForPerson)
		BEGIN
			EXEC [spInc_CalculateIncentive_PersonWise]@RptMonthYear,@PersonID,@PersonType
		END
	END

	SET @Counter=0
	WHILE @Counter<7
	BEGIN
		INSERT INTO #tmpDaysInWeek(WorkingDay,flgAcheived,flgPlanned)
		SELECT DATEADD(dd,-@Counter,@WeekEnding),0,0
		--select dateadd(dd,-1,getdate())
		SET @Counter+=1
	END
	--SELECT * FROM #tmpDaysInWeek

	 SET DATEFIRST 1
	SELECT DISTINCT RCM.RouteId,D.WorkingDay,dbo.[fnGetPlannedVisit](RCM.RouteId,RCM.NodeType,D.WorkingDay) AS FlgPlanned INTO #tmpRoute
	FROM tblRouteCoverage RCM INNER JOIN #RoutesForPerson ON RCM.RouteId=#RoutesForPerson.RouteId CROSS JOIN #tmpDaysInWeek D 
	
	DELETE FROM #tmpRoute WHERE FlgPlanned=0
	SET DATEFIRST 7
	
	UPDATE A SET A.flgPlanned=1 FROM #tmpDaysInWeek A INNER JOIN #tmpRoute B ON A.WorkingDay=B.WorkingDay
	--SELECT * FROM #tmpRoute
	--SELECT * FROM #tmpDaysInWeek

	
	
	DECLARE @AchVal FLOAT=0
	DECLARE @MaterialNodeType INT=0
	DECLARE @Material VARCHAR(200)=''
	--DECLARE @Counter INT=0
	SET @cur_IncList=CURSOR FOR
	SELECT IncId,IncStartDate,IncEndDate FROM #IncentiveListForPerson --WHERE IncId NOT IN(1)
	ORDER BY IncId
	OPEN @cur_IncList
	FETCH NEXT FROM @cur_IncList INTO @IncId,@IncStartDate, @IncEndDate
	WHILE @@FETCH_STATUS=0
	BEGIN
		SET @cur_IncSlabList=CURSOR FOR
		SELECT IncSlabId,FromDate,ToDate,strSlabRule FROM tblIncentive_SlabMaster 
		WHERE IncId=@IncId AND (@Date BETWEEN FromDate AND ToDate)
		OPEN @cur_IncSlabList
		FETCH NEXT FROM @cur_IncSlabList INTO @IncSlabId,@IncSlabStartDate, @IncSlabEndDate,@strSlabRule
		WHILE @@FETCH_STATUS=0
		BEGIN
			SET @AchVal=0
			--SELECT @IncSlabId
			----IF @IncSlabId IN(8,9)
			----BEGIN
			----	UPDATE #IncentiveListForPerson SET OutPutType=1 WHERE IncId=@IncId

			----	INSERT INTO #tmpIncRslt(IncId,Descr)
			----	SELECT @IncId AS IncId,'NA'

			----	UPDATE #IncentiveListForPerson SET Earning= 'NA' WHERE IncId=@IncId

			----	INSERT INTO #tmpColumnMapping(IncId,ReportColumnName,DisplayColumnName,Ordr)
			----	SELECT @IncId AS IncId,'Descr' AS ReportColumnName,'Incentive Details' AS DisplayColumnName,1 AS Ordr
			----END
			----ELSE
			 IF EXISTS(SELECT IncSlabRuleId FROM tblIncentive_SlabRuleDetail WHERE IncSlabId=@IncSlabId AND DependentSlabRuleId IS NULL AND CalcSequence>1 AND IncSlabRuleId NOT IN(SELECT DISTINCT DependentSlabRuleId FROM tblIncentive_SlabRuleDetail WHERE IncSlabId=@IncSlabId AND DependentSlabRuleId IS NOT NULL))
			BEGIN
				PRINT 'Condition 2'
				UPDATE #IncentiveListForPerson SET OutPutType=2 WHERE IncId=@IncId
				--SELECT @IncSlabId
				SET @cur_IncSlabRuleList=CURSOR FOR
				SELECT IncSlabRuleId,TimeGranualrityId,CutoffVal,PayoutAmount,CalcSequence FROM tblIncentive_SlabRuleDetail WHERE IncSlabID=@IncSlabId ORDER BY CalcSequence DESC
				OPEN @cur_IncSlabRuleList
				FETCH NEXT FROM @cur_IncSlabRuleList INTO @IncSlabRuleId,@TimeGranualrityId,@CutoffVal,@PayoutAmount,@CalcSequence
				WHILE @@FETCH_STATUS=0
				BEGIN	
					SET @AchVal=0
					--SELECT @IncSlabRuleId
					IF @TimeGranualrityId=2
					BEGIN
						SELECT @TimeGranualrityValue=CONVERT(VARCHAR,@Date,112)
						SELECT @TimePeriod='Day'
					END
					ELSE IF @TimeGranualrityId=3
					BEGIN
						SELECT @TimeGranualrityValue=CONVERT(VARCHAR,@WeekEnding,112)
						SELECT @TimePeriod='Week'
					END
					ELSE IF @TimeGranualrityId=4
					BEGIN
						SELECT @TimeGranualrityValue=@RptMonthyear
						SELECT @TimePeriod='Month'
					END
					--SELECT @TimeGranualrityValue
					--SELECT @TimeGranualrityId

					SELECT @AchVal=AchVal
					FROM tblPayoutDetail
					WHERE IncSlabRuleId=@IncSlabRuleId AND IncSlabId=@IncSlabId AND PersonNodeId=@PersonID AND TimeGranualrityId=@TimeGranualrityId AND TimeGranualrityValue=@TimeGranualrityValue

					--SELECT @CutoffVal
					--SELECT @AchVal
					IF @TimeGranualrityId=2
					BEGIN
						UPDATE #tmpDaysInWeek Set flgAcheived=0

						UPDATE A SET A.flgAcheived=B.flgPayoutAcheived FROM #tmpDaysInWeek A INNER JOIN tblPayoutDetail B ON CONVERT(VARCHAR,A.WorkingDay,112)=B.TimeGranualrityValue
						WHERE B.IncSlabRuleId=@IncSlabRuleId AND B.IncSlabId=@IncSlabId AND B.PersonNodeId=@PersonID AND B.TimeGranualrityId=@TimeGranualrityId AND B.flgPayoutAcheived=1
						--SELECT * FROM #tmpDaysInWeek
						--SELECT COUNT(WorkingDay) AS RemainingDay FROM #tmpDaysInWeek WHERE CONVERT(VARCHAR,WorkingDay,112)>=CONVERT(VARCHAR,@Date,112)
						INSERT INTO #tmpIncRslt(IncId,TimeGranualrityId,TimePeriod,Tgt,Shortfall,DayEarned,ActPayout,PossiblePayout)
						SELECT @IncId AS IncId,@TimeGranualrityId, @TimePeriod AS [Time Period],ISNULL(@CutoffVal,0),'',ISNULL(AA.DayEarned,0),ISNULL(AA.DayEarned,0)*ISNULL(@PayoutAmount,0),ISNULL(BB.RemainingDay,0)*ISNULL(@PayoutAmount,0)
						FROM (SELECT COUNT(WorkingDay) AS DayEarned FROM #tmpDaysInWeek WHERE flgAcheived=1) AA,(SELECT COUNT(WorkingDay) AS RemainingDay FROM #tmpDaysInWeek WHERE flgAcheived=0 AND flgPlanned=1 AND CONVERT(VARCHAR,WorkingDay,112)>=CONVERT(VARCHAR,@Date,112)) BB						
					END
					ELSE
					BEGIN
						PRINT '@TimeGranualrityId' + CAST(@TimeGranualrityId AS VARCHAR)
						INSERT INTO #tmpIncRslt(IncId,TimeGranualrityId,TimePeriod,Tgt,Ach,Shortfall,ActPayout,PossiblePayout)
						SELECT @IncId AS IncId,@TimeGranualrityId,'Current ' + @TimePeriod AS [Time Period],ISNULL(@CutoffVal,0),ISNULL(@AchVal,0),CASE WHEN ISNULL(@AchVal,0)>=ISNULL(@CutoffVal,0) THEN 0 ELSE ISNULL(@CutoffVal,0)-ISNULL(ROUND(@AchVal,0),0) END AS Shortfall,CASE WHEN ISNULL(@AchVal,0)>=ISNULL(@CutoffVal,0) THEN ISNULL(@PayoutAmount * @AchVal,0) ELSE 0 END AS ActPayout,CASE WHEN ISNULL(@AchVal,0)<ISNULL(@CutoffVal,0) THEN ISNULL(@PayoutAmount * @CutoffVal,0) ELSE 0 END AS PossiblePayout	
						
						--SELECT * FROM #tmpIncRslt
					END
					--SELECT @CalcSequence
					--SELECT @CutoffVal
					--SELECT @AchVal
					IF ISNULL(@AchVal,0)>=ISNULL(@CutoffVal,0)
					BEGIN
						UPDATE A SET A.flgAcheived= CASE @CalcSequence WHEN 1 THEN 1 ELSE 2 END FROM #IncentiveListForPerson A
						WHERE A.IncId=@IncId

						IF @TimeGranualrityId=4
							UPDATE #tmpIncRslt SET ActPayout='',PossiblePayout='' WHERE IncId= @IncId AND TimeGranualrityId IN(2,3)
						ELSE IF @TimeGranualrityId=3
							UPDATE #tmpIncRslt SET ActPayout='',PossiblePayout='' WHERE IncId= @IncId AND TimeGranualrityId IN (2)
					END

					IF @TimeGranualrityId=2 OR @TimeGranualrityId=3
					BEGIN
						INSERT INTO #tmpPastData(IncId,TimePeriod,NoAcheived,PayoutAcheived)
						SELECT @IncId AS IncId,@TimePeriod + 's Earned',ISNULL(AA.Ach,0),ISNULL(AA.Ach,0)*ISNULL(@PayoutAmount,0)
						FROM (SELECT COUNT(DISTINCT TimeGranualrityValue) AS Ach FROM tblPayoutDetail WHERE IncSlabRuleId=@IncSlabRuleId AND IncSlabId=@IncSlabId AND PersonNodeId=@PersonID AND TimeGranualrityId=@TimeGranualrityId AND LEFT(TimeGranualrityValue,6)=@RptMonthYear AND flgPayoutAcheived=1) AA
					END

					FETCH NEXT FROM @cur_IncSlabRuleList INTO @IncSlabRuleId,@TimeGranualrityId,@CutoffVal,@PayoutAmount,@CalcSequence
				END
				DEALLOCATE @cur_IncSlabRuleList
				
				UPDATE A SET A.Earning='Rs ' + CAST(CAST(ROUND(ISNULL(AA.PayoutValue,0),0) AS DECIMAL(18,0)) AS VARCHAR) FROM #IncentiveListForPerson A,
				(SELECT SUM(PayoutValue) PayoutValue FROM tblIncentiveMaster IM
				INNER JOIN tblIncentive_SlabMaster S ON IM.IncId=S.IncId INNER JOIN tblPayoutdetail P ON S.IncSlabId=P.IncSlabId 
				WHERE IM.IncId=@IncId AND PersonNodeId=@PersonID AND flgPayoutAcheived=1 AND LEFT(TimeGranualrityValue,6)=@RptMonthYear) AA
				WHERE A.IncId=@IncId

				INSERT INTO #tmpColumnMapping(IncId,ReportColumnName,DisplayColumnName,Ordr)
				SELECT @IncId AS IncId,'TimePeriod' AS ReportColumnName,'Time Period' AS DisplayColumnName,1 AS Ordr
				UNION
				SELECT @IncId AS IncId,'Tgt' AS ReportColumnName,'Target' AS DisplayColumnName,2 AS Ordr
				UNION
				SELECT @IncId AS IncId,'DayEarned' AS ReportColumnName,'Days Earned' AS DisplayColumnName,3 AS Ordr
				UNION
				SELECT @IncId AS IncId,'Shortfall' AS ReportColumnName,'Shortfall' AS DisplayColumnName,4 AS Ordr
				UNION
				SELECT @IncId AS IncId,'ActPayout' AS ReportColumnName,'Actual Payout' AS DisplayColumnName,5 AS Ordr
				UNION
				SELECT  @IncId AS IncId,'PossiblePayout' AS ReportColumnName,'Possible Payout(' + @MonthName + ')' AS DisplayColumnName,6 AS Ordr

				INSERT INTO #tmpPastColumnMapping(IncId,ReportColumnName,DisplayColumnName,Ordr)
				SELECT @IncId AS IncId,'TimePeriod' AS ReportColumnName,'Time Period' AS DisplayColumnName,1 AS Ordr
				UNION
				SELECT @IncId AS IncId,'NoAcheived' AS ReportColumnName,'No. Acheived' AS DisplayColumnName,2 AS Ordr
				UNION
				SELECT @IncId AS IncId,'PayoutAcheived' AS ReportColumnName,'Payout Acheived' AS DisplayColumnName,3 AS Ordr
			END
			ELSE IF EXISTS(SELECT IncSlabRuleId FROM tblIncentive_SlabRuleDetail WHERE IncSlabId=@IncSlabId AND DependentSlabRuleId IS NULL AND CalcSequence>1 AND IncSlabRuleId IN(SELECT DISTINCT DependentSlabRuleId FROM tblIncentive_SlabRuleDetail WHERE IncSlabId=@IncSlabId AND DependentSlabRuleId IS NOT NULL))
			BEGIN
				PRINT 'Condition 3'
				UPDATE #IncentiveListForPerson SET OutPutType=2 WHERE IncId=@IncId
				--SELECT @IncSlabId
				SET @Counter=1
				SET @cur_IncSlabRuleList=CURSOR FOR
				SELECT IncSlabRuleId,TimeGranualrityId,CutoffVal,PayoutAmount,CalcSequence,DependentSlabRuleId FROM tblIncentive_SlabRuleDetail WHERE IncSlabID=@IncSlabId ORDER BY CalcSequence DESC
				OPEN @cur_IncSlabRuleList
				FETCH NEXT FROM @cur_IncSlabRuleList INTO @IncSlabRuleId,@TimeGranualrityId,@CutoffVal,@PayoutAmount,@CalcSequence,@DependentSlabRuleId
				WHILE @@FETCH_STATUS=0
				BEGIN	
					SET @AchVal=0
					--SELECT @IncSlabRuleId
					--SELECT @DependentSlabRuleId
					--SELECT @Counter
					SELECT @MaterialNodeType=MaterialNodeType FROM tblIncentive_SlabRuleMaterialDetail WHERE IncSlabRuleId=@IncSlabRuleId

					IF @MaterialNodeType=62
					BEGIN
						SELECT @Material=A.PrdWeightTypeDescr 
						FROM tblPrdAttributeWeightTypeMstr A INNER JOIN tblIncentive_SlabRuleMaterialDetail B ON A.PrdWeightTypeId=B.MaterialNodeId
						WHERE B.MaterialNodeType=@MaterialNodeType
					END
					ELSE IF @MaterialNodeType=51
					BEGIN
						SELECT @Material=A.POSMaterialDescr 
						FROM tblPOSMaterialMstr A INNER JOIN tblIncentive_SlabRuleMaterialDetail B ON A.POSMaterialId=B.MaterialNodeId
						WHERE B.MaterialNodeType=@MaterialNodeType
					END
					--SELECT @Material

					IF @TimeGranualrityId=1
					BEGIN
						SELECT @TimeGranualrityValue=FORMAT(@IncSlabStartDate,'dd-MMM-yy') + ' to ' + FORMAT(@IncSlabEndDate,'dd-MMM-yy')
						SELECT @TimePeriod=FORMAT(@IncSlabStartDate,'dd-MMM-yy') + ' to ' + FORMAT(@IncSlabEndDate,'dd-MMM-yy')
					END
					ELSE IF @TimeGranualrityId=2
					BEGIN
						SELECT @TimeGranualrityValue=CONVERT(VARCHAR,@Date,112)
						SELECT @TimePeriod='Day'
					END
					ELSE IF @TimeGranualrityId=3
					BEGIN
						SELECT @TimeGranualrityValue=CONVERT(VARCHAR,@WeekEnding,112)
						SELECT @TimePeriod='Week'
					END
					ELSE IF @TimeGranualrityId=4
					BEGIN
						SELECT @TimeGranualrityValue=@RptMonthyear
						SELECT @TimePeriod='Month'
					END
					--SELECT @TimeGranualrityValue
					--SELECT @TimeGranualrityId

					SELECT @AchVal=AchVal
					FROM tblPayoutDetail
					WHERE IncSlabRuleId=@IncSlabRuleId AND IncSlabId=@IncSlabId AND PersonNodeId=@PersonID AND TimeGranualrityId=@TimeGranualrityId AND TimeGranualrityValue=@TimeGranualrityValue				
					
					--SELECT @CalcSequence
					--SELECT @CutoffVal
					--SELECT @AchVal
					IF @DependentSlabRuleId IS NULL
					BEGIN
						IF ISNULL(@AchVal,0)>=ISNULL(@CutoffVal,0)
						BEGIN
							INSERT INTO #tmpIncRslt(IncId,Category,Tgt,Shortfall,ActPayout,PossiblePayout)
							SELECT @IncId AS IncId,ISNULL(@Material,''),ISNULL(@CutoffVal,0),CASE WHEN ISNULL(@AchVal,0)>=ISNULL(@CutoffVal,0) THEN 0 ELSE ISNULL(@CutoffVal,0)-ISNULL(ROUND(@AchVal,0),0) END AS Shortfall,CASE WHEN ISNULL(@AchVal,0)>=ISNULL(@CutoffVal,0) THEN ISNULL(@PayoutAmount,0) ELSE 0 END AS ActPayout,ISNULL(AA.PayoutAmount,0)
							FROM (SELECT PayoutAmount FROM tblIncentive_SlabRuleDetail WHERE IncSlabId=@IncSlabId AND DependentSlabRuleId IS NULL AND CalcSequence<@CalcSequence) AA

							UPDATE A SET A.flgAcheived= CASE @CalcSequence WHEN 1 THEN 1 ELSE 2 END FROM #IncentiveListForPerson A
							WHERE A.IncId=@IncId
						END
						ELSE
						BEGIN
							INSERT INTO #tmpIncRslt(IncId,Category,Tgt,Shortfall,ActPayout,PossiblePayout)
							SELECT @IncId AS IncId,ISNULL(@Material,''),ISNULL(@CutoffVal,0),CASE WHEN ISNULL(@AchVal,0)>=ISNULL(@CutoffVal,0) THEN 0 ELSE ISNULL(@CutoffVal,0)-ISNULL(ROUND(@AchVal,0),0) END AS Shortfall,CASE WHEN ISNULL(@AchVal,0)>=ISNULL(@CutoffVal,0) THEN ISNULL(@PayoutAmount,0) ELSE 0 END AS ActPayout,CASE WHEN ISNULL(@AchVal,0)<ISNULL(@CutoffVal,0) THEN ISNULL(@PayoutAmount,0) ELSE 0 END AS ActPayout		

							IF @DependentSlabRuleId IS NOT NULL
								BREAK
						END
					END
					ELSE
					BEGIN
						INSERT INTO #tmpIncRslt(IncId,Category,Tgt,Shortfall,ActPayout,PossiblePayout)
						SELECT @IncId AS IncId,ISNULL(@Material,''),ISNULL(@CutoffVal,0),CASE WHEN ISNULL(@AchVal,0)>=ISNULL(@CutoffVal,0) THEN 0 ELSE ISNULL(@CutoffVal,0)-ISNULL(ROUND(@AchVal,0),0) END AS Shortfall,'',''

						IF @DependentSlabRuleId IS NOT NULL
							BREAK
					END
					
					
					IF @DependentSlabRuleId IS NOT NULL
						SET @Counter+=1
					FETCH NEXT FROM @cur_IncSlabRuleList INTO @IncSlabRuleId,@TimeGranualrityId,@CutoffVal,@PayoutAmount,@CalcSequence,@DependentSlabRuleId
				END
				DEALLOCATE @cur_IncSlabRuleList
				
				UPDATE A SET A.Earning='Rs ' + CAST(CAST(ROUND(ISNULL(AA.PayoutValue,0),0) AS DECIMAL(18,0)) AS VARCHAR) FROM #IncentiveListForPerson A,
				(SELECT SUM(PayoutValue) PayoutValue FROM tblIncentiveMaster IM
				INNER JOIN tblIncentive_SlabMaster S ON IM.IncId=S.IncId INNER JOIN tblPayoutdetail P ON S.IncSlabId=P.IncSlabId 
				WHERE IM.IncId=@IncId AND PersonNodeId=@PersonID AND flgPayoutAcheived=1 AND TimeGranualrityValue=FORMAT(@IncSlabStartDate,'dd-MMM-yy') + ' to ' + FORMAT(@IncSlabEndDate,'dd-MMM-yy')) AA
				WHERE A.IncId=@IncId

				INSERT INTO #tmpColumnMapping(IncId,ReportColumnName,DisplayColumnName,Ordr)
				SELECT @IncId AS IncId,'Category' AS ReportColumnName,'Category' AS DisplayColumnName,1 AS Ordr
				UNION
				SELECT @IncId AS IncId,'Tgt' AS ReportColumnName,'Target' AS DisplayColumnName,2 AS Ordr
				UNION
				SELECT @IncId AS IncId,'Shortfall' AS ReportColumnName,'Shortfall' AS DisplayColumnName,4 AS Ordr
				UNION
				SELECT @IncId AS IncId,'ActPayout' AS ReportColumnName,'Actual Payout' AS DisplayColumnName,5 AS Ordr
				UNION
				SELECT  @IncId AS IncId,'PossiblePayout' AS ReportColumnName,'Possible Payout(' + @MonthName + ')' AS DisplayColumnName,6 AS Ordr

			END	
			ELSE
			BEGIN
				PRINT 'Condition 4'
				UPDATE #IncentiveListForPerson SET OutPutType=1 WHERE IncId=@IncId
				--SELECT @IncSlabId
				SELECT @IncSlabRuleId=IncSlabRuleId,@TimeGranualrityId=TimeGranualrityId,@CutoffVal=CutoffVal, @PayoutAmount=PayoutAmount
				FROM tblIncentive_SlabRuleDetail
				WHERE IncSlabID=@IncSlabId AND CalcSequence=1 AND DependentSlabRuleId IS NULL

				IF @TimeGranualrityId=2
				BEGIN
					SELECT @TimeGranualrityValue=CONVERT(VARCHAR,@Date,112)
					SELECT @TimePeriod='Day'
				END
				ELSE IF @TimeGranualrityId=3
				BEGIN
					SELECT @TimeGranualrityValue=CONVERT(VARCHAR,@WeekEnding,112)
					SELECT @TimePeriod='Week'
				END
				ELSE IF @TimeGranualrityId=4
				BEGIN
					SELECT @TimeGranualrityValue=@RptMonthyear
					SELECT @TimePeriod='Month'
				END
				--SELECT @TimeGranualrityValue
				
				SELECT @AchVal=AchVal
				FROM tblPayoutDetail
				WHERE IncSlabRuleId=@IncSlabRuleId AND IncSlabId=@IncSlabId AND PersonNodeId=@PersonID AND TimeGranualrityId=@TimeGranualrityId AND TimeGranualrityValue=@TimeGranualrityValue

				--SELECT @CutoffVal
				--SELECT @AchVal

				IF ISNULL(@AchVal,0)>=ISNULL(@CutoffVal,0)
				BEGIN
					INSERT INTO #tmpIncRslt(IncId,Descr)
					SELECT @IncId AS IncId,'Your target for current ' + @TimePeriod + ' is ' + CAST(ISNULL(@CutoffVal,0) AS VARCHAR) +' & you have acheived it & earned Rs ' + CAST(ISNULL(@PayoutAmount,0) AS VARCHAR) --+ ' Rs'

					UPDATE #IncentiveListForPerson SET flgAcheived=1 WHERE IncId=@IncId
					UPDATE #IncentiveListForPerson SET Earning= 'Rs ' + CAST(ISNULL(@PayoutAmount,0) AS VARCHAR) WHERE IncId=@IncId
				END
				ELSE
				BEGIN
					INSERT INTO #tmpIncRslt(IncId,Descr)
					SELECT @IncId AS IncId,'Your target for current ' + @TimePeriod + ' is ' + CAST(ISNULL(@CutoffVal,0) AS VARCHAR) +' & you have acheived ' + CAST(ISNULL(ROUND(@AchVal,0),0) AS VARCHAR) + '. If you acheive ' + CAST(ISNULL(@CutoffVal,0)-ISNULL(ROUND(@AchVal,0),0) AS VARCHAR) + ' more, you will earn Rs ' + CAST(ISNULL(@PayoutAmount,0) AS VARCHAR) --+ ' Rs.'
					UPDATE #IncentiveListForPerson SET Earning= 'Rs 0' WHERE IncId=@IncId
				END

				--to be removed
				--IF @IncId=3
				--BEGIN
				--	INSERT INTO #tmpIncRslt(IncId,Descr)
				--	SELECT @IncId AS IncId,'Your target for current ' + @TimePeriod + ' is ' + CAST(ISNULL(@CutoffVal,0) AS VARCHAR) +' & you have acheived ' + CAST(ISNULL(ROUND(@AchVal,0),0) AS VARCHAR) + '. If you acheive ' + CAST(ISNULL(@CutoffVal,0)-ISNULL(ROUND(@AchVal,0),0) AS VARCHAR) + ' more, you will earn ' + CAST(ISNULL(@PayoutAmount,0) AS VARCHAR) + ' Rs.'
				--END

				INSERT INTO #tmpColumnMapping(IncId,ReportColumnName,DisplayColumnName,Ordr)
				SELECT @IncId AS IncId,'Descr' AS ReportColumnName,'Incentive Details' AS DisplayColumnName,1 AS Ordr
			END


			FETCH NEXT FROM @cur_IncSlabList INTO @IncSlabId,@IncSlabStartDate, @IncSlabEndDate,@strSlabRule
		END
		DEALLOCATE @cur_IncSlabList

		FETCH NEXT FROM @cur_IncList INTO @IncId,@IncStartDate, @IncEndDate
	END
	DEALLOCATE @cur_IncList

	--SELECT * FROM #tmpIncRslt
	--UPDATE #IncentiveListForPerson SET flgAcheived=1 WHERE IncId=3
	--UPDATE #IncentiveListForPerson SET flgAcheived=2 WHERE IncId=4

	SELECT IncId,OutputType,IncentiveName,flgAcheived,Earning FROM #IncentiveListForPerson --WHERE IncId NOT IN(1)

	--SELECT IncId,1 AS OutputType,IncentiveName FROM tblIncentiveMaster WHERE IncId=1
	--UNION
	--SELECT IncId,2 AS OutputType,IncentiveName FROM tblIncentiveMaster WHERE IncId=3
	--ORDER BY IncId

	--INSERT INTO #tmpIncRslt(IncId,Descr)
	--SELECT 1 AS IncId,'Your target is 200 & you have acheived 150. If you acheive 50 more, you will earn 100 Rs' AS Descr

	--INSERT INTO #tmpIncRslt(IncId,[Date],Tgt,Ach,Shortfall,PayoutAmount)
	--SELECT 1 AS IncId,'12-Jun-2017' AS [Date],200 AS Tgt, 100 AS Ach,100 AS Shortfall,200 AS [Payout_Amount]
	--UNION
	--SELECT 3 AS IncId,'13-Jun-2017' AS [Date],200 AS Tgt, 100 AS Ach,100 AS Shortfall,200 AS [Payout_Amount]


	SELECT IncId,Descr,Category,TimePeriod,Tgt,DayEarned,Shortfall,ActPayout,PossiblePayout FROM #tmpIncRslt
	
	
	--SELECT 1 AS IncId,'Descr' AS ReportColumnName,'Descr' AS DisplayColumnName,1 AS Ordr INTO #tmpColumnMapping
	--UNION
	--SELECT 3 AS IncId,'Date' AS ReportColumnName,'Date' AS DisplayColumnName,1 AS Ordr
	--UNION
	--SELECT 3 AS IncId,'Tgt' AS ReportColumnName,'Tgt' AS DisplayColumnName,2 AS Ordr
	--UNION
	--SELECT 3 AS IncId,'Ach' AS ReportColumnName,'Ach' AS DisplayColumnName,3 AS Ordr
	--UNION
	--SELECT 3 AS IncId,'Shortfall' AS ReportColumnName,'Shortfall' AS DisplayColumnName,4 AS Ordr
	--UNION
	--SELECT 3 AS IncId,'PayoutAmount' AS ReportColumnName,'[Payout Amount]' AS DisplayColumnName,5 AS Ordr

	SELECT IncId,ReportColumnName,DisplayColumnName
	FROM #tmpColumnMapping
	ORDER BY IncId,ordr

	SELECT 'Rs ' + CAST(CAST(ROUND(ISNULL(SUM(PayoutValue),0),0) AS DECIMAL(18,0)) AS VARCHAR)  AS [Total_Earning]
	FROM tblPayoutMaster
	WHERE PersonNodeId=@PersonId AND LEFT(TimeGranualrityValue,6)=@RptMonthYear
	--SELECT 'Rs 100' AS [Total_Earning]

	SELECT * FROM #tmpPastData
	SELECT * FROM #tmpPastColumnMapping ORDER BY IncId,ordr

	--SELECT 'Payment of Incentives will be subject to verification of Order Booked Vs Order Actually Executed. Please enter Order Actually Executed in SFA. Incentive Pay Out is based on Order Actually Executed' AS MsgToDisplay
	SELECT 'Incentives secondary sales are shown based on orders booked but payment will be based on actual execution and will be verified before payment is made.' AS MsgToDisplay
	

END
