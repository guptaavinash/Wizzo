



-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[spToGetReasonMasterForNoVisit]
	
AS
BEGIN
	SELECT ReasonId,ReasonDescr,FlgToShowTextBox,flgSOApplicable,flgDSRApplicable,flgNoVisitOption,SeqNo,flgDelayedReason,flgMarketVisit,flgASMApplicable
	FROM tblMstrReasonsForNoVisit ORDER BY SeqNo
END





