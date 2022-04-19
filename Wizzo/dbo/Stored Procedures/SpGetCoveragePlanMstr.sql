-- =============================================
-- Author:		Avinash Gupta
-- Create date: 06-May-2015
-- Description:	Sp to get the master list of Coverage Frequency
-- =============================================
CREATE PROCEDURE [dbo].[SpGetCoveragePlanMstr] 
	
AS
BEGIN
	SELECT CovFrqID,CovFrq,CASE CovFrqID WHEN 10 THEN 1 WHEN 11 THEN 1 ELSE 0 END AS Flg,CASE CovFrqID WHEN 1 THEN 1 WHEN 2 THEN 2 WHEN 3 THEN 2 WHEN 10 THEN 2 ELSE 3 END AS CovTypeId FROM tblMstrCoverageFrequency

	SELECT 1 AS CovTypeId, 'Weekly' AS [Coverage Type]
	UNION
	SELECT 2 AS CovTypeId, 'Fortnightly' AS [Coverage Type]
	UNION
	SELECT 3 AS CovTypeId, 'Once a month' AS [Coverage Type]
END


