
-- =============================================
-- Author:		Avinash Gupta
-- Create date: 26-Aug-2014
-- Description:	Sp to create the Route for the DSR
-- =============================================
--[SpSaveDSRRouteDetails] 216,16,'1^',0,'1^',3193,'','01-Sep-2015','30-Sep-2015'
CREATE PROCEDURE [dbo].[SpSaveDSRRouteDetails] 
	@RouteID INT, -- should be greater than 0 always
	@NodeType INT,
	@StrCovFrqID VARCHAR(50), --- 1^3^5^
	@CovStoreCount INT,
	@StrWeekday VARCHAR(50),  -- 1^3^5^6^
	@LoginID INT,
	@strStoresID VARCHAR(MAX),  -- 1^2^3,
	@FromDate SMALLDATETIME,
	@ToDate SMALLDATETIME,
	@WeekId INT
AS
BEGIN
	--DECLARE @MappedDSRID INT
	DECLARE @CovFrqID INT
	DECLARE @WeekDay INT
	DECLARE @StrWeekdayFull VARCHAR(MAX)
	DECLARE @SQL VARCHAR(MAX)
	DECLARE @Stores VARCHAR(MAX)
	--DECLARE @UncheckedStores VARCHAR(MAX)
	SET @Stores=REPLACE (@strStoresID,'^',',')
	--SET @UncheckedStores=REPLACE (@strUncheckedStoresID,'^',',')
	SET @StrWeekdayFull=@StrWeekday
	IF @RouteID>0
		BEGIN
		IF @RouteID>0 AND @NodeType IN(140,170)
			--UPDATE tblDBRSalesStructureRouteMstr SET CoveredStoreCount=@CovStoreCount FROM tblDBRSalesStructureRouteMstr WHERE NodeID=@RouteID
		
			------ Assignment of Person to the Route
			----IF EXISTS (SELECT 1 FROM tblSalesPersonMapping WHERE NodeID=@RouteID AND NodeType=@NodeType AND PersonNodeID<>@MappedDSRID)
			----BEGIN
			----	IF EXISTS (SELECT 1 FROM tblSalesPersonMapping WHERE NodeID=@RouteID AND NodeType=@NodeType AND DATEDIFF(d,@FromDate,FromDate)=0 AND DATEDIFF(d,@ToDate,ToDate)=0)
			----		UPDATE tblSalesPersonMapping SET PersonNodeID=@MappedDSRID WHERE NodeID=@RouteID AND NodeType=@NodeType
			----	ELSE IF EXISTS (SELECT 1 FROM tblSalesPersonMapping WHERE NodeID=@RouteID AND NodeType=@NodeType AND DATEDIFF(d,@FromDate,FromDate)<0 AND DATEDIFF(d,@ToDate,ToDate)<0)
			----	BEGIN
			----		UPDATE tblSalesPersonMapping SET PersonNodeID=@MappedDSRID,ToDate=DATEADD(d,-1,@FromDate) WHERE NodeID=@RouteID AND NodeType=@NodeType
			----		INSERT INTO tblSalesPersonMapping(PersonNodeID,NodeID,NodeType,FromDate,ToDate,LoginIDIns)
			----		VALUES (@MappedDSRID,@RouteID,@NodeType,@FromDate,@ToDate,@LoginID)
			----	END
			----END
			----ELSE IF EXISTS (SELECT 1 FROM tblSalesPersonMapping WHERE NodeID=@RouteID AND NodeType=@NodeType AND PersonNodeID=@MappedDSRID)
			----BEGIN
			----	UPDATE tblSalesPersonMapping SET ToDAte=@ToDAte,LoginIDUpd=@LoginID WHERE NodeID=@RouteID AND NodeType=@NodeType AND PersonNodeID=@MappedDSRID
			----END
			-- Entring the Route Details Values
			--################################  Wrinting Code For RoutePerson Mapping ##############################################################
			DECLARE @MinExistingFromDate DATETIME
			DECLARE @MaxExistingToDate DATETIME
			DECLARE @PreviousToDate DATETIME
			DECLARE @PreviousPersonID INT
			DECLARE @flgInsertCurrent TINYINT
			DECLARE @flgInsertPrevious TINYINT
			SET @flgInsertCurrent=0
			SET @flgInsertPrevious=0
			DECLARE @CountDistinctDates INT
			--- Assuming @FromDate will always be Greater or equal to Todays Date
			IF @FromDate>= CONVERT(VARCHAR(11),GETDATE(),112)
			BEGIN
				IF EXISTS (SELECT 1 FROM tblRouteCoverage SH WHERE RouteID=@RouteID AND NodeType=@NodeType AND ToDate>= CONVERT(VARCHAR(11),GETDATE(),112))
				BEGIN
					DELETE FROM tblRouteCoverage WHERE RouteID=@RouteID AND NodeType=@NodeType AND @FromDate<=FromDate AND @ToDate>=ToDate AND FromDate>=CONVERT(VARCHAR(11),GETDATE(),112)

					PRINT 'Coverage Updation'
					SELECT @MinExistingFromDate=MIN(FromDate) ,@MaxExistingToDate=MAX(ToDate),@CountDistinctDates=COUNT(DISTINCT ToDate) FROM tblRouteCoverage WHERE RouteID=@RouteID 
					AND NodeType=@NodeType AND 
					(@FromDate BETWEEN FromDate AND ToDate OR @ToDate BETWEEN FromDate AND ToDate) AND ToDate> CONVERT(VARCHAR(11),GETDATE(),112)
					SELECT @MinExistingFromDate=ISNULL(@MinExistingFromDate,@FromDate)
					SELECT @MaxExistingToDate=ISNULL(@MaxExistingToDate,@ToDate)

					PRINT '@CountDistinctDates=' + CAST(@CountDistinctDates AS VARCHAR)
					IF @CountDistinctDates>0
					BEGIN
						IF @FromDate>@MaxExistingToDate 
						BEGIN
							SET @flgInsertCurrent=1
						END
						ELSE IF @FromDate=@MinExistingFromDate AND @ToDate=@MaxExistingToDate
						BEGIN
							DELETE FROM tblRouteCoverage WHERE RouteID=@RouteID AND NodeType=@NodeType AND 
							((@FromDate BETWEEN FromDate AND ToDate OR @ToDate BETWEEN FromDate AND ToDate) OR (FromDate BETWEEN @FromDate AND @ToDate OR ToDate BETWEEN @FromDate AND @ToDate))

							SET @flgInsertCurrent=1
						END
						ELSE IF @FromDate<= @MinExistingFromDate AND @ToDate>=@MaxExistingToDate
						BEGIN
							DELETE FROM tblRouteCoverage WHERE RouteID=@RouteID AND NodeType=@NodeType AND 
							((@FromDate BETWEEN FromDate AND ToDate OR @ToDate BETWEEN FromDate AND ToDate) OR (FromDate BETWEEN @FromDate AND @ToDate OR ToDate BETWEEN @FromDate AND @ToDate))
							SET @flgInsertCurrent=1
						END
						ELSE IF @FromDate<= @MinExistingFromDate AND @ToDate<@MaxExistingToDate
						BEGIN
							PRINT 'STEP 3.1'
							IF @CountDistinctDates=1
							BEGIN
								UPDATE  tblRouteCoverage SET FromDate=DATEADD(d,1,@ToDate) FROM tblRouteCoverage 
								WHERE RouteID=@RouteID AND NodeType=@NodeType AND @ToDate BETWEEN FromDate AND ToDate

								SET @flgInsertCurrent=1
							END
							ELSE
							BEGIN
								UPDATE  tblRouteCoverage SET ToDate=DATEADD(d,-1,@FromDate) FROM tblRouteCoverage 
								WHERE RouteID=@RouteID AND NodeType=@NodeType AND ToDate<@FromDate AND ToDate>=CONVERT(VARCHAR(11),GETDATE(),112)
					
								UPDATE tblRouteCoverage SET FromDate=@FromDate FROM tblRouteCoverage 
								WHERE RouteID=@RouteID AND NodeType=@NodeType AND @ToDate BETWEEN FromDate AND ToDate
							END
						END
						ELSE IF @FromDate<@MinExistingFromDate AND @ToDate=@MaxExistingToDate
						BEGIN
						
							PRINT 'Step 4'
							IF @CountDistinctDates=1
							BEGIN
								PRINT 'Step X.1'				
								DELETE FROM tblRouteCoverage WHERE RouteID=@RouteID AND NodeType=@NodeType AND
								((@FromDate BETWEEN FromDate AND ToDate OR @ToDate BETWEEN FromDate AND ToDate) OR (FromDate BETWEEN @FromDate AND @ToDate OR ToDate BETWEEN @FromDate AND @ToDate))

								SET @flgInsertCurrent=1
							END
						END
						ELSE IF @FromDate>@MinExistingFromDate AND @ToDate>=@MaxExistingToDate
						BEGIN
							UPDATE tblRouteCoverage SET ToDate=DATEADD(d,-1,@FromDate) FROM tblRouteCoverage WHERE RouteID=@RouteID AND NodeType=@NodeType
							AND @FromDate BETWEEN FromDate AND ToDate
							DELETE FROM tblRouteCoverage WHERE RouteID=@RouteID AND NodeType=@NodeType AND (FromDate>ToDate OR (FromDate>@FromDate AND ToDate<=@ToDate))
							SET @flgInsertCurrent=1
						END
						ELSE IF @FromDate>@MinExistingFromDate AND @ToDate< @MaxExistingToDate
						BEGIN
							IF @CountDistinctDates=1
							BEGIN
								SELECT @PreviousToDate=ToDate  FROM tblRouteCoverage WHERE RouteID=@RouteID AND NodeType=@NodeType
								AND @FromDate BETWEEN FromDate AND ToDate
								UPDATE tblRouteCoverage SET ToDate=DATEADD(d,-1,@FromDate) FROM tblRouteCoverage WHERE RouteID=@RouteID AND NodeType=@NodeType
								AND @FromDate BETWEEN FromDate AND ToDate
								IF @PreviousToDate>@ToDate
								BEGIN
									SET @flgInsertCurrent=1
								END
							END
							ELSE IF @CountDistinctDates>1
							BEGIN
								SELECT @PreviousToDate=ToDate  FROM tblRouteCoverage WHERE RouteID=@RouteID AND NodeType=@NodeType
								AND @ToDate BETWEEN FromDate AND ToDate
								UPDATE tblRouteCoverage SET ToDate=DATEADD(d,-1,@FromDate) FROM tblRouteCoverage WHERE RouteID=@RouteID AND NodeType=@NodeType
								AND @FromDate BETWEEN FromDate AND ToDate
								UPDATE tblRouteCoverage SET FromDate=DATEADD(d,1,@ToDate) FROM tblRouteCoverage WHERE RouteID=@RouteID AND NodeType=@NodeType
								AND @ToDate BETWEEN FromDate AND ToDate
							END

					
							--UPDATE tblSalesPersonMapping SET FromDate=@ToDate FROM tblSalesPersonMapping WHERE NodeID=@SalesStructureNodeID AND NodeType=@SalesStructureNodeType
							--AND @ToDate BETWEEN FromDate AND ToDate
							SET @flgInsertCurrent=1

					

						END
						ELSE IF @FromDate=@MinExistingFromDate AND @ToDate< @MaxExistingToDate
						BEGIN
							UPDATE tblRouteCoverage SET FromDate=DATEADD(d,-1,@ToDate) FROM tblRouteCoverage WHERE RouteID=@RouteID AND NodeType=@NodeType
							AND @FromDate BETWEEN FromDate AND ToDate
							
							SET @flgInsertCurrent=1
						END
						ELSE IF @FromDate>@MinExistingFromDate AND @ToDate>@MaxExistingToDate
						BEGIN
							UPDATE tblRouteCoverage SET ToDate=DATEADD(d,-1,@FromDate) FROM tblRouteCoverage WHERE RouteID=@RouteID AND NodeType=@NodeType
							AND @FromDate BETWEEN FromDate AND ToDate
							DELETE FROM tblRouteCoverage WHERE RouteID=@RouteID AND NodeType=@NodeType AND FromDate>@FromDate
							SET @flgInsertCurrent=1
						END
					END
					ELSE
					BEGIN
						IF EXISTS (SELECT 1 FROM tblRouteCoverage WHERE RouteID=@RouteID AND NodeType=@NodeType AND  
						(FromDate BETWEEN @FromDate AND @ToDate OR ToDate BETWEEN @FromDate AND @ToDate))
						BEGIN
							DELETE FROM tblRouteCoverage WHERE RouteID=@RouteID AND NodeType=@NodeType AND
							((@FromDate BETWEEN FromDate AND ToDate OR @ToDate BETWEEN FromDate AND ToDate) OR (FromDate BETWEEN @FromDate AND @ToDate OR ToDate BETWEEN @FromDate AND @ToDate)) 
						END
					
						SET @flgInsertCurrent=1
					END
				END
				ELSE
				BEGIN
					SET @flgInsertCurrent=1
				END
			END
			
			
			--##########################################################################################################################################
			----IF EXISTS (SELECT 1 FROM tblRouteCoverage WHERE RouteID=@RouteID AND DATEDIFF(d,@FromDate,FromDate)=0 AND (DATEDIFF(d,@ToDate,ToDate)=0 OR ToDate IS NULL))
			----BEGIN
			----	INSERT INTO tblRouteCoverageHistory(RouteCoverageID,RouteID,CovFrqID,Weekday,FromDate,ToDate,LoginIDIns)
			----	SELECT RouteCoverageID,RouteID,CovFrqID,[Weekday],FromDate,ToDate,LoginIDIns FROM tblRouteCoverage WHERE RouteID=@RouteID AND DATEDIFF(d,@FromDate,FromDate)=0 AND DATEDIFF(d,@ToDate,ToDate)=0
			----	DELETE FROM tblRouteCoverage WHERE RouteID=@RouteID AND DATEDIFF(d,@FromDate,FromDate)=0 AND (DATEDIFF(d,@ToDate,ToDate)=0 OR ToDate IS NULL)
			----END
			IF @flgInsertCurrent=1
			BEGIN
				PRINT 'Coverage Plan Updated'
				WHILE PATINDEX('%^%',@StrCovFrqID)>0
				BEGIN
					SET @CovFrqID=CAST(SUBSTRING(@StrCovFrqID,1,PATINDEX('%^%',@StrCovFrqID)-1) AS INT)
					SET @StrCovFrqID=SUBSTRING(@StrCovFrqID,PATINDEX('%^%',@StrCovFrqID)+1,LEN(@StrCovFrqID))
					SET @StrWeekday=@StrWeekdayFull
					IF @WeekId=0
					BEGIN
						SELECT @WeekId=MIN(WeekId)
						FROM tblRoutePlanDetails
						WHERE weekfrom>= CAST(DATEADD(dd, -(DATEPART(dw, @FromDate)-1), @FromDate) AS DATE) AND CovFrqID=@CovFrqID
					END
					WHILE PATINDEX('%^%',@StrWeekday)>0
					BEGIN
						SET @WeekDay=CAST(SUBSTRING(@StrWeekday,1,PATINDEX('%^%',@StrWeekday)-1) AS INT)
						SET @StrWeekday=SUBSTRING(@StrWeekday,PATINDEX('%^%',@StrWeekday)+1,LEN(@StrWeekday))
				
						INSERT INTO tblRouteCoverage(RouteID,CovFrqID,[Weekday],FromDate,ToDate,LoginIDIns,NodeType,WeekID) 
						VALUES (@RouteID,@CovFrqID,@Weekday,@FromDate,@ToDate,@LoginID,@NodeType,@WeekId)
					END
				END
			END

			
			SELECT RouteID,StoreID,FromDate,ToDate,LoginIDIns,1 AS flgActive INTO #tmpRoutePlan FROM tblRouteCoverageStoreMapping 
			WHERE RouteID=RouteID AND DATEDIFF(d,FromDate,@FromDate)>0 AND DATEDIFF(d,ISNULL(ToDate,'01-Jan-2049'),@FromDate)<0

		

		

			IF ISNULL(@Stores,'') <> ''
			BEGIN
				PRINT 'Route Store Mapped'
				CREATE TABLE #tmpStores(RouteID INT,StoreID INT,FromDate DATETIME,ToDAte DateTime,LoginIDIns INT)
				SET @SQL='UPDATE #tmpRoutePlan SET flgActive=0 FROM #tmpRoutePlan WHERE StoreID NOT IN (' + @Stores + ')' -- Deleting
				EXEC (@SQL)
				SET @SQL='UPDATE #tmpRoutePlan SET flgActive=1 FROM #tmpRoutePlan WHERE StoreID IN (' + @Stores + ')'  -- Updating
				EXEC (@SQL)
				SET @SQL='SELECT ' + CAST(@RouteID AS VARCHAR) + ',StoreID,''' + CONVERT(VARCHAR,@FromDate,112) + ''' ,''' + CONVERT(VARCHAR,@ToDate,112) + ''' ,' + CAST(@LoginID AS VARCHAR) + ' FROM tblStoremaster WHERE StoreID IN (' + @Stores + ')'
				INSERT INTO #tmpStores(RouteID,StoreID,FromDate,ToDate,LoginIDIns)
				EXEC (@SQL)
				INSERT INTO #tmpRoutePlan(RouteID,StoreID,FromDate,ToDate,LoginIDIns,flgActive)
				SELECT S.RouteID,S.StoreID,S.FromDate,S.ToDate,S.LoginIDIns,2 FROM #tmpStores S LEFT OUTER JOIN #tmpRoutePlan RP ON S.StoreID=RP.StoreID WHERE RP.StoreID IS NULL

				UPDATE tblRouteCoverageStoreMapping SET ToDate=DATEADD(d,-1,@FromDate),LoginIDUpd=@LoginID,TimestampUpd=GETDATE() FROM tblRouteCoverageStoreMapping RCM 
				INNER JOIN #tmpRoutePlan TP ON TP.RouteID=RCM.RouteID AND TP.StoreID=RCM.StoreID WHERE TP.flgActive=0

				UPDATE tblRouteCoverageStoreMapping SET ToDate=@ToDate,LoginIDUpd=@LoginID,TimestampUpd=GETDATE() FROM tblRouteCoverageStoreMapping RCM INNER JOIN #tmpRoutePlan TP ON
				TP.RouteID=RCM.RouteID AND TP.StoreID=RCM.StoreID WHERE TP.flgActive=1
				IF @FromDate<=GETDATE() AND @ToDate>GETDATE()
					SET @FromDate=GETDATE()
				INSERT INTO tblRouteCoverageStoreMapping(RouteID,StoreID,FromDate,ToDate,LoginIDIns)
				SELECT RouteID,StoreID,@FromDate,@ToDate,@LoginID FROM #tmpRoutePlan WHERE flgActive=2

			END
	END		
END






