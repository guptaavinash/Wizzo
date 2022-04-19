





-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[spRptSaveRequestForGenerationOfRetailAnalysisRawData]
@strTime VARCHAR(5000), 
@strProduct VARCHAR(5000),
@strCompanySales VARCHAR(5000),
@SalesLvl INT,
@strKeyVal VARCHAR(500),
@LoginId INT,
@MainMeasureId INT,
@flgToShowPriorityDBROnly TINYINT=0,
@FileName VARCHAR(500),
@EMailId VARCHAR(200)
AS
BEGIN
	INSERT INTO tblRequestDetailForGenerationOfRetailAnalysisRawData(strTime,strProduct,strCompanySales,SalesLvl,strKeyVal,LoginId,MainMeasureId,flgToShowPriorityDBROnly, TimeStampIns,flgGenerated,FileName,EMailId)
	SELECT @strTime,@strProduct,@strCompanySales,@SalesLvl,@strKeyVal,@LoginId,@MainMeasureId,@flgToShowPriorityDBROnly,GETDATE(),0,@FileName,@EMailId
END





