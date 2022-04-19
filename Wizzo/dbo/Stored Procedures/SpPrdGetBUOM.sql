-- =============================================
-- Author:		Avinash Gupta
-- Create date: 21-Apr-2015
-- Description:	
-- =============================================
CREATE PROCEDURE [dbo].[SpPrdGetBUOM] 
	@flgConversionUnit TINYINT
AS
BEGIN
	SELECT BUOMID,BUOMName FROM tblPrdMstrBUOMMaster --WHERE ISNULL(flgConversionUnit,0)=@flgConversionUnit
END





