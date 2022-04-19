





-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[spRptGetRequestForGenerationOfRetailAnalysisRawData]
AS
BEGIN
	SELECT RequestId,strTime,strProduct,strCompanySales,SalesLvl,strKeyVal,LoginId,MainMeasureId,flgToShowPriorityDBROnly,[FileName],EMailId
	FROM tblRequestDetailForGenerationOfRetailAnalysisRawData
	WHERE flgGenerated=0
END





