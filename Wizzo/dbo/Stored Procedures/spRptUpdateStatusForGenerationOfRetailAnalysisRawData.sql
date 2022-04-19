





-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[spRptUpdateStatusForGenerationOfRetailAnalysisRawData]
@RequestId INT
AS
BEGIN
	UPDATE tblRequestDetailForGenerationOfRetailAnalysisRawData SET flgGenerated=1,GenerationTime=GETDATE() WHERE RequestId=@RequestId
END





