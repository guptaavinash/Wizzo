

-- =============================================
-- Author:		Avinash Gupta
-- Create date: 09Apr2015
-- Description:	Sp to manage Person Mapping
-- =============================================
-- SpManagePersonMapping 2,13,41,'','','','','',3252,2
CREATE PROCEDURE [dbo].[SpManagePersonMapping]
	@SalesStructureNodeID INT,
	@SalesStructureNodeType INT,
	@PersonNodeID INT=0,
	@PersonType INT=0,
	@PersonName VARCHAR(400),
	@MobileNo VARCHAR(12),
	@EMail VARCHAR(50),
	@FromDate DATETIME,
	@ToDate DATETIME,
	@LoginID INT,
	@flgPersonMoved TINYINT,  -- 0=Not Moved,1=Moved
	@flgPersonType TINYINT, -- 1=Company ,2=Distributor
	@flgOtherLevelPerson TINYINT=0 -- 0=Assigned Person is from same level,1=Assigned Perosn is from Other Level.

AS
BEGIN
	DECLARE @MappedSalesStructureNodeID INT
	DECLARE @MappedSalesStructureNodeType INT
	--DECLARE @PersonType INT
	
	--IF @PersonNodeID>0
	--	SELECT @PersonType=NodeType FROM tblMstrPerson WHERE NodeID=@PersonNodeID
	--ELSE
	--	SELECT @PersonType=PersonType FROM tblPMSTNodeTypes WHERE NodeType=@SalesStructureNodeType
	IF @FromDate<=@ToDate AND EXISTS (SELECT 1 FROM tblSalesPersonMapping WHERE CAST(GETDATE() AS DATE) BETWEEN FromDate AND ToDate AND PersonNodeID=@PersonNodeID AND PersonType=@PersonType AND NodeID=@SalesStructureNodeID AND NodeType=@SalesStructureNodeType)
	BEGIN
		PRINT 'Inactive'
		UPDATE tblSalesPersonMapping SET ToDate=DATEADD(d,-1,@FromDate),LoginIDUpd=@LoginID,TimestampUpd=Getdate()
		WHERE PersonNodeID=@PersonNodeID AND PersonType=@PersonType AND NodeID=@SalesStructureNodeID AND NodeType=@SalesStructureNodeType AND @ToDate BETWEEN FromDate AND ToDate
	END

	
	IF @flgPersonMoved=1 AND @SalesStructureNodeType NOT IN (140,170) AND @SalesStructureNodeType IN (100,110,120,130)
	BEGIN
		--UPDATE tblSalesPersonMapping SET ToDate=DATEADD(d,-1,@FromDate)
		--WHERE PersonNodeID=@PersonNodeID AND NodeType IN (6,7) AND @FromDate BETWEEN FromDate AND ToDate
		--UPDATE tblSalesPersonMapping SET PersonNodeID=0 WHERE PersonNodeID=@PersonNodeID AND FromDate>@FromDate

		UPDATE tblSalesPersonMapping SET ToDate=DATEADD(d,-1,@FromDate),LoginIDUpd=@LoginID,TimestampUpd=Getdate()
		WHERE PersonNodeID=@PersonNodeID AND @FromDate BETWEEN FromDate AND ToDate
		--UPDATE tblSalesPersonMapping SET PersonNodeID=0,LoginIDUpd=@LoginID,TimestampUpd=Getdate() WHERE PersonNodeID=@PersonNodeID AND FromDate>@FromDate
	END
	IF @flgPersonMoved=2
	BEGIN
		UPDATE tblSalesPersonMapping SET ToDate=@FromDate,LoginIDUpd=@LoginID,TimestampUpd=Getdate() WHERE PersonNodeID=@PersonNodeID AND NodeID=@SalesStructureNodeID 
		AND NodeType=@SalesStructureNodeType  AND @FromDate BETWEEN FromDate AND ToDate
		--UPDATE tblSalesPersonMapping SET PersonNodeID=0,LoginIDUpd=@LoginID,TimestampUpd=Getdate()  WHERE NodeID=@SalesStructureNodeID 
		AND NodeType=@SalesStructureNodeType AND PersonNodeID=@PersonNodeID AND FromDate>@FromDate
	END
	--SELECT @PersonNodeID=PersonID FROM tblMstrPerson WHERE Personname=@PersonName AND PersonEMail=@EMail
	IF @SalesStructureNodeID=0
	BEGIN
		IF ISNULL(@PersonNodeID,0)=0
		BEGIN
			IF NOT EXISTS (SELECT 1 FROM tblMstrPerson WHERE Descr=@PersonName AND PersonEmailID=@EMail AND PersonPhone=@MobileNo)
			BEGIN
				INSERT INTO tblMstrPerson([Descr],[PersonEmailID],[PersonPhone],[FromDate],[ToDate],[LoginIDIns],[TimestampIns],NodeType,[flgCompanyPerson])
				SELECT @PersonName,@EMail,@MobileNo,@FromDate,@ToDate,@LoginID,GETDATE(),@PersonType,@flgPersonType
				SELECT @PersonNodeID=SCOPE_IDENTITY()
			END
			SELECT @PersonNodeID=NodeID FROM tblMstrPerson WHERE Descr=@PersonName AND PersonEmailID=@EMail AND PersonPhone=@MobileNo
		END
	END
	ELSE
	BEGIN
		IF ISNULL(@PersonNodeID,0)=0
		BEGIN
			IF NOT EXISTS (SELECT 1 FROM tblMstrPerson WHERE Descr=@PersonName AND PersonEmailID=@EMail AND PersonPhone=@MobileNo)
			BEGIN
				INSERT INTO tblMstrPerson([Descr],[PersonEmailID],[PersonPhone],[FromDate],[ToDate],[LoginIDIns],[TimestampIns],NodeType,[flgCompanyPerson])
				SELECT @PersonName,@EMail,@MobileNo,@FromDate,@ToDate,@LoginID,GETDATE(),@PersonType,@flgPersonType
				SELECT @PersonNodeID=SCOPE_IDENTITY()
			END
			SELECT @PersonNodeID=NodeID FROM tblMstrPerson WHERE Descr=@PersonName AND PersonEmailID=@EMail AND PersonPhone=@MobileNo
			
		END
		--################################  Wrinting Code For RoutePerson Mapping ##############################################################
		DECLARE @MinExistingFromDate DATETIME
		DECLARE @MaxExistingToDate DATETIME
		DECLARE @PreviousToDate DATETIME
		DECLARE @PreviousPersonID INT
		DECLARE @CountDistinctDates INT
		--- Assuming @FromDate will always be Greater or equal to Todays Date
		IF @FromDate>= CONVERT(VARCHAR(11),GETDATE(),112)
		BEGIN
			IF EXISTS (SELECT 1 FROM tblSalesPersonMapping SM WHERE NodeID=@SalesStructureNodeID AND NodeType=@SalesStructureNodeType AND ToDate>= GETDATE())
			BEGIN
				DELETE FROM tblSalesPersonMapping WHERE NodeID=@SalesStructureNodeID AND NodeType=@SalesStructureNodeType AND
				@FromDate<=FromDate AND @ToDate>=ToDate AND FromDate>=CONVERT(VARCHAR(11),GETDATE(),112)

				SELECT @MinExistingFromDate=MIN(FromDate) ,@MaxExistingToDate=MAX(ToDate),@CountDistinctDates=COUNT(DISTINCT ToDate) FROM tblSalesPersonMapping WHERE NodeID=@SalesStructureNodeID 
				AND NodeType=@SalesStructureNodeType AND  
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
						INSERT INTO tblSalesPersonMapping([PersonNodeID],[NodeID],[NodeType],[FromDate],[ToDate],[LoginIDIns],[TimestampIns],PersonType,flgOtherLevelPerson)
						SELECT @PersonNodeID,@SalesStructureNodeID,@SalesStructureNodeType,@FromDate,@ToDate,@LoginID,GETDATE(),@PersonType,@flgOtherLevelPerson
					END
					ELSE IF @FromDate=@MinExistingFromDate AND @ToDate=@MaxExistingToDate
					BEGIN
						PRINT 'Step 2'
						DELETE FROM tblSalesPersonMapping WHERE NodeID=@SalesStructureNodeID AND NodeType=@SalesStructureNodeType AND
						((@FromDate BETWEEN FromDate AND ToDate OR @ToDate BETWEEN FromDate AND ToDate) OR (FromDate BETWEEN @FromDate AND @ToDate OR ToDate BETWEEN @FromDate AND @ToDate))

						INSERT INTO tblSalesPersonMapping([PersonNodeID],[NodeID],[NodeType],[FromDate],[ToDate],[LoginIDIns],[TimestampIns],PersonType,flgOtherLevelPerson)
						SELECT @PersonNodeID,@SalesStructureNodeID,@SalesStructureNodeType,@FromDate,@ToDate,@LoginID,GETDATE(),@PersonType,@flgOtherLevelPerson

						----UPDATE tblSalesPersonMapping SET PersonNodeID=@PersonNodeID FROM tblSalesPersonMapping 
						----WHERE NodeID=@SalesStructureNodeID AND NodeType=@SalesStructureNodeType AND DATEDIFF(d,FromDate,@FromDate)=0 AND DATEDIFF(d,ToDate,@ToDate)=0
					END
					ELSE IF @FromDate<= @MinExistingFromDate AND @ToDate>=@MaxExistingToDate
					BEGIN
						PRINT 'Step 3'
						DELETE FROM tblSalesPersonMapping WHERE NodeID=@SalesStructureNodeID AND NodeType=@SalesStructureNodeType AND
						((@FromDate BETWEEN FromDate AND ToDate OR @ToDate BETWEEN FromDate AND ToDate) OR (FromDate BETWEEN @FromDate AND @ToDate OR ToDate BETWEEN @FromDate AND @ToDate))
						INSERT INTO tblSalesPersonMapping([PersonNodeID],[NodeID],[NodeType],[FromDate],[ToDate],[LoginIDIns],[TimestampIns],PersonType,flgOtherLevelPerson)
						SELECT @PersonNodeID,@SalesStructureNodeID,@SalesStructureNodeType,@FromDate,@ToDate,@LoginID,GETDATE(),@PersonType,@flgOtherLevelPerson
					END
					ELSE IF @FromDate<= @MinExistingFromDate AND @ToDate<@MaxExistingToDate
					BEGIN
						PRINT 'STEP 3.1'
						IF @CountDistinctDates=1
						BEGIN
											
							UPDATE  tblSalesPersonMapping SET FromDate=DATEADD(d,1,@ToDate),LoginIDUpd=@LoginID,TimestampUpd=Getdate() FROM tblSalesPersonMapping 
							WHERE NodeID=@SalesStructureNodeID AND NodeType=@SalesStructureNodeType AND @ToDate BETWEEN FromDate AND ToDate

							INSERT INTO tblSalesPersonMapping([PersonNodeID],[NodeID],[NodeType],[FromDate],[ToDate],[LoginIDIns],[TimestampIns],PersonType,flgOtherLevelPerson)
							SELECT @PersonNodeID,@SalesStructureNodeID,@SalesStructureNodeType,@FromDate,@ToDate,@LoginID,GETDATE(),@PersonType,@flgOtherLevelPerson
						END
						ELSE
						BEGIN
							UPDATE  tblSalesPersonMapping SET ToDate=DATEADD(d,-1,@FromDate),LoginIDUpd=@LoginID,TimestampUpd=Getdate() FROM tblSalesPersonMapping 
							WHERE NodeID=@SalesStructureNodeID AND NodeType=@SalesStructureNodeType AND ToDate<@FromDate AND ToDate>=CONVERT(VARCHAR(11),GETDATE(),112)
					
							UPDATE tblSalesPersonMapping SET PersonNodeID=@PersonNodeID,FromDate=@FromDate,LoginIDUpd=@LoginID,TimestampUpd=Getdate() FROM tblSalesPersonMapping 
							WHERE NodeID=@SalesStructureNodeID AND NodeType=@SalesStructureNodeType AND @ToDate BETWEEN FromDate AND ToDate
						END
								
						
					END
					ELSE IF @FromDate<@MinExistingFromDate AND @ToDate=@MaxExistingToDate
					BEGIN
						
						PRINT 'Step 4'
						IF @CountDistinctDates=1
						BEGIN
							PRINT 'Step X.1'				
							DELETE FROM tblSalesPersonMapping WHERE NodeID=@SalesStructureNodeID AND NodeType=@SalesStructureNodeType AND
							((@FromDate BETWEEN FromDate AND ToDate OR @ToDate BETWEEN FromDate AND ToDate) OR (FromDate BETWEEN @FromDate AND @ToDate OR ToDate BETWEEN @FromDate AND @ToDate))

							INSERT INTO tblSalesPersonMapping([PersonNodeID],[NodeID],[NodeType],[FromDate],[ToDate],[LoginIDIns],[TimestampIns],PersonType,flgOtherLevelPerson)
							SELECT @PersonNodeID,@SalesStructureNodeID,@SalesStructureNodeType,@FromDate,@ToDate,@LoginID,GETDATE(),@PersonType,@flgOtherLevelPerson
						END
					END
					ELSE IF @FromDate>@MinExistingFromDate AND @ToDate>=@MaxExistingToDate
					BEGIN
						PRINT 'Step 4'
						UPDATE tblSalesPersonMapping SET ToDate=DATEADD(d,-1,@FromDate),LoginIDUpd=@LoginID,TimestampUpd=Getdate() FROM tblSalesPersonMapping WHERE NodeID=@SalesStructureNodeID AND NodeType=@SalesStructureNodeType
						AND @FromDate BETWEEN FromDate AND ToDate
						DELETE FROM tblSalesPersonMapping WHERE NodeID=@SalesStructureNodeID AND NodeType=@SalesStructureNodeType 
						AND (FromDate>ToDate OR (FromDate>@FromDate AND ToDate<=@ToDate))
						INSERT INTO tblSalesPersonMapping([PersonNodeID],[NodeID],[NodeType],[FromDate],[ToDate],[LoginIDIns],[TimestampIns],PersonType,flgOtherLevelPerson)
						SELECT @PersonNodeID,@SalesStructureNodeID,@SalesStructureNodeType,@FromDate,@ToDate,@LoginID,GETDATE(),@PersonType,@flgOtherLevelPerson
					END
					ELSE IF @FromDate>@MinExistingFromDate AND @ToDate< @MaxExistingToDate
					BEGIN
						PRINT 'Step 5'
						IF @CountDistinctDates=1
						BEGIN
							PRINT 'Step 5.1'
							SELECT @PreviousToDate=ToDate,@PreviousPersonID=PersonNodeID FROM tblSalesPersonMapping WHERE NodeID=@SalesStructureNodeID AND NodeType=@SalesStructureNodeType
							AND @FromDate BETWEEN FromDate AND ToDate
							UPDATE tblSalesPersonMapping SET ToDate=DATEADD(d,-1,@FromDate),LoginIDUpd=@LoginID,TimestampUpd=Getdate() FROM tblSalesPersonMapping WHERE NodeID=@SalesStructureNodeID AND NodeType=@SalesStructureNodeType
							AND @FromDate BETWEEN FromDate AND ToDate
							IF @PreviousToDate>@ToDate
							BEGIN
								INSERT INTO tblSalesPersonMapping([PersonNodeID],[NodeID],[NodeType],[FromDate],[ToDate],[LoginIDIns],[TimestampIns],PersonType,flgOtherLevelPerson)
								SELECT @PreviousPersonID,@SalesStructureNodeID,@SalesStructureNodeType,DATEADD(d,1,@ToDate),@PreviousToDate,@LoginID,GETDATE(), @PersonType,@flgOtherLevelPerson
							END
						END
						ELSE IF @CountDistinctDates>1
						BEGIN
							PRINT 'Step 5.2'
							SELECT @PreviousToDate=ToDate  FROM tblSalesPersonMapping WHERE NodeID=@SalesStructureNodeID AND NodeType=@SalesStructureNodeType
							AND @ToDate BETWEEN FromDate AND ToDate
							UPDATE tblSalesPersonMapping SET ToDate=DATEADD(d,-1,@FromDate),LoginIDUpd=@LoginID,TimestampUpd=Getdate() FROM tblSalesPersonMapping WHERE NodeID=@SalesStructureNodeID AND NodeType=@SalesStructureNodeType
							AND @FromDate BETWEEN FromDate AND ToDate
							UPDATE tblSalesPersonMapping SET FromDate=DATEADD(d,1,@ToDate),LoginIDUpd=@LoginID,TimestampUpd=Getdate() FROM tblSalesPersonMapping WHERE NodeID=@SalesStructureNodeID AND NodeType=@SalesStructureNodeType
							AND @ToDate BETWEEN FromDate AND ToDate
						END

						--UPDATE tblSalesPersonMapping SET ToDate=DATEADD(d,-1,@FromDate) FROM tblSalesPersonMapping WHERE NodeID=@SalesStructureNodeID AND NodeType=@SalesStructureNodeType
						--AND @FromDate BETWEEN FromDate AND ToDate
						--UPDATE tblSalesPersonMapping SET FromDate=@ToDate FROM tblSalesPersonMapping WHERE NodeID=@SalesStructureNodeID AND NodeType=@SalesStructureNodeType
						--AND @ToDate BETWEEN FromDate AND ToDate
						INSERT INTO tblSalesPersonMapping([PersonNodeID],[NodeID],[NodeType],[FromDate],[ToDate],[LoginIDIns],[TimestampIns],PersonType,flgOtherLevelPerson)
						SELECT @PersonNodeID,@SalesStructureNodeID,@SalesStructureNodeType,@FromDate,@ToDate,@LoginID,GETDATE(),@PersonType,@flgOtherLevelPerson

						----INSERT INTO tblSalesPersonMapping([PersonNodeID],[NodeID],[NodeType],[FromDate],[ToDate],[LoginIDIns],[TimestampIns])
						----SELECT @PreviousPersonID,@SalesStructureNodeID,@SalesStructureNodeType,DATEADD(d,1,@ToDate),@PreviousToDate,@LoginID,GETDATE()

					END
					ELSE IF @FromDate=@MinExistingFromDate AND @ToDate< @MaxExistingToDate
					BEGIN
						PRINT 'Step 6'
						UPDATE tblSalesPersonMapping SET FromDate=DATEADD(d,-1,@ToDate),LoginIDUpd=@LoginID,TimestampUpd=Getdate() FROM tblSalesPersonMapping WHERE NodeID=@SalesStructureNodeID AND NodeType=@SalesStructureNodeType
						AND @FromDate BETWEEN FromDate AND ToDate
						INSERT INTO tblSalesPersonMapping([PersonNodeID],[NodeID],[NodeType],[FromDate],[ToDate],[LoginIDIns],[TimestampIns],PersonType,flgOtherLevelPerson)
						SELECT @PersonNodeID,@SalesStructureNodeID,@SalesStructureNodeType,@FromDate,@ToDate,@LoginID,GETDATE(),@PersonType,@flgOtherLevelPerson
					END
					ELSE IF @FromDate>@MinExistingFromDate AND @ToDate>@MaxExistingToDate
					BEGIN
						PRINT 'Step 7'
						UPDATE tblSalesPersonMapping SET ToDate=DATEADD(d,-1,@FromDate) FROM tblSalesPersonMapping WHERE NodeID=@SalesStructureNodeID AND NodeType=@SalesStructureNodeType
						AND @FromDate BETWEEN FromDate AND ToDate
						DELETE FROM tblSalesPersonMapping WHERE NodeID=@SalesStructureNodeID AND NodeType=@SalesStructureNodeType AND FromDate>@FromDate
						INSERT INTO tblSalesPersonMapping([PersonNodeID],[NodeID],[NodeType],[FromDate],[ToDate],[LoginIDIns],[TimestampIns],PersonType,flgOtherLevelPerson)
						SELECT @PersonNodeID,@SalesStructureNodeID,@SalesStructureNodeType,@FromDate,@ToDate,@LoginID,GETDATE(),@PersonType,@flgOtherLevelPerson
					END
				END
				ELSE
				BEGIN
					IF EXISTS (SELECT 1 FROM tblSalesPersonMapping WHERE NodeID=@SalesStructureNodeID AND NodeType=@SalesStructureNodeType AND  
					(FromDate BETWEEN @FromDate AND @ToDate OR ToDate BETWEEN @FromDate AND @ToDate))
					BEGIN
						DELETE FROM tblSalesPersonMapping WHERE NodeID=@SalesStructureNodeID AND NodeType=@SalesStructureNodeType AND
						((@FromDate BETWEEN FromDate AND ToDate OR @ToDate BETWEEN FromDate AND ToDate) OR (FromDate BETWEEN @FromDate AND @ToDate OR ToDate BETWEEN @FromDate AND @ToDate)) 
					END
					INSERT INTO tblSalesPersonMapping([PersonNodeID],[NodeID],[NodeType],[FromDate],[ToDate],[LoginIDIns],[TimestampIns],PersonType,flgOtherLevelPerson)
					SELECT @PersonNodeID,@SalesStructureNodeID,@SalesStructureNodeType,@FromDate,@ToDate,@LoginID,GETDATE(),@PersonType,@flgOtherLevelPerson
				END
				
			END
			ELSE
			BEGIN
				INSERT INTO tblSalesPersonMapping([PersonNodeID],[NodeID],[NodeType],[FromDate],[ToDate],[LoginIDIns],[TimestampIns],PersonType,flgOtherLevelPerson)
				SELECT @PersonNodeID,@SalesStructureNodeID,@SalesStructureNodeType,@FromDate,@ToDate,@LoginID,GETDATE(),@PersonType,@flgOtherLevelPerson
			END
			--##########################################################################################################################################
		END
		
	END
	IF @PersonNodeID <>0 AND ISNULL(@PersonName,'')<>''
	BEGIN
		UPDATE tblMstrPerson SET PersonEmailID=@EMail,PersonPhone=@MobileNo,Descr=@PersonName WHERE NodeID=@PersonNodeID
	END
	IF @flgPersonMoved=1
	BEGIN
		DELETE FROM tblSalesPersonMapping WHERE PersonNodeID=@PersonNodeID AND FromDate>ToDate
	END
	SELECT @PersonNodeID PersonID
	DECLARE @flgMapped TINYINT
	DECLARE @DHNodeID INT
	DECLARE @DHNodeType INT
	SET @flgMapped=0
	SET @DHNodeID=0
	SET @DHNodeType=0
	DECLARE @HierTypeID INT
	SELECT @HierTypeID=HierTypeID FROM tblpmstnodetypes WHERE NodeType=@SalesStructureNodeType

	SELECT @flgMapped=1,@DHNodeID=DHNodeID,@DHNodeType=DHNodeType FROM tblCompanySalesStructure_DistributorMapping WHERE SHNodeID=@SalesStructureNodeID AND SHNodetype=@SalesStructureNodeType 
	AND GETDATE() BETWEEN FROMDATE AND TODATE

	IF @HierTypeID=5
		SELECT @flgMapped flgMapped,@DHNodeID DHNodeID,@DHNodeType DHNodeType
	ELSE
		SELECT 1 flgMapped,0 DHNodeID,0 DHNodeType
END






