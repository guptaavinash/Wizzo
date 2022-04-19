-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- ============================================
--[spToCheckForVisit]'868087024619932','15-05-2016'
CREATE PROCEDURE [dbo].[spSaveReasonForNoVisit]
@IMEINO VARCHAR(50)='',  
@Date Date,
@ReasonId INT,
@ReasonText VARCHAR(100)
AS
BEGIN
	DECLARE @VisitDate Date
	-- SET @VisitDate=CONVERT(Date,@Date,105)
	 SET @VisitDate=@Date

	 DECLARE @PDAID INT  
	 DECLARE @PersonID INT  
	 DECLARE @PersonType INT  
	 DECLARE @RowId INT=0
	 
	 IF @IMEINo<>''
	 BEGIN
		 SELECT @PersonID=NodeID,@PersonType=NodeType FROM dbo.fnGetPersonIDfromPDACode(@IMEINO) U INNER JOIN tblMstrPerson P ON P.NodeID=U.PersonID
	 END
	 
	 IF EXISTS(SELECT * FROM tblReasonDetailForNoVisit WHERE PersonNodeId=@PersonID AND PersonNodeType=@PersonType AND VisitDate=@VisitDate)
		DELETE FROM tblReasonDetailForNoVisit WHERE PersonNodeId=@PersonID AND PersonNodeType=@PersonType AND VisitDate=@VisitDate
		
		
	 INSERT INTO tblReasonDetailForNoVisit(PersonNodeId,PersonNodeType,VisitDate,ReasonId,ReasonText,TimeStampIns)
	 SELECT @PersonID,@PersonType,@VisitDate,@ReasonId,@ReasonText,GETDATE()
	 
	 SELECT @RowId=IDENT_CURRENT('tblReasonDetailForNoVisit')
	 
	 SELECT @RowId AS RowId
END





