-- =============================================
-- Author:		Avinash
-- Create date: 17-Mar-2021
-- Description:	
-- =============================================
-- [SPTargetDataImport] 6,2021,4,2021
CREATE PROCEDURE [dbo].[SPTargetDataImport] 
	@month INT,
	@year INT,
	@SettingCopymonth INT,
	@SettingCopyYear INT
	
AS
BEGIN
	DECLARE @TimePeriodKey INT 
	SELECT @TimePeriodKey=@year * 100 + @month
	DECLARE @SettingCopyTimePeriodKey INT 
	SELECT @SettingCopyTimePeriodKey=@SettingCopyYear * 100 + @SettingCopymonth

	DECLARE @SettingCopyTimePeriodNOdeID INT,@SettingCopyTimePeriodNodeType SMALLINT
	SELECT @SettingCopyTimePeriodNOdeID=TimePeriodNOdeID,@SettingCopyTimePeriodNodeType=TimePeriodNodeType FROM tblTargetTimePeriodMstr WHERE TimePeriodKey=@SettingCopyTimePeriodKey

	DECLARE @TimePeriodNOdeID INT,@TimePeriodNodeType SMALLINT
	SELECT @TimePeriodNOdeID=TimePeriodNOdeID,@TimePeriodNodeType=TimePeriodNodeType FROM tblTargetTimePeriodMstr WHERE TimePeriodKey=@TimePeriodKey

	CREATE TABLE #tblTargetMeasureCriteria(TgtMeasureCrtraID INT,TimePeriodNodeId INT,TimePeriodNodeType INT,TgtMeasureID INT,TgtMeasureName VARCHAR(200),IsStoreLevel BIT,IsProductLevel BIT,IsMeasureAggregated BIT,AggregatedLevel TINYINT,IsPercentage BIT)


	INSERT INTO #tblTargetMeasureCriteria
	SELECT * FROM tblTargetMeasureCriteria WHERE TimePeriodNodeId=@TimePeriodNOdeID AND TimePeriodNodeType=@TimePeriodNodeType

	---Copy the settings
	IF NOT EXISTS (SELECT 1 FROM #tblTargetMeasureCriteria)
	BEGIN
		INSERT INTO tblTargetMeasureCriteria(TimePeriodNodeId,TimePeriodNodeType,TgtMeasureID,TgtMeasureName,IsStoreLevel,IsProductLevel,IsMeasureAggregated,AggregatedLevel,IsPercentage)
		SELECT @TimePeriodNOdeID,@TimePeriodNodeType,TgtMeasureID,TgtMeasureName,IsStoreLevel,IsProductLevel,IsMeasureAggregated,AggregatedLevel,IsPercentage FROM tblTargetMeasureCriteria WHERE TimePeriodNodeId=@SettingCopyTimePeriodNOdeID AND TimePeriodNodeType=@SettingCopyTimePeriodNodeType

		SELECT C.* INTO #OldConfig FROM tblTargetMeasureCriteriaDepMeasure C INNER JOIN tblTargetMeasureCriteria M ON M.TgtMeasureCrtraID=C.TgtMeasureCrtraID WHERE M.TimePeriodNodeId=@SettingCopyTimePeriodNOdeID AND M.TimePeriodNodeType=@SettingCopyTimePeriodNodeType

		DELETE FROM tblTargetMeasureCriteriaDepMeasure WHERE TgtMeasureCrtraID NOT IN (SELECT TgtMeasureCrtraID FROM tblTargetMeasureCriteria)
		INSERT INTO tblTargetMeasureCriteriaDepMeasure(TgtMeasureCrtraID,Depto_TgtMeasureCrtraID)
		SELECT DISTINCT New_PC.TgtMeasureCrtraID,New_CC.TgtMeasureCrtraID FROM #OldConfig O INNER JOIN tblTargetMeasureCriteria Old_PC ON Old_PC.TgtMeasureCrtraID=O.TgtMeasureCrtraID INNER JOIN tblTargetMeasureCriteria New_PC ON New_PC.TgtMeasureID=Old_PC.TgtMeasureID INNER JOIN tblTargetMeasureCriteria Old_CC ON Old_CC.TgtMeasureCrtraID=O.Depto_TgtMeasureCrtraID INNER JOIN tblTargetMeasureCriteria New_CC ON New_CC.TgtMeasureID=Old_CC.TgtMeasureID 
		WHERE New_PC.TimePeriodNodeId=@TimePeriodNOdeID AND New_PC.TimePeriodNodeType=@TimePeriodNodeType 

		--- Delete duplicate record
		;WITH CTEA(ID,TgtMeasureCrtraID,Depto_TgtMeasureCrtraID) AS
		(
		SELECT ROW_NUMBER() OVER (partition BY TgtMeasureCrtraID,Depto_TgtMeasureCrtraID ORDER BY TgtMeasureCrtraID,Depto_TgtMeasureCrtraID) ID,TgtMeasureCrtraID,Depto_TgtMeasureCrtraID FROM tblTargetMeasureCriteriaDepMeasure
	
		)
		DELETE FROM CTEA WHERE ID>1
			   	
		--- Target Attribute Copy
		SELECT C.* INTO #OldAttConfig FROM tblTargetMeasureAttributeMapping C INNER JOIN tblTargetMeasureCriteria M ON M.TgtMeasureCrtraID=C.TgtMeasureCrtraID WHERE M.TimePeriodNodeId=@SettingCopyTimePeriodNOdeID AND M.TimePeriodNodeType=@SettingCopyTimePeriodNodeType


		DELETE FROM tblTargetMeasureAttributeMapping WHERE TgtMeasureCrtraID NOT IN (SELECT TgtMeasureCrtraID FROM tblTargetMeasureCriteria)
		INSERT INTO tblTargetMeasureAttributeMapping(TgtMeasureID,TgtMeasureCrtraID,NodeID,NodeType)
		SELECT O.TgtMeasureID,New_PC.TgtMeasureCrtraID,O.NodeID,O.NodeType FROM #OldAttConfig O INNER JOIN tblTargetMeasureCriteria New_PC ON New_PC.TgtMeasureID=O.TgtMeasureID 
		WHERE New_PC.TimePeriodNodeId=@TimePeriodNOdeID AND New_PC.TimePeriodNodeType=@TimePeriodNodeType

	END

	DELETE FROM #tblTargetMeasureCriteria
	INSERT INTO #tblTargetMeasureCriteria
	SELECT * FROM tblTargetMeasureCriteria WHERE TimePeriodNodeId=@TimePeriodNOdeID AND TimePeriodNodeType=@TimePeriodNodeType

	--SELECT * FROM #tblTargetMeasureCriteria

	INSERT INTO tblTargetMstr(TgtMeasureCrtraID,LoginIDIns,TimeStampIns)
	SELECT DISTINCT C.TgtMeasureCrtraID,1,GETDATE() FROM #tblTargetMeasureCriteria C LEFT OUTER JOIN tblTargetMstr T ON T.TgtMeasureCrtraID=C.TgtMeasureCrtraID WHERE T.TgtMstrID IS NULL

	DELETE D FROM tblTargetDet D INNER JOIN tblTargetMstr M ON M.TgtMstrID=D.TgtMstrId INNER JOIN #tblTargetMeasureCriteria C ON C.TgtMeasureCrtraID=M.TgtMeasureCrtraID


	INSERT INTO tblTargetDet(TgtMstrId,SalesmanNodeId,SalesmanNodeType,AreaNodeId,AreaNodeType,TargetVal,LoginIDIns)
	SELECT DISTINCT M.TgtMstrID,SalesmanNodeID,SalesmanNodeType,CovAreaNodeID,CovAreaNodeType,[UBO Target],1 FROM tblTargetDataImport CROSS JOIN tblTargetMstr M INNER JOIN #tblTargetMeasureCriteria C ON C.TgtMeasureCrtraID=M.TgtMeasureCrtraID WHERE C.TgtMeasureID=1

	INSERT INTO tblTargetDet(TgtMstrId,SalesmanNodeId,SalesmanNodeType,AreaNodeId,AreaNodeType,TargetVal,LoginIDIns)
	SELECT DISTINCT M.TgtMstrID,SalesmanNodeID,SalesmanNodeType,CovAreaNodeID,CovAreaNodeType,[EC],1 FROM tblTargetDataImport CROSS JOIN tblTargetMstr M INNER JOIN #tblTargetMeasureCriteria C ON C.TgtMeasureCrtraID=M.TgtMeasureCrtraID WHERE C.TgtMeasureID=2

	INSERT INTO tblTargetDet(TgtMstrId,SalesmanNodeId,SalesmanNodeType,AreaNodeId,AreaNodeType,TargetVal,LoginIDIns)
	SELECT DISTINCT M.TgtMstrID,SalesmanNodeID,SalesmanNodeType,CovAreaNodeID,CovAreaNodeType,[PC],1 FROM tblTargetDataImport CROSS JOIN tblTargetMstr M INNER JOIN #tblTargetMeasureCriteria C ON C.TgtMeasureCrtraID=M.TgtMeasureCrtraID WHERE C.TgtMeasureID=3

	INSERT INTO tblTargetDet(TgtMstrId,SalesmanNodeId,SalesmanNodeType,AreaNodeId,AreaNodeType,TargetVal,LoginIDIns)
	SELECT DISTINCT M.TgtMstrID,SalesmanNodeID,SalesmanNodeType,CovAreaNodeID,CovAreaNodeType,[Sec Sales in Litres],1 FROM tblTargetDataImport CROSS JOIN tblTargetMstr M INNER JOIN #tblTargetMeasureCriteria C ON C.TgtMeasureCrtraID=M.TgtMeasureCrtraID WHERE C.TgtMeasureID=4

	INSERT INTO tblTargetDet(TgtMstrId,SalesmanNodeId,SalesmanNodeType,AreaNodeId,AreaNodeType,TargetVal,LoginIDIns)
	SELECT DISTINCT M.TgtMstrID,SalesmanNodeID,SalesmanNodeType,CovAreaNodeID,CovAreaNodeType,[Sunny-1PP-SFO],1 FROM tblTargetDataImport CROSS JOIN tblTargetMstr M INNER JOIN #tblTargetMeasureCriteria C ON C.TgtMeasureCrtraID=M.TgtMeasureCrtraID WHERE C.TgtMeasureID=5

	INSERT INTO tblTargetDet(TgtMstrId,SalesmanNodeId,SalesmanNodeType,AreaNodeId,AreaNodeType,TargetVal,LoginIDIns)
	SELECT DISTINCT M.TgtMstrID,SalesmanNodeID,SalesmanNodeType,CovAreaNodeID,CovAreaNodeType,[Sunny-Bottles-SFO],1 FROM tblTargetDataImport CROSS JOIN tblTargetMstr M INNER JOIN #tblTargetMeasureCriteria C ON C.TgtMeasureCrtraID=M.TgtMeasureCrtraID WHERE C.TgtMeasureID=6

	INSERT INTO tblTargetDet(TgtMstrId,SalesmanNodeId,SalesmanNodeType,AreaNodeId,AreaNodeType,TargetVal,LoginIDIns)
	SELECT DISTINCT M.TgtMstrID,SalesmanNodeID,SalesmanNodeType,CovAreaNodeID,CovAreaNodeType,[Sunny-5L Jar-SFO],1 FROM tblTargetDataImport CROSS JOIN tblTargetMstr M INNER JOIN #tblTargetMeasureCriteria C ON C.TgtMeasureCrtraID=M.TgtMeasureCrtraID WHERE C.TgtMeasureID=7

	INSERT INTO tblTargetDet(TgtMstrId,SalesmanNodeId,SalesmanNodeType,AreaNodeId,AreaNodeType,TargetVal,LoginIDIns)
	SELECT DISTINCT M.TgtMstrID,SalesmanNodeID,SalesmanNodeType,CovAreaNodeID,CovAreaNodeType,[Sunny-15L Jar-SFO],1 FROM tblTargetDataImport CROSS JOIN tblTargetMstr M INNER JOIN #tblTargetMeasureCriteria C ON C.TgtMeasureCrtraID=M.TgtMeasureCrtraID WHERE C.TgtMeasureID=8

	INSERT INTO tblTargetDet(TgtMstrId,SalesmanNodeId,SalesmanNodeType,AreaNodeId,AreaNodeType,TargetVal,LoginIDIns)
	SELECT DISTINCT M.TgtMstrID,SalesmanNodeID,SalesmanNodeType,CovAreaNodeID,CovAreaNodeType,[Sunny SFO Total],1 FROM tblTargetDataImport CROSS JOIN tblTargetMstr M INNER JOIN #tblTargetMeasureCriteria C ON C.TgtMeasureCrtraID=M.TgtMeasureCrtraID WHERE C.TgtMeasureID=9

	INSERT INTO tblTargetDet(TgtMstrId,SalesmanNodeId,SalesmanNodeType,AreaNodeId,AreaNodeType,TargetVal,LoginIDIns)
	SELECT DISTINCT M.TgtMstrID,SalesmanNodeID,SalesmanNodeType,CovAreaNodeID,CovAreaNodeType,[Sunny SBO Total],1 FROM tblTargetDataImport CROSS JOIN tblTargetMstr M INNER JOIN #tblTargetMeasureCriteria C ON C.TgtMeasureCrtraID=M.TgtMeasureCrtraID WHERE C.TgtMeasureID=10

	INSERT INTO tblTargetDet(TgtMstrId,SalesmanNodeId,SalesmanNodeType,AreaNodeId,AreaNodeType,TargetVal,LoginIDIns)
	SELECT DISTINCT M.TgtMstrID,SalesmanNodeID,SalesmanNodeType,CovAreaNodeID,CovAreaNodeType,[Sunny Total],1 FROM tblTargetDataImport CROSS JOIN tblTargetMstr M INNER JOIN #tblTargetMeasureCriteria C ON C.TgtMeasureCrtraID=M.TgtMeasureCrtraID WHERE C.TgtMeasureID=11

	INSERT INTO tblTargetDet(TgtMstrId,SalesmanNodeId,SalesmanNodeType,AreaNodeId,AreaNodeType,TargetVal,LoginIDIns)
	SELECT DISTINCT M.TgtMstrID,SalesmanNodeID,SalesmanNodeType,CovAreaNodeID,CovAreaNodeType,[Priya-SFO],1 FROM tblTargetDataImport CROSS JOIN tblTargetMstr M INNER JOIN #tblTargetMeasureCriteria C ON C.TgtMeasureCrtraID=M.TgtMeasureCrtraID WHERE C.TgtMeasureID=12

	INSERT INTO tblTargetDet(TgtMstrId,SalesmanNodeId,SalesmanNodeType,AreaNodeId,AreaNodeType,TargetVal,LoginIDIns)
	SELECT DISTINCT M.TgtMstrID,SalesmanNodeID,SalesmanNodeType,CovAreaNodeID,CovAreaNodeType,[Priya-SBO],1 FROM tblTargetDataImport CROSS JOIN tblTargetMstr M INNER JOIN #tblTargetMeasureCriteria C ON C.TgtMeasureCrtraID=M.TgtMeasureCrtraID WHERE C.TgtMeasureID=13

	INSERT INTO tblTargetDet(TgtMstrId,SalesmanNodeId,SalesmanNodeType,AreaNodeId,AreaNodeType,TargetVal,LoginIDIns)
	SELECT DISTINCT M.TgtMstrID,SalesmanNodeID,SalesmanNodeType,CovAreaNodeID,CovAreaNodeType,[Priya-Musturd],1 FROM tblTargetDataImport CROSS JOIN tblTargetMstr M INNER JOIN #tblTargetMeasureCriteria C ON C.TgtMeasureCrtraID=M.TgtMeasureCrtraID WHERE C.TgtMeasureID=14

	INSERT INTO tblTargetDet(TgtMstrId,SalesmanNodeId,SalesmanNodeType,AreaNodeId,AreaNodeType,TargetVal,LoginIDIns)
	SELECT DISTINCT M.TgtMstrID,SalesmanNodeID,SalesmanNodeType,CovAreaNodeID,CovAreaNodeType,[Priya-VP],1 FROM tblTargetDataImport CROSS JOIN tblTargetMstr M INNER JOIN #tblTargetMeasureCriteria C ON C.TgtMeasureCrtraID=M.TgtMeasureCrtraID WHERE C.TgtMeasureID=15

	INSERT INTO tblTargetDet(TgtMstrId,SalesmanNodeId,SalesmanNodeType,AreaNodeId,AreaNodeType,TargetVal,LoginIDIns)
	SELECT DISTINCT M.TgtMstrID,SalesmanNodeID,SalesmanNodeType,CovAreaNodeID,CovAreaNodeType,[Priya Total],1 FROM tblTargetDataImport CROSS JOIN tblTargetMstr M INNER JOIN #tblTargetMeasureCriteria C ON C.TgtMeasureCrtraID=M.TgtMeasureCrtraID WHERE C.TgtMeasureID=16

	INSERT INTO tblTargetDet(TgtMstrId,SalesmanNodeId,SalesmanNodeType,AreaNodeId,AreaNodeType,TargetVal,LoginIDIns)
	SELECT DISTINCT M.TgtMstrID,SalesmanNodeID,SalesmanNodeType,CovAreaNodeID,CovAreaNodeType,AvgLPC,1 FROM tblTargetDataImport CROSS JOIN tblTargetMstr M INNER JOIN #tblTargetMeasureCriteria C ON C.TgtMeasureCrtraID=M.TgtMeasureCrtraID WHERE C.TgtMeasureID=17


END

