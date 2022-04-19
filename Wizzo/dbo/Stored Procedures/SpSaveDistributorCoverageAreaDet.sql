-- =============================================
-- Author:		Avinash Gupta
-- Create date: 28-Sep-2015
-- Description:	Sp to save the distributor coverage Area Detail
-- =============================================
CREATE PROCEDURE [dbo].[SpSaveDistributorCoverageAreaDet] 
	@DHNodeID INT,   -- Distributor Coverage Area DHNodeID from tblDBRSalesStructureCoverage
	@DHNodeType TINYINT,  -- DHNodeType of the Distributor Coverage Area (10)
	@SHNodeID INT,
	@SHNodeType TINYINT,
	@FromDate Date,
	@ToDate Date,
	@LoginID INT,
	@flgSup TINYINT
AS
BEGIN
	--################################  Wrinting Code For RoutePerson Mapping ##############################################################
		DECLARE @MinExistingFromDate DATETIME
		DECLARE @MaxExistingToDate DATETIME
		DECLARE @PreviousToDate DATETIME
		DECLARE @PreviousSHID INT
		DECLARE @PreviousSHNodeType TINYINT
		DECLARE @CountDistinctDates INT
		--- Assuming @FromDate will always be Greater or equal to Todays Date
		IF @FromDate>= CONVERT(VARCHAR(11),GETDATE(),112)
		BEGIN
			IF EXISTS (SELECT 1 FROM tblCompanySalesStructure_DistributorMapping SM WHERE DHNodeID=@DHNodeID AND DHNodeType=@DHNodeType AND ToDate>= GETDATE())
			BEGIN
				DELETE FROM tblCompanySalesStructure_DistributorMapping WHERE DHNodeID=@DHNodeID AND DHNodeType=@DHNodeType AND
				@FromDate<=FromDate AND @ToDate>=ToDate AND FromDate>=CONVERT(VARCHAR(11),GETDATE(),112)

				SELECT @MinExistingFromDate=MIN(FromDate) ,@MaxExistingToDate=MAX(ToDate),@CountDistinctDates=COUNT(DISTINCT ToDate) FROM tblCompanySalesStructure_DistributorMapping WHERE DHNodeID=@DHNodeID 
				AND DHNodeType=@DHNodeType AND  
				(@FromDate BETWEEN FromDate AND ToDate OR @ToDate BETWEEN FromDate AND ToDate) --OR (FromDate BETWEEN @FromDate AND @ToDate OR ToDate BETWEEN @FromDate AND @ToDate))
				AND ToDate> GETDATE()	

				SELECT @MinExistingFromDate=ISNULL(@MinExistingFromDate,@FromDate)
				SELECT @MaxExistingToDate=ISNULL(@MaxExistingToDate,@ToDate)
				PRINT '@MinExistingFromDate' + CAST(@MinExistingFromDate AS VARCHAR)
				PRINT '@MaxExistingToDate' + CAST(@MaxExistingToDate AS VARCHAR)
				PRINT '@CountDistinctDates=' + CAST(@CountDistinctDates AS VARCHAR)

				IF @CountDistinctDates>0
				BEGIN
					IF @FromDate>@MaxExistingToDate 
					BEGIN
						PRINT 'Step 1'
						INSERT INTO tblCompanySalesStructure_DistributorMapping(SHNodeID,[DHNodeID],[DHNodeType],[FromDate],[ToDate],[LoginIDIns],[TimestampIns],SHNodeType,flgSup)
						SELECT @SHNodeID,@DHNodeID,@DHNodeType,@FromDate,@ToDate,@LoginID,GETDATE(),@SHNodeType,@flgSup
					END
					ELSE IF @FromDate=@MinExistingFromDate AND @ToDate=@MaxExistingToDate
					BEGIN
						PRINT 'Step 2'
						DELETE FROM tblCompanySalesStructure_DistributorMapping WHERE DHNodeID=@DHNodeID AND DHNodeType=@DHNodeType AND
						((@FromDate BETWEEN FromDate AND ToDate OR @ToDate BETWEEN FromDate AND ToDate) OR (FromDate BETWEEN @FromDate AND @ToDate OR ToDate BETWEEN @FromDate AND @ToDate))

						INSERT INTO tblCompanySalesStructure_DistributorMapping(SHNodeID,[DHNodeID],[DHNodeType],[FromDate],[ToDate],[LoginIDIns],[TimestampIns],SHNodeType,flgSup)
						SELECT @SHNodeID,@DHNodeID,@DHNodeType,@FromDate,@ToDate,@LoginID,GETDATE(),@SHNodeType,@flgSup

						----UPDATE tblCompanySalesStructure_DistributorMapping SET SHNodeID=@SHNodeID FROM tblCompanySalesStructure_DistributorMapping 
						----WHERE DHNodeID=@DHNodeID AND DHNodeType=@DHNodeType AND DATEDIFF(d,FromDate,@FromDate)=0 AND DATEDIFF(d,ToDate,@ToDate)=0
					END
					ELSE IF @FromDate<= @MinExistingFromDate AND @ToDate>=@MaxExistingToDate
					BEGIN
						PRINT 'Step 3'
						DELETE FROM tblCompanySalesStructure_DistributorMapping WHERE DHNodeID=@DHNodeID AND DHNodeType=@DHNodeType AND
						((@FromDate BETWEEN FromDate AND ToDate OR @ToDate BETWEEN FromDate AND ToDate) OR (FromDate BETWEEN @FromDate AND @ToDate OR ToDate BETWEEN @FromDate AND @ToDate))
						INSERT INTO tblCompanySalesStructure_DistributorMapping(SHNodeID,[DHNodeID],[DHNodeType],[FromDate],[ToDate],[LoginIDIns],[TimestampIns],SHNodeType,flgSup)
						SELECT @SHNodeID,@DHNodeID,@DHNodeType,@FromDate,@ToDate,@LoginID,GETDATE(),@SHNodeType,@flgSup
					END
					ELSE IF @FromDate<= @MinExistingFromDate AND @ToDate<@MaxExistingToDate
					BEGIN
						PRINT 'STEP 3.1'
						IF @CountDistinctDates=1
						BEGIN
											
							UPDATE  tblCompanySalesStructure_DistributorMapping SET FromDate=DATEADD(d,1,@ToDate) FROM tblCompanySalesStructure_DistributorMapping 
							WHERE DHNodeID=@DHNodeID AND DHNodeType=@DHNodeType AND @ToDate BETWEEN FromDate AND ToDate

							INSERT INTO tblCompanySalesStructure_DistributorMapping(SHNodeID,[DHNodeID],[DHNodeType],[FromDate],[ToDate],[LoginIDIns],[TimestampIns],SHNodeType,flgSup)
							SELECT @SHNodeID,@DHNodeID,@DHNodeType,@FromDate,@ToDate,@LoginID,GETDATE(),@SHNodeType,@flgSup
						END
						ELSE
						BEGIN
							UPDATE  tblCompanySalesStructure_DistributorMapping SET ToDate=DATEADD(d,-1,@FromDate) FROM tblCompanySalesStructure_DistributorMapping 
							WHERE DHNodeID=@DHNodeID AND DHNodeType=@DHNodeType AND ToDate<@FromDate AND ToDate>=CONVERT(VARCHAR(11),GETDATE(),112)
					
							UPDATE tblCompanySalesStructure_DistributorMapping SET SHNodeID=@SHNodeID,FromDate=@FromDate FROM tblCompanySalesStructure_DistributorMapping 
							WHERE DHNodeID=@DHNodeID AND DHNodeType=@DHNodeType AND @ToDate BETWEEN FromDate AND ToDate
						END
								
						
					END
					ELSE IF @FromDate<@MinExistingFromDate AND @ToDate=@MaxExistingToDate
					BEGIN
						
						PRINT 'Step 4'
						IF @CountDistinctDates=1
						BEGIN
							PRINT 'Step X.1'				
							DELETE FROM tblCompanySalesStructure_DistributorMapping WHERE DHNodeID=@DHNodeID AND DHNodeType=@DHNodeType AND
							((@FromDate BETWEEN FromDate AND ToDate OR @ToDate BETWEEN FromDate AND ToDate) OR (FromDate BETWEEN @FromDate AND @ToDate OR ToDate BETWEEN @FromDate AND @ToDate))

							INSERT INTO tblCompanySalesStructure_DistributorMapping(SHNodeID,[DHNodeID],[DHNodeType],[FromDate],[ToDate],[LoginIDIns],[TimestampIns],SHNodeType,flgSup)
							SELECT @SHNodeID,@DHNodeID,@DHNodeType,@FromDate,@ToDate,@LoginID,GETDATE(),@SHNodeType,@flgSup
						END
					END
					ELSE IF @FromDate>@MinExistingFromDate AND @ToDate>=@MaxExistingToDate
					BEGIN
						PRINT 'Step 4'
						UPDATE tblCompanySalesStructure_DistributorMapping SET ToDate=DATEADD(d,-1,@FromDate) FROM tblCompanySalesStructure_DistributorMapping WHERE DHNodeID=@DHNodeID AND DHNodeType=@DHNodeType
						AND @FromDate BETWEEN FromDate AND ToDate
						DELETE FROM tblCompanySalesStructure_DistributorMapping WHERE DHNodeID=@DHNodeID AND DHNodeType=@DHNodeType 
						AND (FromDate>ToDate OR (FromDate>@FromDate AND ToDate<=@ToDate))
						INSERT INTO tblCompanySalesStructure_DistributorMapping(SHNodeID,[DHNodeID],[DHNodeType],[FromDate],[ToDate],[LoginIDIns],[TimestampIns],SHNodeType,flgSup)
						SELECT @SHNodeID,@DHNodeID,@DHNodeType,@FromDate,@ToDate,@LoginID,GETDATE(),@SHNodeType,@flgSup
					END
					ELSE IF @FromDate>@MinExistingFromDate AND @ToDate< @MaxExistingToDate
					BEGIN
						PRINT 'Step 5'
						IF @CountDistinctDates=1
						BEGIN
							PRINT 'Step 5.1'
							SELECT @PreviousToDate=ToDate,@PreviousSHID=SHNodeID,@PreviousSHNodeType=SHNodeType FROM tblCompanySalesStructure_DistributorMapping WHERE DHNodeID=@DHNodeID AND DHNodeType=@DHNodeType
							AND @FromDate BETWEEN FromDate AND ToDate
							UPDATE tblCompanySalesStructure_DistributorMapping SET ToDate=DATEADD(d,-1,@FromDate) FROM tblCompanySalesStructure_DistributorMapping WHERE DHNodeID=@DHNodeID AND DHNodeType=@DHNodeType
							AND @FromDate BETWEEN FromDate AND ToDate
							IF @PreviousToDate>@ToDate
							BEGIN
								INSERT INTO tblCompanySalesStructure_DistributorMapping(SHNodeID,SHNodeType,[DHNodeID],[DHNodeType],[FromDate],[ToDate],[LoginIDIns],[TimestampIns],flgSup)
								SELECT @PreviousSHID,@PreviousSHNodeType,@DHNodeID,@DHNodeType,DATEADD(d,1,@ToDate),@PreviousToDate,@LoginID,GETDATE(),@flgSup
							END
						END
						ELSE IF @CountDistinctDates>1
						BEGIN
							PRINT 'Step 5.2'
							SELECT @PreviousToDate=ToDate  FROM tblCompanySalesStructure_DistributorMapping WHERE DHNodeID=@DHNodeID AND DHNodeType=@DHNodeType
							AND @ToDate BETWEEN FromDate AND ToDate
							UPDATE tblCompanySalesStructure_DistributorMapping SET ToDate=DATEADD(d,-1,@FromDate) FROM tblCompanySalesStructure_DistributorMapping WHERE DHNodeID=@DHNodeID AND DHNodeType=@DHNodeType
							AND @FromDate BETWEEN FromDate AND ToDate
							UPDATE tblCompanySalesStructure_DistributorMapping SET FromDate=DATEADD(d,1,@ToDate) FROM tblCompanySalesStructure_DistributorMapping WHERE DHNodeID=@DHNodeID AND DHNodeType=@DHNodeType
							AND @ToDate BETWEEN FromDate AND ToDate
						END

						--UPDATE tblCompanySalesStructure_DistributorMapping SET ToDate=DATEADD(d,-1,@FromDate) FROM tblCompanySalesStructure_DistributorMapping WHERE DHNodeID=@DHNodeID AND DHNodeType=@DHNodeType
						--AND @FromDate BETWEEN FromDate AND ToDate
						--UPDATE tblCompanySalesStructure_DistributorMapping SET FromDate=@ToDate FROM tblCompanySalesStructure_DistributorMapping WHERE DHNodeID=@DHNodeID AND DHNodeType=@DHNodeType
						--AND @ToDate BETWEEN FromDate AND ToDate
						INSERT INTO tblCompanySalesStructure_DistributorMapping(SHNodeID,[DHNodeID],[DHNodeType],[FromDate],[ToDate],[LoginIDIns],[TimestampIns],SHNodeType,flgSup)
						SELECT @SHNodeID,@DHNodeID,@DHNodeType,@FromDate,@ToDate,@LoginID,GETDATE(),@SHNodeType,@flgSup

						----INSERT INTO tblCompanySalesStructure_DistributorMapping(SHNodeID,[DHNodeID],[DHNodeType],[FromDate],[ToDate],[LoginIDIns],[TimestampIns])
						----SELECT @PreviousPersonID,@DHNodeID,@DHNodeType,DATEADD(d,1,@ToDate),@PreviousToDate,@LoginID,GETDATE()

					END
					ELSE IF @FromDate=@MinExistingFromDate AND @ToDate< @MaxExistingToDate
					BEGIN
						PRINT 'Step 6'
						UPDATE tblCompanySalesStructure_DistributorMapping SET FromDate=DATEADD(d,-1,@ToDate) FROM tblCompanySalesStructure_DistributorMapping WHERE DHNodeID=@DHNodeID AND DHNodeType=@DHNodeType
						AND @FromDate BETWEEN FromDate AND ToDate
						INSERT INTO tblCompanySalesStructure_DistributorMapping(SHNodeID,[DHNodeID],[DHNodeType],[FromDate],[ToDate],[LoginIDIns],[TimestampIns],SHNodeType,flgSup)
						SELECT @SHNodeID,@DHNodeID,@DHNodeType,@FromDate,@ToDate,@LoginID,GETDATE(),@SHNodeType,@flgSup
					END
					ELSE IF @FromDate>@MinExistingFromDate AND @ToDate>@MaxExistingToDate
					BEGIN
						PRINT 'Step 7'
						UPDATE tblCompanySalesStructure_DistributorMapping SET ToDate=DATEADD(d,-1,@FromDate) FROM tblCompanySalesStructure_DistributorMapping WHERE DHNodeID=@DHNodeID AND DHNodeType=@DHNodeType
						AND @FromDate BETWEEN FromDate AND ToDate
						DELETE FROM tblCompanySalesStructure_DistributorMapping WHERE DHNodeID=@DHNodeID AND DHNodeType=@DHNodeType AND FromDate>@FromDate
						INSERT INTO tblCompanySalesStructure_DistributorMapping(SHNodeID,[DHNodeID],[DHNodeType],[FromDate],[ToDate],[LoginIDIns],[TimestampIns],SHNodeType,flgSup)
						SELECT @SHNodeID,@DHNodeID,@DHNodeType,@FromDate,@ToDate,@LoginID,GETDATE(),@SHNodeType,@flgSup
					END
				END
				ELSE
				BEGIN
					IF EXISTS (SELECT 1 FROM tblCompanySalesStructure_DistributorMapping WHERE DHNodeID=@DHNodeID AND DHNodeType=@DHNodeType AND  
					(FromDate BETWEEN @FromDate AND @ToDate OR ToDate BETWEEN @FromDate AND @ToDate))
					BEGIN
						DELETE FROM tblCompanySalesStructure_DistributorMapping WHERE DHNodeID=@DHNodeID AND DHNodeType=@DHNodeType AND
						((@FromDate BETWEEN FromDate AND ToDate OR @ToDate BETWEEN FromDate AND ToDate) OR (FromDate BETWEEN @FromDate AND @ToDate OR ToDate BETWEEN @FromDate AND @ToDate)) 
					END
					INSERT INTO tblCompanySalesStructure_DistributorMapping(SHNodeID,[DHNodeID],[DHNodeType],[FromDate],[ToDate],[LoginIDIns],[TimestampIns],SHNodeType,flgSup)
					SELECT @SHNodeID,@DHNodeID,@DHNodeType,@FromDate,@ToDate,@LoginID,GETDATE(),@SHNodeType,@flgSup
				END
				
			END
			ELSE
			BEGIN
				INSERT INTO tblCompanySalesStructure_DistributorMapping(SHNodeID,[DHNodeID],[DHNodeType],[FromDate],[ToDate],[LoginIDIns],[TimestampIns],SHNodeType,flgSup)
				SELECT @SHNodeID,@DHNodeID,@DHNodeType,@FromDate,@ToDate,@LoginID,GETDATE(),@SHNodeType,@flgSup
			END
			--##########################################################################################################################################
		END
	
	--Added By Alok on 15-May to populate  tblDBR_LiveMarking which is list of DBR with coverage area under 
	----TRUNCATE TABLE tblDBR_LiveMarking
	----INSERT INTO tblDBR_LiveMarking
	----SELECT DISTINCT PHierId
	----FROM   tblCompanySalesStructureHierarchy
	----WHERE (PNodeType = 150)
	----INSERT INTO tblDBR_LiveMarking
	----SELECT DISTINCT HierId
	----FROM   tblCompanySalesStructureHierarchy
	----WHERE (PNodeType = 150)
	----INSERT INTO tblDBR_LiveMarking
	----SELECT DISTINCT HierId
	----FROM   tblCompanySalesStructureHierarchy
	----WHERE (PNodeType = 160)
	
END

