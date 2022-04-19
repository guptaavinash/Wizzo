-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
--exec [SpGetSalesLevel] 1
CREATE PROCEDURE [dbo].[SpGetSalesLevel]
@flgtoShowOnlyMgrLvl TINYINT=0
AS
BEGIN
	IF @flgtoShowOnlyMgrLvl=1
	BEGIN
		SELECT NodeType,NodeTypeDesc,HierTypeID,CASE HierTypeID WHEN 2 THEN 'Company' WHEN 5 THEN 'Distributor' END LevelGroupname  
		FROM tblPMstNodeTypes WHERE HierTypeID IN (2) AND NodeType<=120 AND NodeType<>93 oRDER By level
	END
	ELSE
	BEGIN
		SELECT NodeType,NodeTypeDesc,HierTypeID,CASE HierTypeID WHEN 2 THEN 'Company' WHEN 5 THEN 'Distributor' END LevelGroupname  
		FROM tblPMstNodeTypes WHERE HierTypeID IN (2,5) ORDER BY HierTypeID,level
	END
END
